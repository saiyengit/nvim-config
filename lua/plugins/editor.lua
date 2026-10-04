return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = "Telescope",
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      { "<leader>fk", "<cmd>Telescope keymaps<cr>", desc = "Keymaps" },
      { "<leader>fc", "<cmd>Telescope commands<cr>", desc = "Commands" },
      { "<leader>fd", "<cmd>Telescope lsp_definitions<cr>", desc = "Definitions" },
      { "<leader>fr", "<cmd>Telescope lsp_references<cr>", desc = "References" },
    },
    opts = {},
  },

  -- harpoon2 — quick file marking and jumping
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
    config = function()
      local harpoon = require("harpoon")
      harpoon:setup({
        settings = { save_on_toggle = true },
      })

      -- open files in splits/tabs from the harpoon menu
      harpoon:extend({
        UI_CREATE = function(cx)
          vim.keymap.set("n", "<C-v>", function()
            harpoon.ui:select_menu_item({ vsplit = true })
          end, { buffer = cx.bufnr })
          vim.keymap.set("n", "<C-x>", function()
            harpoon.ui:select_menu_item({ split = true })
          end, { buffer = cx.bufnr })
          vim.keymap.set("n", "<C-g>", function()
            harpoon.ui:select_menu_item({ tabedit = true })
          end, { buffer = cx.bufnr })
        end,
      })

      -- add current file / toggle the built-in menu
      vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end,
        { desc = "Harpoon add file" })
      vim.keymap.set("n", "<leader>hh", function()
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end, { desc = "Harpoon menu" })

      -- jump directly to slots 1-9, 0 = slot 10
      for i = 1, 9 do
        vim.keymap.set("n", "<leader>" .. i, function() harpoon:list():select(i) end,
          { desc = "Harpoon to file " .. i })
      end
      vim.keymap.set("n", "<leader>0", function() harpoon:list():select(10) end,
        { desc = "Harpoon to file 10" })

      -- open harpoon list inside telescope (fuzzy-findable)
      local function toggle_telescope(harpoon_files)
        local conf = require("telescope.config").values
        local file_paths = {}
        for _, item in ipairs(harpoon_files.items) do
          table.insert(file_paths, item.value)
        end

        require("telescope.pickers").new({}, {
          prompt_title = "Harpoon",
          finder = require("telescope.finders").new_table({
            results = file_paths,
          }),
          previewer = conf.file_previewer({}),
          sorter = conf.generic_sorter({}),
        }):find()
      end

      vim.keymap.set("n", "<leader>fh", function()
        toggle_telescope(harpoon:list())
      end, { desc = "Harpoon (Telescope)" })
    end,
  },

  -- flash: s jump, S treesitter jump, r remote, R ts search, <C-s> in /
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<C-s>", mode = "c", function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
  },

  -- yazi file manager
  {
    "mikavilpas/yazi.nvim",
    lazy = false, -- needed for open_for_directories (`nvim .`)
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "-", "<cmd>Yazi<cr>", desc = "Open yazi at current file" },
      { "<leader>cd", "<cmd>Yazi<cr>", desc = "Open yazi at current file" },
      { "<leader>ch", "<cmd>Yazi cwd<cr>", desc = "Open yazi in cwd" },
      { "<leader>ft", "<cmd>Yazi toggle<cr>", desc = "Resume last yazi session" },
    },
    opts = {
      open_for_directories = true,
      keymaps = { show_help = "<f1>" },
    },
  },

  -- surround on a gs prefix (s is flash): gsa gsd gsr gsf gsF gsh
  -- `c` = C block comment: gsaiwc -> /* word */
  {
    "nvim-mini/mini.surround",
    opts = {
      search_method = "cover_or_next",
      custom_surroundings = {
        c = {
          input = { "/%*%s*().-()%s*%*/" },
          output = { left = "/* ", right = " */" },
        },
      },
      mappings = {
        add = "gsa",
        delete = "gsd",
        replace = "gsr",
        find = "gsf",
        find_left = "gsF",
        highlight = "gsh",
        update_n_lines = "gsn",
        suffix_last = "l",
        suffix_next = "n",
      },
    },
  },

  -- 42 header: inserted/updated automatically on save, <F1> manually
  {
    "Diogo-ss/42-header.nvim",
    commit = "213eed395eebe317700800daf26f476a8c94989c",
    config = function()
      -- vim.g.user/mail take priority over $USER/$MAIL
      vim.g.user = "ykadoun"
      vim.g.mail = "yannis.kadoun@learner.42.tech"
      require("42header").setup({
        default_map = true,
        auto_update = false, -- our autocmd below also covers new files
        user = vim.g.user,
        mail = vim.g.mail,
      })
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = vim.api.nvim_create_augroup("42header_autoformat", { clear = true }),
        pattern = { "*.c", "*.h", "*.cpp", "*.hpp", "Makefile" },
        callback = function()
          require("42header.utils.header").stdheader()
        end,
      })
    end,
  },
}
