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

-- Height of the picker split, as a fraction of the screen, or as an absolute
-- number of lines when greater than 1.
local picker_height = 0.3
local picker_min_height = 8

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

---Warn that the oil buffer has pending changes (renames, deletes) that would
---be discarded by closing the picker.
---@return boolean modified True when the buffer has unsaved changes.
local function warn_if_modified()
	if not vim.bo.modified then
		return false
	end

	vim.notify("Oil: unsaved changes (:w to apply)", vim.log.levels.WARN)
	return true
end

---Close the picker split and return focus to the origin window. Outside a
---picker, fall back to the default oil close.
local function close_picker()
	local origin = vim.w.oil_origin_win ---@type integer?
	if not origin then
		return require("oil.actions").close.callback()
	end

	if warn_if_modified() then
		return
	end

	-- The last window of the tab cannot be closed, so let oil restore the
	-- previous buffer instead.
	if #vim.api.nvim_tabpage_list_wins(0) > 1 then
		vim.api.nvim_win_close(0, true)
	else
		require("oil.actions").close.callback()
	end

	if vim.api.nvim_win_is_valid(origin) then
		vim.api.nvim_set_current_win(origin)
	end
end

---Build a select keymap callback. Inside a picker split, files open in the
---origin window (optionally in a new split of it) and the picker closes.
---Directories are navigated inside the picker. Outside a picker, the default
---oil action runs.
---@param action string Name of the oil action used outside a picker.
---@param split? "split"|"vsplit" Split to create in the origin window.
---@return fun()
local function make_select(action, split)
	return function()
		local actions = require("oil.actions")
		local origin = vim.w.oil_origin_win ---@type integer?
		local entry = oil.get_cursor_entry() ---@type oil.Entry?
		local dir = oil.get_current_dir() ---@type string?

		if not origin or not vim.api.nvim_win_is_valid(origin) or not entry or not dir then
			return actions[action].callback()
		end

		local path = dir .. entry.name ---@type string
		local stat = vim.uv.fs_stat(path)
		if entry.type == "directory" or (stat and stat.type == "directory") then
			return actions.select.callback()
		end

		if warn_if_modified() then
			return
		end

		vim.api.nvim_win_close(0, true)
		vim.api.nvim_set_current_win(origin)
		if split then
			vim.cmd("belowright " .. split)
		end
		vim.cmd.edit(vim.fn.fnameescape(path))
	end
end

local select_entry = make_select("select")
local select_entry_split = make_select("select_split", "split")
local select_entry_vsplit = make_select("select_vsplit", "vsplit")

---Open oil in a temporary bottom split that acts as a file picker. The
---window that was current goes in `vim.w.oil_origin_win` of the new split.
local function open_picker_split()
	-- Reuse the picker if it is already open.
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		if vim.w[win].oil_origin_win then
			return vim.api.nvim_set_current_win(win)
		end
	end

	local origin = vim.api.nvim_get_current_win()
	local height = picker_height > 1 and picker_height or math.floor(vim.o.lines * picker_height)
	vim.cmd(("botright %dsplit"):format(math.max(picker_min_height, height)))
	vim.w.oil_origin_win = origin
	vim.wo.winfixheight = true
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
	["sh"] = {
		callback = select_entry_split,
		desc = "Select in horizontal split (of origin window if from split)",
	},
	["sv"] = {
		callback = select_entry_vsplit,
		desc = "Select in vertical split (of origin window if from split)",
	},
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
	["q"] = { callback = close_picker, desc = "Close oil (closes the split if from picker)" },
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

vim.keymap.set("n", "gs", open_picker_split, {
	desc = "Open parent directory in bottom split picker",
})

vim.keymap.set("n", "g~", goto_home.callback, { desc = goto_home.desc })
vim.keymap.set("n", "g.", goto_cwd.callback, { desc = goto_cwd.desc })
