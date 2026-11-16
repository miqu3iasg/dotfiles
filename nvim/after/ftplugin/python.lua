-- after/ftplugin/python.lua

-- PEP 8 style.
-- See: https://peps.python.org/pep-0008/

local opt = vim.opt_local

opt.textwidth = 88
opt.formatoptions:remove("t")
opt.formatoptions:append("croql")

opt.foldmethod = "indent"
