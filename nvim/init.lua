-- init.lua

vim.loader.enable()
vim.deprecate = function() end

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.commands")
require("modules.statusline").setup()
require("config.pack")
require("plugins")
require("modules.compile").setup()

vim.cmd.colorscheme("hollow")
