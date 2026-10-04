-- <leader>tt : toggle a small terminal split across the bottom of the screen.
-- The terminal is created in the directory of the file you're editing. The
-- same buffer (and its running shell + scrollback) is reused between toggles,
-- so the directory is fixed when it's first opened, not on every toggle.
--
--   <leader>tt   (normal)   open / hide the terminal
--   <leader>to   (normal)   separate kitty window in the file's dir
--   <C-n>        (terminal) hide the split without leaving your shell
--   <C-\><C-n>              built-in: terminal -> normal mode (to scroll etc.)

local state = { buf = -1, win = -1 }

-- directory of the current file, or the cwd if the buffer has no file
local function file_dir()
  local dir = vim.fn.expand("%:p:h")
  if dir == "" or vim.fn.isdirectory(dir) == 0 then
    return vim.fn.getcwd()
  end
  return dir
end

local function open()
  local dir = file_dir()

  vim.cmd("botright 12split")
  state.win = vim.api.nvim_get_current_win()

  if vim.api.nvim_buf_is_valid(state.buf) then
    vim.api.nvim_win_set_buf(state.win, state.buf)
  else
    state.buf = vim.api.nvim_create_buf(false, false)
    vim.api.nvim_win_set_buf(state.win, state.buf)
    vim.fn.jobstart(vim.o.shell, { term = true, cwd = dir })
    vim.bo[state.buf].buflisted = false
  end

  vim.wo[state.win].number = false
  vim.wo[state.win].relativenumber = false
  vim.wo[state.win].signcolumn = "no"
  vim.cmd.startinsert()
end

local function toggle()
  if vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_win_hide(state.win)
    state.win = -1
  else
    open()
  end
end

vim.keymap.set("n", "<leader>tt", toggle, { desc = "Toggle terminal split" })
vim.keymap.set("t", "<C-n>", function()
  vim.cmd("stopinsert")
  toggle()
end, { desc = "Toggle terminal split" })

-- <leader>to : open a separate kitty window in the current file's directory
-- (same detached-spawn approach as the compile helpers).
vim.keymap.set("n", "<leader>to", function()
  local cmd = string.format("cd %s; exec ${SHELL:-/bin/sh} -i", vim.fn.shellescape(file_dir()))
  vim.fn.jobstart({ "kitty", "sh", "-c", cmd }, { detach = true })
end, { desc = "Open kitty window in file's dir" })
