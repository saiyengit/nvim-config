-- Indentation exactly like vim: real tabs, 8-wide tabs like vim,
-- and in C vim's cindent places braces and indents what goes inside them.
-- Runs on every FileType, after plugins, so nothing overrides it.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("vim_like_indent", { clear = true }),
  pattern = "*",
  callback = function(ev)
    local bo = vim.bo[ev.buf]
    bo.expandtab = false
    bo.tabstop = 8
    bo.shiftwidth = 8
    bo.softtabstop = 0
    bo.autoindent = false
    bo.smartindent = false
    if bo.filetype == "c" or bo.filetype == "cpp" then
      bo.indentexpr = ""
      bo.cindent = true
    end
  end,
})
