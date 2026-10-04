return {
  -- server configs (clangd, neocmakelsp) enabled with nvim's built-in vim.lsp
  {
    "neovim/nvim-lspconfig",
    dependencies = { "mason-org/mason.nvim" },
    config = function()
      vim.lsp.enable({
        "clangd", -- C/C++
        "neocmake", -- CMake
      })
    end,
  },

  -- Luau LSP via luau-lsp.nvim — it owns the LSP setup itself.
  -- plugin = { enabled; port } starts the HTTP listener that receives
  -- the live DataModel from the Roblox Studio companion plugin, so
  -- instances built in Studio's 3D editor (not in the Rojo filetree)
  -- show up in intellisense. The port MUST match the port set inside
  -- the Studio companion plugin's settings (default 3667).
  {
    "lopi-py/luau-lsp.nvim",
    dependencies = { "mason-org/mason.nvim", "nvim-lua/plenary.nvim" },
    opts = {
      platform = { type = "roblox" },
      types = { roblox_security_level = "PluginSecurity" },
      server = {
        cmd = { "luau-lsp", "lsp" },
      },
      plugin = {
        enabled = true,
        port = 3667,
      },
    },
  },

  -- cmake-tools.nvim — build/configure/run/debug from inside nvim
  {
    "Civitasv/cmake-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      cmake_command = "cmake",
      ctest_command = "ctest",
      cmake_build_directory = "build",
      cmake_generate_options = { "-G", "Ninja", "-DCMAKE_EXPORT_COMPILE_COMMANDS=1" },
    },
    keys = {
      { "<leader>cb", "<cmd>CMakeBuild<cr>", desc = "CMake Build" },
      { "<leader>cr", "<cmd>CMakeRun<cr>", desc = "CMake Run" },
    },
  },
}
