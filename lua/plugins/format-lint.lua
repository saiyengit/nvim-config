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
        -- run with its own python, minus the parenthesize_return step:
        -- no automatic ( ) around return values, everything else unchanged
        c_formatter_42 = {
          command = function()
            local exe = vim.fn.resolve(vim.fn.exepath("c_formatter_42"))
            local python = vim.fn.fnamemodify(exe, ":h") .. "/python"
            return vim.fn.executable(python) == 1 and python or "python3"
          end,
          args = {
            "-E",
            "-c",
            "import sys, c_formatter_42.run as r\n"
              .. "r.parenthesize_return = lambda content: content\n"
              .. "print(r.run_all(sys.stdin.read()), end='')",
          },
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
