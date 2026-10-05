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

-- brighter, more readable line numbers (fg only — keeps gutter transparent).
-- Re-applied on every :colorscheme so load order doesn't matter.
local function apply()
  vim.api.nvim_set_hl(0, "LineNr", { fg = "#73daca" })
  vim.api.nvim_set_hl(0, "LineNrAbove", { fg = "#73daca" })
  vim.api.nvim_set_hl(0, "LineNrBelow", { fg = "#73daca" })
  vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#27a1b9", bold = true })
end
apply()
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("custom_highlights", { clear = true }),
  callback = apply,
})

-- Ctrl+V in insert mode pastes the system clipboard, like in vim.
-- <C-r><C-o> inserts it as-is, so auto-indent doesn't shift pasted code.
vim.keymap.set("i", "<C-v>", "<C-r><C-o>+", { desc = "Paste system clipboard" })
