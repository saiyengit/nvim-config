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
      -- skip headers: .h opens as cpp, so clangd's fallback would rewrite
      -- structs/typedefs in LLVM style (brace on same line, 2 spaces)
      format_on_save = function(bufnr)
        if vim.api.nvim_buf_get_name(bufnr):match("%.h$") then
          return
        end
        return { timeout_ms = 2000, lsp_format = "fallback" }
      end,
    },
  },
}
