-- init.lua

vim.loader.enable()
vim.deprecate = function() end

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.filetypes")
require("config.commands")
require("modules.statusline").setup()
require("config.pack")
require("plugins")
require("modules.scratch").setup()
require("modules.compile").setup()
require("modules.sessions").setup()

vim.cmd.colorscheme("plain")
