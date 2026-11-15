return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      local p = require("config.palette")
      require("tokyonight").setup({
        style = "night",
        transparent = true, -- see-through background : le fond d'écran kitty passe derrière
        styles = {
          comments = { italic = false },
          keywords = { italic = false },
        },
        -- couleurs tirées de la photo du fond : voir lua/config/palette.lua
        on_highlights = function(hl)
          -- une couleur par rôle dans le code
          local roles = {
            -- mots-clés et préprocesseur : if while return static struct typedef sizeof #include
            [p.rose] = { "Keyword", "Statement", "Conditional", "Repeat", "Label", "Include",
              "PreProc", "Define", "Macro", "StorageClass", "Structure", "Exception",
              "@keyword", "@keyword.conditional", "@keyword.repeat", "@keyword.return",
              "@keyword.import", "@keyword.directive", "@keyword.directive.define",
              "@keyword.storage", "@keyword.modifier", "@keyword.type", "@keyword.operator",
              "@keyword.function", "@label" },
            -- types : int char void size_t t_list s_list
            [p.lavande] = { "Type", "Typedef", "@type", "@type.builtin", "@type.definition",
              "@type.qualifier" },
            -- fonctions, définition et appel : ft_lstnew malloc write
            [p.ciel] = { "Function", "@function", "@function.call", "@function.builtin",
              "@function.macro", "@function.method", "@function.method.call" },
            -- paramètres de la fonction
            [p.peche] = { "@variable.parameter", "@variable.parameter.builtin" },
            -- variables et champs : temp list->next
            [p.blanc] = { "Identifier", "@variable", "@variable.member", "@variable.builtin",
              "@property", "@module" },
            -- opérateurs : * & -> = + ++ !
            [p.poudre] = { "Operator", "@operator" },
            -- ponctuation : ; , (les parenthèses suivent la profondeur, plus bas)
            [p.gris] = { "Delimiter", "@punctuation.delimiter", "@punctuation.bracket",
              "@punctuation.special" },
            -- chaînes et caractères : "abc" 'c' <stdio.h>
            [p.dore] = { "String", "Character", "@string", "@string.special",
              "@string.special.path", "@character" },
            -- valeurs fixes : 42 NULL '\0' BUFFER_SIZE \n
            [p.ecume] = { "Number", "Float", "Boolean", "Constant", "SpecialChar",
              "@number", "@number.float", "@boolean", "@constant", "@constant.builtin",
              "@constant.macro", "@string.escape", "@character.special" },
            -- commentaires : l'en-tête 42
            [p.mauve] = { "Comment", "SpecialComment", "@comment", "@comment.documentation" },
          }
          for color, names in pairs(roles) do
            for _, name in ipairs(names) do
              hl[name] = { fg = color }
            end
          end

          -- clangd colore aussi le code : on le ramène aux mêmes rôles
          -- (sinon NULL serait colorée comme une fonction et size_t en bleu)
          for name, link in pairs({
            ["@lsp.typemod.macro.defaultLibrary"] = "@constant.macro",
            ["@lsp.typemod.type.defaultLibrary"] = "@type.builtin",
            ["@lsp.typemod.typeAlias.defaultLibrary"] = "@type.builtin",
            ["@lsp.typemod.variable.defaultLibrary"] = "@variable",
            ["@lsp.type.macro"] = "@constant.macro",
            ["@lsp.type.type"] = "@type",
            ["@lsp.type.class"] = "@type",
            ["@lsp.type.function"] = "@function",
          }) do
            hl[name] = { link = link }
          end
          hl["@lsp.type.unresolvedReference"] = { undercurl = true, sp = p.erreur }

          -- parenthèses et accolades : une couleur par profondeur
          hl.RainbowDelimiterRed = { fg = p.rose }
          hl.RainbowDelimiterYellow = { fg = p.dore }
          hl.RainbowDelimiterBlue = { fg = p.ciel }
          hl.RainbowDelimiterOrange = { fg = p.peche }
          hl.RainbowDelimiterGreen = { fg = p.ecume }
          hl.RainbowDelimiterViolet = { fg = p.lavande }
          hl.RainbowDelimiterCyan = { fg = p.poudre }

          -- numéros de ligne clairs (le fond reste transparent), celui du curseur en doré
          hl.LineNr = { fg = p.numeros }
          hl.LineNrAbove = { fg = p.numeros }
          hl.LineNrBelow = { fg = p.numeros }
          hl.CursorLineNr = { fg = p.dore, bold = true }
          hl.EndOfBuffer = { fg = p.vin }

          -- sélection, recherche, parenthèse correspondante
          hl.Visual = { bg = p.vin }
          hl.Search = { fg = p.encre, bg = p.dore }
          hl.IncSearch = { fg = p.encre, bg = p.rose }
          hl.CurSearch = { fg = p.encre, bg = p.rose }
          hl.MatchParen = { fg = p.dore, bold = true, underline = true }

          -- menus et fenêtres flottantes : fond opaque, lisible sur l'image
          hl.Pmenu = { fg = p.blanc, bg = p.nuit }
          hl.PmenuSel = { fg = p.blanc, bg = p.vin, bold = true }
          hl.PmenuSbar = { bg = p.nuit }
          hl.PmenuThumb = { bg = p.vin }
          hl.NormalFloat = { fg = p.blanc, bg = p.nuit }
          hl.FloatBorder = { fg = p.rose, bg = p.nuit }
          hl.FloatTitle = { fg = p.rose, bg = p.nuit, bold = true }
          hl.WinSeparator = { fg = p.vin }
          hl.TelescopeNormal = { fg = p.blanc, bg = p.nuit }
          hl.TelescopeBorder = { fg = p.rose, bg = p.nuit }
          hl.TelescopePromptBorder = { fg = p.rose, bg = p.nuit }
          hl.TelescopePromptTitle = { fg = p.encre, bg = p.rose, bold = true }
          hl.TelescopeResultsTitle = { fg = p.encre, bg = p.lavande, bold = true }
          hl.TelescopePreviewTitle = { fg = p.encre, bg = p.ciel, bold = true }
          hl.TelescopeSelection = { fg = p.blanc, bg = p.vin, bold = true }
          hl.TelescopeMatching = { fg = p.dore, bold = true }

          -- erreurs et avertissements (clangd, norminette)
          for nom, couleur in pairs({ Error = p.erreur, Warn = p.dore, Info = p.ciel, Hint = p.ecume }) do
            hl["Diagnostic" .. nom] = { fg = couleur }
            hl["DiagnosticVirtualText" .. nom] = { fg = couleur }
            hl["DiagnosticUnderline" .. nom] = { undercurl = true, sp = couleur }
          end
        end,
      })
      vim.cmd.colorscheme("tokyonight")
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    -- barre du bas aux couleurs de la photo : la pastille du mode change de couleur
    opts = function()
      local p = require("config.palette")
      local function mode(couleur)
        return {
          a = { fg = p.encre, bg = couleur, gui = "bold" },
          b = { fg = couleur, bg = p.vin_fonce },
          c = { fg = p.gris, bg = "NONE" },
        }
      end
      local discret = { fg = p.mauve, bg = "NONE" }
      return {
        options = {
          theme = {
            normal = mode(p.rose),
            insert = mode(p.dore),
            visual = mode(p.lavande),
            replace = mode(p.peche),
            command = mode(p.ecume),
            terminal = mode(p.ciel),
            inactive = { a = discret, b = discret, c = discret },
          },
        },
      }
    end,
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
