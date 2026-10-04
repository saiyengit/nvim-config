-- C compile-and-run helpers, each spawned in a fresh kitty window.
--
--   <leader>gcc  compile the current file, run it in a new terminal
--   <leader>gca  file holds one free function -> generate a throwaway main,
--                then loop: type args, see the call + its output, repeat.
--                ctrl-d / ctrl-c ends it; the exe, the generated main and the
--                temp script are all deleted, your source file is never touched.

local map = vim.keymap.set

local TERM = { "kitty" }
local CFLAGS = { "-Wall", "-Wextra", "-Werror" }

-- Interactive shell tail so the window behaves like a normal terminal:
-- output stays on screen, no "press enter", close it yourself when done.
local SHELL_TAIL = 'cd "$HOME"; exec ${SHELL:-/bin/sh} -i'

-- Map a C return type -> printf conversion. nil means "just call it, no print".
local function fmt_for(rtype, is_ptr)
  if is_ptr then
    return rtype == "char" and "%s" or "%p"
  end
  local m = {
    int = "%d", short = "%d", char = "%c", _Bool = "%d", bool = "%d",
    long = "%ld", ["long int"] = "%ld", ["long long"] = "%lld", ["long long int"] = "%lld",
    unsigned = "%u", ["unsigned int"] = "%u", ["unsigned char"] = "%d", ["unsigned short"] = "%u",
    ["unsigned long"] = "%lu", ["unsigned long int"] = "%lu", ["unsigned long long"] = "%llu",
    size_t = "%zu", ssize_t = "%zd",
    float = "%f", double = "%f", ["long double"] = "%Lf",
  }
  return m[rtype]
end

-- Inspect the buffer with treesitter: find `main`, or the first free function.
local function scan_c(buf)
  local ok, parser = pcall(vim.treesitter.get_parser, buf, "c")
  if not ok or not parser then
    return nil, "treesitter C parser unavailable"
  end
  local root = parser:parse()[1]:root()
  local q = vim.treesitter.query.parse("c", [[
    (function_definition type: (_) @ret declarator: (_) @decl)
  ]])

  local ret_text, res = nil, {}
  for id, node in q:iter_captures(root, buf, 0, -1) do
    local cap = q.captures[id]
    if cap == "ret" then
      ret_text = vim.treesitter.get_node_text(node, buf)
    elseif cap == "decl" then
      local d, is_ptr = node, false
      while d and d:type() == "pointer_declarator" do
        is_ptr = true
        d = d:field("declarator")[1]
      end
      if d and d:type() == "function_declarator" then
        local idn = d:field("declarator")[1]
        local name = idn and vim.treesitter.get_node_text(idn, buf)
        if name == "main" then
          res.has_main = true
        elseif name and not res.name then
          res.name, res.rtype, res.is_ptr = name, ret_text, is_ptr
        end
      end
    end
  end
  return res
end

-- Compile with cc in nvim; on failure dump cc output to the quickfix list.
-- Returns true on success.
local function compile(args)
  local cc = vim.list_extend({ "cc" }, vim.deepcopy(CFLAGS))
  vim.list_extend(cc, args)
  local out = vim.fn.systemlist(cc)
  if vim.v.shell_error ~= 0 then
    vim.fn.setqflist({}, " ", { title = "cc", lines = out })
    vim.cmd("copen")
    return false
  end
  return true
end

local function spawn(cmd)
  vim.fn.jobstart(vim.list_extend(vim.deepcopy(TERM), cmd), { detach = true })
end

-- <leader>gcc --------------------------------------------------------------
local function run_file()
  if vim.bo.modified then vim.cmd.write() end
  local src = vim.fn.expand("%:p")
  local bin = vim.fn.expand("%:p:r")

  if not compile({ src, "-o", bin }) then return end

  local run = string.format("%s; rm -f %s; %s",
    vim.fn.shellescape(bin), vim.fn.shellescape(bin), SHELL_TAIL)
  spawn({ "sh", "-c", run })
end

-- <leader>gca --------------------------------------------------------------
local function run_function(buf)
  if vim.bo.modified then vim.cmd.write() end
  local src = vim.fn.expand("%:p")
  local srcdir = vim.fn.expand("%:p:h")

  local info, err = scan_c(buf)
  if not info then
    vim.notify(err, vim.log.levels.ERROR)
    return
  end

  local dir = vim.fn.tempname()
  vim.fn.mkdir(dir, "p")
  local script = vim.fn.tempname() .. ".sh"
  local esc_dir = vim.fn.shellescape(dir)
  local esc_inc = vim.fn.shellescape("-I" .. srcdir)

  -- Already runnable: compile in nvim, run once in a new terminal.
  if info.has_main then
    if not compile({ "-I" .. srcdir, src, "-o", dir .. "/a.out" }) then return end
    local run = string.format("%s; rm -rf %s; %s",
      vim.fn.shellescape(dir .. "/a.out"), esc_dir, SHELL_TAIL)
    spawn({ "sh", "-c", run })
    return
  end

  if not info.name then
    vim.notify("gca: no function definition found in this file", vim.log.levels.WARN)
    return
  end

  -- Build the two halves of the throwaway program. The user's typed args are
  -- spliced in between them inside the terminal, so slashes/quotes are fine.
  local pre = {
    "#include <stdio.h>",
    "#include <stdlib.h>",
    "#include <string.h>",
    "#include <stdbool.h>",
    "#include <unistd.h>",
    "",
  }
  vim.list_extend(pre, vim.fn.readfile(src))
  vim.list_extend(pre, { "", "int main(void)", "{" })

  local conv, post = fmt_for(info.rtype, info.is_ptr)
  if conv then
    table.insert(pre, string.format('\tprintf("%s\\n", %s(', conv, info.name))
    post = { "));", "\treturn (0);", "}", "" }
  else
    table.insert(pre, string.format("\t%s(", info.name))
    post = { ");", "\treturn (0);", "}", "" }
  end

  vim.fn.writefile(pre, dir .. "/pre.c")
  vim.fn.writefile(post, dir .. "/post.c")

  vim.fn.writefile({
    -- Clean up (exe, generated main, this script) whenever the loop ends,
    -- whether by ctrl-d or ctrl-c.
    "trap 'cd \"$HOME\"; rm -rf " .. esc_dir .. "; rm -f " .. vim.fn.shellescape(script) .. "' EXIT INT",
    "cd " .. esc_dir,
    "while :; do",
    "printf '\\n' >&2",
    "IFS= read -r ARGS || break",
    -- No comma and no quotes? treat whitespace as argument separators,
    -- so `10 10` works just as well as `10, 10`.
    [[case "$ARGS" in]],
    [[  *,*|*\"*|*\'*) CALL="$ARGS" ;;]],
    [==[  *) CALL=$(printf '%s' "$ARGS" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' -e 's/[[:space:]]\{1,\}/, /g') ;;]==],
    [[esac]],
    '{ cat pre.c; printf "%s" "$CALL"; cat post.c; } > run.c',
    string.format("printf '%s(%%s)\\n' \"$CALL\"", info.name),
    "if cc " .. table.concat(CFLAGS, " ") .. " " .. esc_inc .. " run.c -o run.out; then",
    "  ./run.out",
    "else",
    "  printf 'compilation failed\\n'",
    "fi",
    "echo --------------------------------------------------",
    "done",
  }, script)

  spawn({ "sh", script })
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "c",
  callback = function(ev)
    map("n", "<leader>gcc", run_file,
      { buffer = ev.buf, desc = "Compile & run C file in new terminal" })
    map("n", "<leader>gca", function() run_function(ev.buf) end,
      { buffer = ev.buf, desc = "Generate main, prompt args, compile & run" })
  end,
})
