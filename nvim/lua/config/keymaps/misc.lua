-- lua/config/keymaps/misc.lua

-- Miscellaneous normal-mode keymaps, such as view toggles, config shortcuts,
-- the file explorer, saving, quitting, reloading and running commands.
--
-- See: lua/plugins/oil.lua
-- See: :help :restart

local keys = require("lib.keys")
local map = keys.map
local toggle_wo = keys.toggle_wo

---Map a key that opens a file for editing.
---@param lhs string
---@param path string
---@param desc string
local function edit_file(lhs, path, desc) map("n", lhs, "<cmd>e " .. path .. "<cr>", desc) end

---Map a key that opens a directory in the file explorer.
---@param lhs string
---@param path string
---@param desc string
local function open_dir(lhs, path, desc)
	map("n", lhs, function() require("oil").open(vim.fn.expand(path)) end, desc)
end

toggle_wo("<leader>vw", "wrap", "Toggle line wrap")
toggle_wo("<leader>vl", "list", "Toggle whitespace characters")
toggle_wo("<leader>vs", "spell", "Toggle spell check")
toggle_wo("<leader>vc", "cursorline", "Toggle cursorline")

map("n", "<leader>vm", function()
	if vim.wo.colorcolumn ~= "" then
		vim.wo.colorcolumn = ""
		return
	end
	vim.wo.colorcolumn = vim.bo.textwidth > 0 and "+1" or "80"
end, "Toggle color column")

map("n", "<leader>vn", function()
	vim.wo.number = not vim.wo.number
	vim.wo.relativenumber = vim.wo.number
end, "Toggle line numbers")

edit_file("<leader>zi", "~/dotfiles/i3/config", "Edit i3 config")
edit_file("<leader>zt", "~/dotfiles/tmux/tmux.conf", "Edit tmux.conf")
edit_file("<leader>zk", "~/dotfiles/kitty/kitty.conf", "Edit kitty.conf")

open_dir("<leader>zn", "~/dotfiles/nvim", "Open nvim config dir")
open_dir("<leader>zz", "~/dotfiles/zsh", "Open zsh config dir")
open_dir("<leader>zw", "~/dev/repos", "Open workspace dir")
open_dir("<leader>zd", "~/dotfiles", "Open dotfiles directory")
open_dir("<leader>zb", "~/dotfiles/scripts", "Open scripts directory")

-- Explicit mappings of the native commands, so they show up with a description.
map("n", "ZZ", "<cmd>x<cr>", "Save and quit")
map("n", "ZQ", "<cmd>q!<cr>", "Quit without saving")
map("n", "ZX", "<cmd>w<cr>", "Save file")

-- Reload, restart and run
map("n", "<leader>re", "<cmd>wa | restart<cr>", "Save all changes and restart Neovim")
map("n", "<leader>rs", "<cmd>luafile %<cr>", "Source lua files")
map("n", "<leader>ru", "<cmd>update<bar>source %<cr>", "Save and source current file")
