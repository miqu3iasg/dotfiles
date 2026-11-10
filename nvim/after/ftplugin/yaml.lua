-- after/ftplugin/yaml.lua

-- The runtime ftplugin already sets two spaces of indentation, which matches
-- `yamlfmt`, so this file only disables line wrapping, since YAML does not
-- survive it.
--
-- See: lua/plugins/formatting.lua (yamlfmt)
-- See: https://github.com/google/yamlfmt

local opt = vim.opt_local

opt.wrap = false
