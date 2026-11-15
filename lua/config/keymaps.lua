-- General keymaps (from s-i-m-g/nvim lua/config/keymaps.lua)
local map = vim.keymap.set

map("n", "<leader>w", "<cmd>w<cr>", { desc = "Save" })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })
map("n", "<Esc>", "<cmd>nohlsearch<cr>")

-- show the full diagnostic message under the cursor (LSP errors/warnings and linter output)
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic" })

-- window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- extra LSP keymaps, buffer-local, only once a server attaches
-- (from s-i-m-g/nvim lua/plugins/lsp.lua).
-- Built-ins still work: grn rename, grr references, gra code action, K hover,
-- gri implementation, grt type def, gO symbols.
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp_keymaps", { clear = true }),
  callback = function(ev)
    local function lmap(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { buffer = ev.buf, desc = desc })
    end
    lmap("gd", vim.lsp.buf.definition, "Go to definition")
    lmap("gD", vim.lsp.buf.declaration, "Go to declaration")
    lmap("<leader>ci", vim.lsp.buf.incoming_calls, "Incoming calls (who calls this)")
    lmap("<leader>co", vim.lsp.buf.outgoing_calls, "Outgoing calls (what this calls)")
  end,
})

-- line number colors: now in lua/plugins/ui.lua (photo palette, lua/config/palette.lua)

-- Ctrl+V in insert mode pastes the system clipboard, like in vim.
-- <C-r><C-o> inserts it as-is, so auto-indent doesn't shift pasted code.
vim.keymap.set("i", "<C-v>", "<C-r><C-o>+", { desc = "Paste system clipboard" })

-- show / hide all errors: messages, underline and margin marks
vim.keymap.set("n", "<leader>m", function()
  local show = not vim.diagnostic.config().virtual_text
  vim.diagnostic.config({ virtual_text = show, underline = show, signs = show })
end, { desc = "Toggle errors" })

-- Space y in visual mode: copy the selection to the system clipboard.
-- At home: the selected lines go straight to wl-copy, so it works even if nvim's
-- clipboard provider doesn't. Without wl-copy (cluster): "+y, through OSC 52.
if vim.fn.executable("wl-copy") == 1 then
  vim.keymap.set("x", "<leader>y", ":w !wl-copy<CR><CR>", { desc = "Copy selection to system clipboard", silent = true })
else
  vim.keymap.set("x", "<leader>y", '"+y', { desc = "Copy selection to system clipboard" })
end

-- Space r: rename the word under the cursor everywhere in the file
-- (whole word only: elem won't touch elem2 or ft_create_elem). No LSP needed.
vim.keymap.set("n", "<leader>r", function()
  local old = vim.fn.expand("<cword>")
  if old == "" then
    return
  end
  vim.ui.input({ prompt = "Renommer " .. old .. " en : " }, function(new)
    if not new or new == "" then
      return
    end
    local view = vim.fn.winsaveview()
    vim.cmd("keeppatterns %s/\\V\\<" .. old .. "\\>/" .. new .. "/ge")
    vim.fn.winrestview(view)
  end)
end, { desc = "Rename word in file" })
