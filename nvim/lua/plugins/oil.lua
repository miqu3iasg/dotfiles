-- lua/plugins/oil.lua

-- File explorer that edits the filesystem as a normal buffer, replacing netrw as
-- the default explorer. Deletions go to the trash, and simple edits such as
-- delete, move and rename are applied without confirmation.
--
-- Entries are opened with an extension-specific viewer, falling back to
-- `xdg-open` for anything else. The viewers must be installed for their
-- extensions to work: zathura for documents and ebooks, imv for images and mpv
-- for audio and video. On Arch Linux:
--
-- $ sudo pacman -S zathura zathura-pdf-mupdf zathura-djvu zathura-cb imv mpv xdg-utils
--
-- See: https://github.com/stevearc/oil.nvim

local oil = require("oil")

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

oil.setup({
	default_file_explorer = true,
	columns = {
		"permissions",
		"owner",
		"group",
		"size",
		{ "mtime", format = "%d/%m %H:%M" },
		{ "ctime", format = "%d/%m %H:%M" },
		{ "birthtime", format = "%d/%m %H:%M" },
	},
	keymaps = {
		-- Disabled to avoid conflicts with the tmux navigation keys.
		["<C-c>"] = false,
		["<C-h>"] = false,
		["<C-l>"] = false,
		["-"] = "actions.parent",
		["<CR>"] = "actions.select",
		["H"] = "actions.parent",
		["L"] = "actions.select",
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
			-- Opens with a specific app based on the extension, or falls back to
			-- the OS default.
			callback = function()
				local entry = oil.get_cursor_entry()
				local dir = oil.get_current_dir()
				if not entry or not dir then
					return
				end

				local path = dir .. entry.name
				local ext = entry.name:match("^.+%.(.+)$")
				ext = ext and ext:lower() or nil

				local app_map = {
					pdf = { "zathura" },
					djvu = { "zathura" },
					epub = { "zathura" },
					cbz = { "zathura" },
					cbr = { "zathura" },
					xps = { "zathura" },

					png = { "imv" },
					jpg = { "imv" },
					jpeg = { "imv" },
					gif = { "imv" },
					webp = { "imv" },
					bmp = { "imv" },
					svg = { "imv" },

					mp4 = { "mpv" },
					mkv = { "mpv" },
					webm = { "mpv" },
					mov = { "mpv" },
					avi = { "mpv" },
					mp3 = { "mpv" },
					flac = { "mpv" },
					wav = { "mpv" },
				}

				local cmd = ext and app_map[ext]
				if cmd then
					local full_cmd = vim.list_extend(vim.deepcopy(cmd), { path })
					vim.fn.jobstart(full_cmd, { detach = true })
				else
					require("oil.actions").open_external.callback()
				end
			end,
		},
		["gy"] = "actions.copy_entry_path",
		["gh"] = "actions.toggle_hidden",
		["cd"] = "actions.cd",
		["q"] = "actions.close",
		["~"] = goto_home,
		["_"] = goto_cwd,
	},
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

vim.keymap.set("n", "g~", goto_home.callback, { desc = goto_home.desc })
vim.keymap.set("n", "g.", goto_cwd.callback, { desc = goto_cwd.desc })
