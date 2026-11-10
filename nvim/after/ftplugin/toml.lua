-- after/ftplugin/toml.lua

-- Matches the indentation and line limit of `taplo`, the formatter conform
-- runs on save.
--
-- See: lua/plugins/formatting.lua (taplo)
-- See: https://github.com/tamasfe/taplo

local opt = vim.opt_local

opt.expandtab = true
opt.shiftwidth = 2
opt.softtabstop = 2
opt.textwidth = 80
