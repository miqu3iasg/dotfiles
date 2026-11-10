-- lua/config/keymaps/misc.lua

-- Miscellaneous normal-mode keymaps that do not belong to a specific plugin or
-- feature area, such as view toggles, shortcuts to config files and
-- directories, saving, quitting, reloading and running commands.
--
-- The directory shortcuts open directories through the file explorer, so it
-- must be installed.
--
-- See: lua/plugins/oil.lua
-- See: :help :restart

local km = vim.keymap.set

---Set a normal-mode keymap.
---@param lhs string
---@param rhs string|fun()
---@param desc string
local function map(lhs, rhs, desc)
	km("n", lhs, rhs, { desc = desc })
end

---Map a key that toggles a boolean window option.
---@param lhs string
---@param opt string Name of the window option.
---@param desc string
local function toggle_wo(lhs, opt, desc)
	map(lhs, function()
		vim.wo[opt] = not vim.wo[opt]
	end, desc)
end

---Map a key that opens a file for editing.
---@param lhs string
---@param path string
---@param desc string
local function edit_file(lhs, path, desc)
	map(lhs, "<cmd>e " .. path .. "<cr>", desc)
end

---Map a key that opens a directory in the file explorer.
---@param lhs string
---@param path string
---@param desc string
local function open_dir(lhs, path, desc)
	map(lhs, function()
		require("oil").open(vim.fn.expand(path))
	end, desc)
end

---Prompt for a shell command and run it in the current file's directory.
local function run_command_in_file_dir()
	local dir = vim.fn.expand("%:p:h")
	if vim.fn.isdirectory(dir) == 0 then
		-- Terminal and oil buffers have no real directory.
		dir = vim.fn.getcwd()
	end

	vim.ui.input({ prompt = ":! ", completion = "shellcmd" }, function(command)
		if not command or command:match("^%s*$") then
			return
		end
		-- Escapes `%`, `#` and `!` so that `:!` does not expand them.
		vim.cmd(("!cd %s && %s"):format(vim.fn.shellescape(dir, true), vim.fn.escape(command, "%#!")))
	end)
end

-- View toggles
toggle_wo("<leader>vw", "wrap", "Toggle line wrap")
toggle_wo("<leader>vl", "list", "Toggle whitespace characters")
toggle_wo("<leader>vs", "spell", "Toggle spell check")
toggle_wo("<leader>vc", "cursorline", "Toggle cursorline")

map("<leader>vg", function()
	vim.wo.signcolumn = vim.wo.signcolumn == "no" and "yes" or "no"
end, "Toggle sign column")

map("<leader>vd", function()
	local enabled = not vim.diagnostic.is_enabled()
	vim.diagnostic.enable(enabled)
	vim.notify("Diagnostics " .. (enabled and "enabled" or "disabled"))
end, "Toggle diagnostics")

map("<leader>vh", function()
	vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }), { bufnr = 0 })
end, "Toggle inlay hints (buffer)")

-- Line numbers
map("<leader>vn", function()
	vim.wo.number = not vim.wo.number
	vim.wo.relativenumber = vim.wo.number
end, "Toggle line numbers")

map("<leader>vr", function()
	vim.wo.number = true
	vim.wo.relativenumber = not vim.wo.relativenumber
end, "Toggle relative numbers")

-- Config files
edit_file("<leader>zg", "~/dotfiles/git/.gitconfig", "Edit .gitconfig")
edit_file("<leader>zi", "~/dotfiles/i3/config", "Edit i3 config")
edit_file("<leader>zz", "~/dotfiles/zsh/.zshrc", "Edit .zshrc")
edit_file("<leader>zt", "~/dotfiles/tmux/tmux.conf", "Edit tmux.conf")
edit_file("<leader>zk", "~/dotfiles/kitty/kitty.conf", "Edit kitty.conf")

-- Directories
open_dir("<leader>zn", "~/dotfiles/nvim", "Open nvim config dir")
open_dir("<leader>zr", "~/dev/repos", "Open repos dir (workspace)")
open_dir("<leader>zd", "~/dotfiles", "Open dotfiles directory")
open_dir("<leader>zb", "~/.local/bin", "Open ~/.local/bin directory (scripts)")

-- Explicit mappings of the native commands, so they show up with a description.
map("ZZ", "<cmd>x<cr>", "Save and quit")
map("ZQ", "<cmd>q!<cr>", "Quit without saving")
map("ZX", "<cmd>w<cr>", "Save file")

-- Reload, restart and run
map("<leader>re", "<cmd>wa | restart<cr>", "Save all changes and restart Neovim")
map("<leader>rs", "<cmd>luafile %<cr>", "Source lua files")
map("<leader>ru", "<cmd>update<bar>source %<cr>", "Save and source current file")
map("<leader>rc", run_command_in_file_dir, "Run command in file's directory")
