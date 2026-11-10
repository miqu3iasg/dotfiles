-- after/ftplugin/typescript.lua

-- Matches the Prettier defaults that conform runs on save: two spaces of
-- indentation and an 80-column line limit.
--
-- The react filetypes inherit this file through the runtime ftplugin, which
-- runs `runtime! ftplugin/typescript.vim` for them.
--
-- See: lua/plugins/formatting.lua
-- See: https://prettier.io/docs/en/options

local opt = vim.opt_local

opt.expandtab = true
opt.shiftwidth = 2
opt.softtabstop = 2
opt.textwidth = 80
