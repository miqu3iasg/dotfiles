-- after/ftplugin/json.lua

-- Matches the Prettier defaults that conform runs on save: two spaces of
-- indentation. jsonc buffers inherit this file through the runtime ftplugin.
--
-- See: lua/plugins/formatting.lua
-- See: https://prettier.io/docs/en/options

local opt = vim.opt_local

opt.expandtab = true
opt.shiftwidth = 2
opt.softtabstop = 2
opt.wrap = false
