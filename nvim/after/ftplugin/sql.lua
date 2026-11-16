-- after/ftplugin/sql.lua

vim.opt_local.shiftwidth = 2
vim.opt_local.tabstop = 2
vim.opt_local.softtabstop = 2

vim.opt_local.comments = "b:--,s1:/*,mb:*,ex:*/"
vim.opt_local.formatoptions:append("croj")
vim.opt_local.formatoptions:remove("t")

vim.g.omni_sql_no_default_maps = 1
