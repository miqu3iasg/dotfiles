-- lua/config/keymaps/files.lua

-- Keymaps for managing files and directories.
--
-- See: lua/lib/system.lua
-- See: lua/config/commands.lua

local km = vim.keymap.set

-- TODO: add more colors to the prompt

-- Prompt text, colored by the active colorscheme. Because of `default`, a
-- colorscheme or user config can still override this group.
vim.api.nvim_set_hl(0, "FilesPrompt", { link = "Question", default = true })

---Sentinel returned by `input()` when the prompt is cancelled.
local CANCEL = "\1<cancel>"

---Set a normal-mode keymap, always with a description.
---@param lhs string
---@param rhs string|fun()
---@param desc string
---@param opts? table<string, any> Extra mapping options.
local function map(lhs, rhs, desc, opts)
	km("n", lhs, rhs, vim.tbl_extend("force", { desc = desc }, opts or {}))
end

---Absolute path of the current file, or `nil` with a message when there is none.
---@return string?
local function current_file()
	local file = vim.fn.expand("%:p")
	if file == "" then
		print("Buffer is not visiting a file")
		return nil
	end
	return file
end

---Copy a value to the system clipboard. Empty values are ignored.
---@param value string
local function yank(value)
	if value == "" then
		return
	end
	vim.fn.setreg("+", value)
end

---Map a key that yanks the result of a filename-modifier expression.
---@param lhs string
---@param modifier string Filename modifier expression, such as `%:p:~`.
---@param desc string
---@see :help filename-modifiers
local function yank_map(lhs, modifier, desc)
	map(lhs, function()
		yank(vim.fn.expand(modifier))
	end, desc)
end

---Prompt for a path with file completion. The default is shown abbreviated
---with `~`, and the result is expanded back to an absolute path. The key
---hints are appended to the prompt.
---@param prompt string Prompt text, without a trailing colon.
---@param default string
---@return string? path Absolute path, `""` when empty, or `nil` when cancelled.
local function read_path(prompt, default)
	vim.cmd("echohl FilesPrompt")
	local ok, result = pcall(vim.fn.input, {
		prompt = prompt .. " (Enter accept, TAB complete, C-c quit): ",
		default = vim.fn.fnamemodify(default, ":~"),
		completion = "file",
		cancelreturn = CANCEL,
	})
	vim.cmd("echohl None")
	vim.cmd("redraw")

	if not ok or result == CANCEL then
		print("Quit")
		return nil
	end
	if result == "" then
		return ""
	end
	return vim.fn.fnamemodify(vim.fn.expand(result), ":p")
end

---Ask a yes/no question on the command line, with the accepted keys shown.
---`y`/`<Space>` accept, `n`/`<BS>`/`<Del>` refuse, `<C-c>`/`<Esc>` cancel.
---@param prompt string Question text, without the key hints.
---@return boolean? answer `nil` when cancelled.
local function confirm_action(prompt)
	local keys = " (y/Space yes, n/DEL no, C-c/ESC quit) "
	local notice = ""
	while true do
		vim.cmd("redraw")
		vim.api.nvim_echo({ { notice .. prompt, "FilesPrompt" }, { keys, "Comment" } }, false, {})
		local ok, key = pcall(vim.fn.getcharstr)

		if ok and (key == "y" or key == "Y" or key == " ") then
			vim.cmd("redraw")
			return true
		elseif ok and (key == "n" or key == "N" or key == vim.keycode("<BS>") or key == vim.keycode("<Del>")) then
			vim.cmd("redraw")
			return false
		elseif not ok or key == "\3" or key == "\27" then
			vim.cmd("redraw")
			print("Quit")
			return nil
		end
		notice = "Please answer y or n. "
	end
end

-- Working directory
map("<leader>nw", "<cmd>Setwd<CR>", "Set working directory to current file")

map("<leader>.", function()
	vim.notify("Current directory: " .. vim.fn.getcwd(), vim.log.levels.INFO)
end, "Show current working directory", { silent = true })

-- File operations
map("<leader>nf", function()
	local current_dir = vim.fn.expand("%:p:h")
	if current_dir == "" or current_dir == "." then
		current_dir = vim.fn.getcwd()
	end

	local file = read_path("Find file", current_dir .. "/")
	if not file or file == "" then
		return
	end

	local dir = vim.fn.fnamemodify(file, ":h")
	if vim.fn.isdirectory(dir) == 0 then
		if not confirm_action("Directory " .. vim.fn.fnamemodify(dir, ":~") .. " does not exist; create?") then
			return
		end
		vim.fn.mkdir(dir, "p")
	end

	-- `:edit` on a missing path only opens an unsaved buffer, so create it first.
	if vim.fn.filereadable(file) == 0 and vim.fn.isdirectory(file) == 0 then
		if vim.fn.writefile({}, file) ~= 0 then
			vim.notify("Failed to create: " .. file, vim.log.levels.ERROR)
			return
		end
		print("Wrote " .. vim.fn.fnamemodify(file, ":~"))
	end
	vim.cmd("edit " .. vim.fn.fnameescape(file))
end, "Find or create new file")

map("<leader>nr", function()
	local old = current_file()
	if not old then
		return
	end

	local new = read_path("Rename file " .. vim.fn.fnamemodify(old, ":t") .. " to", old)
	if not new or new == "" or new == old then
		return
	end

	vim.cmd("saveas " .. vim.fn.fnameescape(new))
	vim.fn.delete(old)
	vim.cmd("bd " .. vim.fn.bufnr(old))
	print("Renamed to " .. vim.fn.fnamemodify(new, ":~"))
end, "Rename current file")

-- Deletes the file permanently, after confirmation.
map("<leader>nk", function()
	local file = current_file()
	if not file then
		return
	end

	if not confirm_action("Delete " .. vim.fn.fnamemodify(file, ":t") .. "?") then
		return
	end

	if vim.fn.delete(file) ~= 0 then
		vim.notify("Failed to delete: " .. file, vim.log.levels.ERROR)
		return
	end
	vim.cmd("bd!")
	print("Deleted " .. vim.fn.fnamemodify(file, ":~"))
end, "Delete current file")

map("<leader>nx", function()
	local file = current_file()
	if not file then
		return
	end

	local is_exec = vim.fn.executable(file) == 1
	vim.fn.system({ "chmod", is_exec and "-x" or "+x", file })
	print((is_exec and "Removed" or "Added") .. " executable permission: " .. file)
end, "Toggle executable permission on current file")

map("<leader>ne", function()
	local file = current_file()
	if not file then
		return
	end

	local os_name = require("lib.system").get_os()
	if os_name == "mac" then
		vim.fn.system({ "open", "-R", file })
	elseif os_name == "windows" then
		-- explorer.exe parses the raw command line and needs backslashes, so
		-- this goes through cmd.exe with a plain string instead of an argv list.
		local win_path = file:gsub("/", "\\")
		os.execute(string.format('start "" explorer.exe /select,"%s"', win_path))
	else
		-- xdg-open cannot select a file, so it opens the containing folder.
		vim.fn.system({ "xdg-open", vim.fn.fnamemodify(file, ":h") })
	end
end, "Reveal current file in file explorer")

-- Yank paths
yank_map("<leader>yp", "%:p", "Yank absolute file path")
yank_map("<leader>yr", "%:.", "Yank relative file path")
yank_map("<leader>yn", "%:t", "Yank file name")
yank_map("<leader>yd", "%:p:h", "Yank containing directory path")

map("<leader>yl", function()
	local path = vim.fn.expand("%:.")
	if path == "" then
		return
	end
	yank(path .. ":" .. vim.fn.line("."))
end, "Yank file:line reference")
