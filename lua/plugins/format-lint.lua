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
}
