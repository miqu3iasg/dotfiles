-- lua/plugins/oil.lua

-- File explorer that edits the filesystem as a buffer, replacing netrw.
-- Deletions go to the trash, and simple edits apply without confirmation.
--
-- The `gx` viewer must be installed for the extension to open.
--
-- $ sudo pacman -S zathura zathura-pdf-mupdf zathura-djvu zathura-cb imv mpv xdg-utils
--
-- See: lua/modules/sessions.lua
-- See: https://github.com/stevearc/oil.nvim

local oil = require("oil")

---Entry of the oil buffer under the cursor.
---@class oil.Entry
---@field name string
---@field type string

-- Viewer apps by extension. `gx` opens the entry with the matching app, or
-- with the system default.
local app_map = {}
for app, exts in pairs({
	zathura = { "pdf", "djvu", "epub", "cbz", "cbr", "xps" },
	imv = { "png", "jpg", "jpeg", "gif", "webp", "bmp", "svg" },
	mpv = { "mp4", "mkv", "webm", "mov", "avi", "mp3", "flac", "wav" },
}) do
	for _, ext in ipairs(exts) do
		app_map[ext] = { app }
	end
end

---Open the entry under the cursor with its extension's viewer app, falling
---back to the OS default.
local function open_with_viewer()
	local entry = oil.get_cursor_entry()
	local dir = oil.get_current_dir()
	if not entry or not dir then
		return
	end

	local path = dir .. entry.name
	local ext = entry.name:match("^.+%.(.+)$")
	local cmd = ext and app_map[ext:lower()]
	if cmd then
		local full_cmd = vim.list_extend(vim.deepcopy(cmd), { path })
		vim.fn.jobstart(full_cmd, { detach = true })
	else
		require("oil.actions").open_external.callback()
	end
end

---Select the entry under the cursor, opening the file in the origin window
---when oil was opened as a picker split.
local function select_entry()
	local origin = vim.w.oil_origin_win ---@type integer?
	local entry = oil.get_cursor_entry() ---@type oil.Entry?
	local dir = oil.get_current_dir() ---@type string?
	local default = require("oil.actions").select.callback

	if not origin or not vim.api.nvim_win_is_valid(origin) or not entry or not dir then
		return default()
	end

	local path = dir .. entry.name ---@type string
	local stat = vim.uv.fs_stat(path)
	if entry.type == "directory" or (stat and stat.type == "directory") then
		return default()
	end

	vim.api.nvim_win_close(0, true)
	vim.api.nvim_set_current_win(origin)
	vim.cmd.edit(vim.fn.fnameescape(path))
end

---Open oil in a temporary horizontal split that acts as a file picker. The
---current window goes in `vim.w.oil_origin_win` of the new split.
local function open_picker_split()
	local origin = vim.api.nvim_get_current_win()
	vim.cmd("belowright split")
	vim.w.oil_origin_win = origin
	oil.open()
end

---Build an oil keymap entry that opens a directory.
---@param path_fn fun(): string Returns the directory to open.
---@param desc string
---@return { desc: string, callback: fun() }
local function goto_dir(path_fn, desc)
	return {
		desc = desc,
		callback = function()
			oil.open(path_fn())
		end,
	}
end

-- Shared between the in-buffer oil keymaps and the global `g~`/`g.` maps.
local goto_home = goto_dir(function()
	return vim.fn.expand("~")
end, "Open home directory")
local goto_cwd = goto_dir(function()
	return vim.fn.getcwd()
end, "Open cwd")

local select_desc = "Select (opens in origin window if from split)"

local keymaps = {
	-- Disabled to avoid conflicts with the tmux navigation keys.
	["<C-c>"] = false,
	["<C-h>"] = false,
	["<C-l>"] = false,
	["-"] = "actions.parent",
	["<CR>"] = { callback = select_entry, desc = select_desc },
	["H"] = "actions.parent",
	["L"] = { callback = select_entry, desc = select_desc },
	["sh"] = "actions.select_split",
	["sv"] = "actions.select_vsplit",
	["gp"] = {
		"actions.preview",
		opts = {
			vertical = true,
			split = "botright",
		},
	},
	["gR"] = "actions.refresh",
	["<C-r>"] = "actions.refresh",
	["gs"] = "actions.change_sort",
	["gx"] = {
		callback = open_with_viewer,
	},
	["gy"] = "actions.copy_entry_path",
	["gh"] = "actions.toggle_hidden",
	["cd"] = "actions.cd",
	["q"] = "actions.close",
	["~"] = goto_home,
	["_"] = goto_cwd,
}

oil.setup({
	default_file_explorer = true,
	columns = {
		"permissions",
		"owner",
		"size",
		{ "mtime", format = "%d/%m %H:%M" },
		{ "ctime", format = "%d/%m %H:%M" },
		{ "birthtime", format = "%d/%m %H:%M" },
	},
	keymaps = keymaps,
	delete_to_trash = true,
	watch_for_changes = true,
	constrain_cursor = "name",
	lsp_file_methods = {
		autosave_changes = "unmodified",
	},
	view_options = {
		show_hidden = true,
	},
	skip_confirm_for_simple_edits = true,
	skip_confirm_for_delete = true,
	preview_win = {
		border = "single",
	},
	win_options = {
		signcolumn = "no",
		number = false,
		relativenumber = false,
		cursorline = true,
	},
})

-- Marks every explorer buffer, so consumers do not have to depend on the
-- `oil` filetype staying the same (canola is an oil fork).
-- See: lua/modules/sessions.lua
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("oil_explorer_flag", { clear = true }),
	pattern = "oil",
	callback = function(args)
		vim.b[args.buf].explorer = true
	end,
})

vim.keymap.set("n", "go", "<CMD>Oil<CR>", {
	desc = "Open parent directory",
})

vim.keymap.set("n", "g-", open_picker_split, {
	desc = "Open parent directory in horizontal split picker",
})

vim.keymap.set("n", "g~", goto_home.callback, { desc = goto_home.desc })
vim.keymap.set("n", "g.", goto_cwd.callback, { desc = goto_cwd.desc })
