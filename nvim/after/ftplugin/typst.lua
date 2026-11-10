-- after/ftplugin/typst.lua

-- Matches the indentation and line limit of `typstyle`, the formatter conform
-- runs on save and tinymist sets up.
--
-- See: lua/plugins/formatting.lua
-- See: lua/language/servers/tinymist.lua
-- See: https://github.com/Myriad-Dreamin/typstyle

local opt = vim.opt_local

opt.expandtab = true
opt.shiftwidth = 2
opt.softtabstop = 2
opt.textwidth = 80
