-- No auto-indent anywhere: tabs are typed by hand, like in plain vim.
-- Runs on every FileType, after the built-in indent scripts and plugins,
-- so nothing can switch auto-indent back on for a buffer.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("no_auto_indent", { clear = true }),
  pattern = "*",
  callback = function(ev)
    local bo = vim.bo[ev.buf]
    bo.autoindent = false
    bo.smartindent = false
    bo.cindent = false
    bo.indentexpr = ""
    bo.indentkeys = ""
  end,
})
