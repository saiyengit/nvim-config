return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        style = "night",
        transparent = true, -- see-through background
        styles = {
          comments = { italic = false },
          keywords = { italic = false },
        },
        -- code colors copied from claude.ai's code blocks
        on_highlights = function(hl)
          local purple = "#cc7bf4" -- keywords, types, #include
          local blue = "#70b8ff" -- functions
          local green = "#9be963" -- strings, chars
          local cyan = "#53dcc4" -- numbers, constants
          local orange = "#f2a05a" -- parameters
          local white = "#e6e8ec" -- variables, operators, punctuation
          local gray = "#7f848e" -- comments
          local groups = {
            [purple] = { "Keyword", "Statement", "Conditional", "Repeat", "Include",
              "PreProc", "Define", "Macro", "Type", "StorageClass", "Structure",
              "@keyword", "@keyword.conditional", "@keyword.repeat", "@keyword.return",
              "@keyword.import", "@keyword.directive", "@keyword.directive.define",
              "@keyword.storage", "@keyword.modifier", "@keyword.type", "@keyword.operator",
              "@type", "@type.builtin", "@type.definition", "@type.qualifier" },
            [blue] = { "Function", "@function", "@function.call", "@function.builtin",
              "@function.macro" },
            [green] = { "String", "Character", "@string", "@string.special.path",
              "@character" },
            [cyan] = { "Number", "Float", "Boolean", "Constant", "@number",
              "@number.float", "@boolean", "@constant", "@constant.builtin",
              "@constant.macro" },
            [orange] = { "@variable.parameter" },
            [white] = { "Identifier", "@variable", "@variable.member", "@property",
              "Operator", "@operator", "@punctuation.delimiter" },
            [gray] = { "Comment", "@comment" },
          }
          for color, names in pairs(groups) do
            for _, name in ipairs(names) do
              hl[name] = { fg = color }
            end
          end
        end,
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
