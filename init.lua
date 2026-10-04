-- Neovim config, ported from the nvf (Nix) module.
--
--   lua/config/options.lua    editor options, leader
--   lua/config/lazy.lua       lazy.nvim bootstrap
--   lua/plugins/*.lua         plugin specs
--   lua/config/keymaps.lua    general + LSP keymaps, line number colors
--   lua/config/terminal.lua   <leader>tt / <leader>to
--   lua/config/compile.lua    <leader>gcc / <leader>gca (C)

require("config.options")
require("config.lazy")

-- run after every plugin setup so they can override plugin keymaps
require("config.keymaps")
require("config.terminal")
require("config.compile")
