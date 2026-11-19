-- lua/config/keymaps/init.lua

-- Leader keys, which must exist before any `<leader>` mapping, and the keymap
-- module loading order.
--
-- See: :help map.txt

local M = {}

vim.g.mapleader = " "
vim.g.maplocalleader = ","

require("config.keymaps.windows")
require("config.keymaps.command_mode")
require("config.keymaps.search")
require("config.keymaps.quickfix")
require("config.keymaps.editing")
require("config.keymaps.buffers")
require("config.keymaps.terminal")
require("config.keymaps.files")
require("config.keymaps.misc")
require("config.keymaps.marks")
require("config.keymaps.inserts")
require("config.keymaps.pack")

return M
