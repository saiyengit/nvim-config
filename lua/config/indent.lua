-- Indentation exactly like vim: real tabs, the new line keeps the indent,
-- and in C vim's cindent places braces and indents what goes inside them.
-- Runs on every FileType, after plugins, so nothing overrides it.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("vim_like_indent", { clear = true }),
  pattern = "*",
  callback = function(ev)
    local bo = vim.bo[ev.buf]
    bo.expandtab = false
    bo.tabstop = 4
    bo.shiftwidth = 4
    bo.softtabstop = 0
    bo.autoindent = true
    bo.smartindent = false
    if bo.filetype == "c" or bo.filetype == "cpp" then
      bo.indentexpr = ""
      bo.cindent = true
    end
  end,
})
