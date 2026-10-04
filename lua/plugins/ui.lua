return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        style = "night",
        transparent = true, -- see-through background
      })
      vim.cmd.colorscheme("tokyonight")
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
  },

  -- colour brackets by nesting depth
  {
    "HiPhish/rainbow-delimiters.nvim",
    config = function()
      require("rainbow-delimiters.setup").setup({
        highlight = {
          "RainbowDelimiterRed",
          "RainbowDelimiterYellow",
          "RainbowDelimiterBlue",
          "RainbowDelimiterOrange",
          "RainbowDelimiterGreen",
          "RainbowDelimiterViolet",
          "RainbowDelimiterCyan",
        },
      })
    end,
  },

  -- which-key popup with named groups
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      delay = 400,
      spec = {
        { "<leader>f", group = "find" },
        { "<leader>h", group = "harpoon" },
        { "<leader>c", group = "cmake / yazi / calls" },
        { "<leader>g", group = "compile & run" },
        { "<leader>s", group = "surround / swap" },
        { "<leader>d", group = "debug" },
        { "<leader>t", group = "terminal" },
        { "]", group = "next" },
        { "[", group = "prev" },
        { "gs", group = "surround" },
      },
    },
    keys = {
      -- which-key: show only buffer-local maps
      {
        "<leader>?",
        function() require("which-key").show({ global = false }) end,
        desc = "Buffer-local keymaps (which-key)",
      },
    },
  },
}
