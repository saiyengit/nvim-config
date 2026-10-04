-- mason: installs LSP servers and tools into nvim's data dir (no sudo) and
-- puts them on nvim's PATH. Other specs depend on it so the PATH is ready
-- before they look for their binaries.
return {
  {
    "mason-org/mason.nvim",
    lazy = false,
    priority = 900,
    opts = {},
  },

  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "mason-org/mason.nvim" },
    opts = {
      ensure_installed = {
        "clangd", -- C/C++
        "neocmakelsp", -- CMake
        "luau-lsp", -- Luau (started by luau-lsp.nvim)
        "tree-sitter-cli", -- needed by nvim-treesitter to build parsers
      },
    },
  },
}
