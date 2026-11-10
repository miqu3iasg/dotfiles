-- after/ftplugin/sh.lua

-- Matches the indentation that conform passes to `shfmt` (`-i 2`): two spaces,
-- regardless of the shell dialect.
--
-- See: lua/plugins/formatting.lua (shfmt)
-- See: https://github.com/mvdan/sh

local opt = vim.opt_local

opt.expandtab = true
opt.shiftwidth = 2
opt.softtabstop = 2
