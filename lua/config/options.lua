-- leader key = space (must be set before lazy.nvim loads plugins)
vim.g.mapleader = " "
vim.g.maplocalleader = " "
-- yazi replaces netrw for directory buffers (`nvim .`)
vim.g.loaded_netrwPlugin = 1

local o = vim.opt

o.number = true
o.relativenumber = false -- fixed line numbers, they don't shift when the cursor moves
o.ignorecase = true
o.smartcase = true
o.undofile = true

o.cursorline = true
o.cursorlineopt = "number" -- highlight the line number only
o.tabstop = 8
o.shiftwidth = 8
o.expandtab = false -- 42 norm wants real tabs
-- indentation identical to plain vim: tabs shown 8 wide, C uses cindent
o.autoindent = false
o.smartindent = false
o.softtabstop = 0 -- Tab key inserts a real tab
o.wrap = false
o.termguicolors = true
o.scrolloff = 8
o.signcolumn = "yes"
o.updatetime = 250
o.clipboard = "" -- keep registers separate; use "+y / "+p explicitly
-- No wl-copy / xclip / xsel (the 42 cluster, nothing installable without sudo):
-- go through the terminal instead (OSC 52, which kitty supports), so "+y, "+p,
-- Space y and Ctrl+V still reach the system clipboard. At home wl-copy exists,
-- so nothing changes there.
if vim.fn.executable("wl-copy") == 0 and vim.fn.executable("xclip") == 0
    and vim.fn.executable("xsel") == 0 then
  local osc52 = require("vim.ui.clipboard.osc52")
  vim.g.clipboard = {
    name = "OSC 52",
    copy = { ["+"] = osc52.copy("+"), ["*"] = osc52.copy("*") },
    paste = { ["+"] = osc52.paste("+"), ["*"] = osc52.paste("*") },
  }
end
o.splitright = true
o.splitbelow = true

-- set the terminal title to just the filename, so kitty's
-- tab_title_template ({title}) can show it in the tab bar
o.title = true
o.titlestring = "%t"

-- diagnostics: everything hidden by default (messages, underline, margin marks),
-- <leader>m shows / hides it all
vim.diagnostic.config({
  virtual_text = false,
  underline = false,
  signs = false,
  severity_sort = true,
})
vim.opt.autochdir = true
