-- leader key = space (must be set before lazy.nvim loads plugins)
vim.g.mapleader = " "
vim.g.maplocalleader = " "
-- yazi replaces netrw for directory buffers (`nvim .`)
vim.g.loaded_netrwPlugin = 1

local o = vim.opt

o.number = true
o.relativenumber = true
o.ignorecase = true
o.smartcase = true
o.undofile = true

o.cursorline = true
o.cursorlineopt = "number" -- highlight the line number only
o.tabstop = 4
o.shiftwidth = 4
o.expandtab = false -- 42 norm wants real tabs
-- no auto-indent at all: tabs are typed by hand, like in plain vim
o.autoindent = false
o.smartindent = false
o.cindent = false
vim.cmd("filetype indent off")
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
