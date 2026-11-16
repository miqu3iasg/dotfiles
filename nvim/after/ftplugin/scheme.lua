-- after/ftplugin/scheme.lua

vim.opt_local.shiftwidth = 2
vim.opt_local.tabstop = 2
vim.opt_local.softtabstop = 2
vim.opt_local.lisp = true

vim.opt_local.commentstring = "; %s"

vim.opt_local.formatoptions:remove({ "c", "r", "o" })
