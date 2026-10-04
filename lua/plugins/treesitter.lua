return {
  -- nvim-treesitter `main` branch (the rewrite for nvim 0.11+).
  -- Installing parsers needs the `tree-sitter` CLI; c/lua/vim/vimdoc/query/markdown
  -- already ship with nvim.
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    dependencies = { "mason-org/mason.nvim" },
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").install({
        "c", "cpp", "cmake", "lua", "luau", "bash", "make", "json",
      })
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("treesitter_start", { clear = true }),
        callback = function(ev)
          if pcall(vim.treesitter.start, ev.buf) then
            vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },

  -- treesitter text objects: af/if, aa/ia, al/il ... ]f [f, <leader>sa swap
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      -- Treesitter text objects (from s-i-m-g/nvim lua/plugins/treesitter-textobjects.lua)
      -- af/if function, ac/ic struct, aa/ia argument, ai/ii conditional,
      -- al/il loop, am/im call, a=/i= assignment; ]f [f ]F [F jump; <leader>sa/sA/sf swap
      require("nvim-treesitter-textobjects").setup({
        select = {
          -- if the cursor is just before a text object, jump forward to it
          lookahead = true,
          -- multi-line objects select linewise; arguments stay charwise
          selection_modes = {
            ["@function.outer"] = "V",
            ["@class.outer"] = "V",
            ["@loop.outer"] = "V",
            ["@conditional.outer"] = "V",
            ["@parameter.outer"] = "v",
            ["@call.outer"] = "v",
          },
        },
        move = {
          -- record the pre-jump position so <C-o> brings you back
          set_jumps = true,
        },
      })

      local select = require("nvim-treesitter-textobjects.select")
      local move = require("nvim-treesitter-textobjects.move")
      local swap = require("nvim-treesitter-textobjects.swap")
      local map = vim.keymap.set

      -- SELECT: usable after an operator (d/c/y/v...) or in visual mode.
      -- `a…` = "around" (includes braces/trailing comma), `i…` = "inner".
      local objects = {
        f = "function", -- a whole function definition / its body
        c = "class", -- a struct / union / enum with a body
        a = "parameter", -- one argument in a definition or a call
        i = "conditional", -- an if / else if / else / switch
        l = "loop", -- a for / while / do-while
        m = "call", -- a function call (name + argument list)
      }
      for key, name in pairs(objects) do
        map({ "x", "o" }, "a" .. key, function()
          select.select_textobject("@" .. name .. ".outer", "textobjects")
        end, { desc = "around " .. name })
        map({ "x", "o" }, "i" .. key, function()
          select.select_textobject("@" .. name .. ".inner", "textobjects")
        end, { desc = "inner " .. name })
      end

      -- assignment halves: `i=` selects the value, `a=` the whole statement
      map({ "x", "o" }, "a=", function()
        select.select_textobject("@assignment.outer", "textobjects")
      end, { desc = "around assignment" })
      map({ "x", "o" }, "i=", function()
        select.select_textobject("@assignment.rhs", "textobjects")
      end, { desc = "assignment value (rhs)" })

      -- MOVE: jump between functions. Works in normal, visual and operator mode.
      map({ "n", "x", "o" }, "]f", function()
        move.goto_next_start("@function.outer", "textobjects")
      end, { desc = "Next function start" })
      map({ "n", "x", "o" }, "[f", function()
        move.goto_previous_start("@function.outer", "textobjects")
      end, { desc = "Prev function start" })
      map({ "n", "x", "o" }, "]F", function()
        move.goto_next_end("@function.outer", "textobjects")
      end, { desc = "Next function end" })
      map({ "n", "x", "o" }, "[F", function()
        move.goto_previous_end("@function.outer", "textobjects")
      end, { desc = "Prev function end" })

      -- SWAP: reorder arguments / functions without cut-and-paste.
      map("n", "<leader>sa", function()
        swap.swap_next("@parameter.inner")
      end, { desc = "Swap arg with next" })
      map("n", "<leader>sA", function()
        swap.swap_previous("@parameter.inner")
      end, { desc = "Swap arg with previous" })
      map("n", "<leader>sf", function()
        swap.swap_next("@function.outer")
      end, { desc = "Swap function with next" })
    end,
  },
}
