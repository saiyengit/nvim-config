return {
  -- formatting, on save (falls back to the LSP formatter for other filetypes)
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = "ConformInfo",
    opts = {
      formatters_by_ft = {
        c = { "c_formatter_42" },
      },
      formatters = {
        -- 42 norm formatter: `pipx install c-formatter-42`
        c_formatter_42 = {
          command = "c_formatter_42",
          stdin = true,
        },
      },
      format_on_save = {
        timeout_ms = 2000,
        lsp_format = "fallback",
      },
    },
  },

  -- norminette for C — diagnostics show inline, run on save
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufWritePost" },
    config = function()
      local lint = require("lint")

      lint.linters_by_ft = {
        c = { "norminette" },
      }

      lint.linters.norminette = {
        cmd = "norminette",
        args = { "-f", "json", "--no-colors" },
        stdin = false,
        ignore_exitcode = true,
        -- nvim-lint parser for `norminette -f json` (from s-i-m-g/nvim lua/plugins/lint.lua).
        parser = function(output)
          -- Some norminette versions print an extra "Setting locale to ..." line to
          -- stdout before the JSON payload, so decode from the first "{".
          local json_start = output:find("{")
          if not json_start then
            return {}
          end
          local ok, decoded = pcall(vim.json.decode, output:sub(json_start))
          if not ok or not decoded or not decoded.files then
            return {}
          end

          local diagnostics = {}
          for _, file in ipairs(decoded.files) do
            for _, err in ipairs(file.errors or {}) do
              local hl = (err.highlights and err.highlights[1]) or {}
              local lnum = math.max((hl.lineno or 1) - 1, 0)
              local col = math.max((hl.column or 1) - 1, 0)
              table.insert(diagnostics, {
                lnum = lnum,
                col = col,
                severity = (err.level == "Warning") and vim.diagnostic.severity.WARN
                  or vim.diagnostic.severity.ERROR,
                message = err.text,
                source = "norminette",
                code = err.name,
              })
            end
          end
          return diagnostics
        end,
      }

      vim.api.nvim_create_autocmd("BufWritePost", {
        group = vim.api.nvim_create_augroup("nvim_lint", { clear = true }),
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },
}
