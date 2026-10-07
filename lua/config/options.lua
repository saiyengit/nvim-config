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
o.splitright = true
o.splitbelow = true

-- set the terminal title to just the filename, so kitty's
-- tab_title_template ({title}) can show it in the tab bar
o.title = true
o.titlestring = "%t"

-- diagnostics inline (virtual text is off by default since nvim 0.11)
vim.diagnostic.config({
  virtual_text = true,
  severity_sort = true,
})
