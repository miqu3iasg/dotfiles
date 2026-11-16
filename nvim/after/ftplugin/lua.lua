-- after/ftplugin/lua.lua

-- Indentation and wrapping for Lua buffers. It lives in `after/` so it
-- overrides the defaults from the runtime ftplugin, which uses spaces.
--
-- See: lua/plugins/formatting.lua (stylua)

local opt = vim.opt_local

-- Tabs, as in stylua's default style.
opt.expandtab = false

-- Limit used by `gq` and by the color column toggle. Comments are kept within
-- 120 columns, while stylua decides how long code lines can be.
opt.textwidth = 120

-- Auto-wrap only comments, and continue them when pressing enter or `o`/`O`.
opt.formatoptions:append("cro")
opt.formatoptions:remove("t")
