-- lua/config/keymaps/files.lua

-- File and directory keymaps.
--
-- See: lua/lib/system.lua
-- See: lua/config/commands.lua
-- See: lua/config/options.lua
-- See: :help map.txt

local keys = require("lib.keys")
local map = keys.map

-- Prompt text, colored by the active colorscheme. Because of `default`, a
-- colorscheme or user config can still override this group.
vim.api.nvim_set_hl(0, "FilesPrompt", { link = "Question", default = true })

-- The completion menu of a prompt is a plain list with a reverse-video
-- selection, the way the Emacs minibuffer lists its completions.
---@type table<string, table>?
local pum_faces

---Replace the popup menu faces with plain ones, then restore them
---@param plain boolean
local function plain_pum(plain)
	if plain and not pum_faces then
		pum_faces = {
			Pmenu = vim.api.nvim_get_hl(0, { name = "Pmenu" }),
			PmenuSel = vim.api.nvim_get_hl(0, { name = "PmenuSel" }),
		}
		vim.api.nvim_set_hl(0, "Pmenu", { link = "Normal" })
		vim.api.nvim_set_hl(0, "PmenuSel", { reverse = true })
	elseif pum_faces then
		for name, attrs in pairs(pum_faces) do
			vim.api.nvim_set_hl(0, name, attrs)
		end
		pum_faces = nil
	end
end

vim.api.nvim_create_autocmd({ "CmdlineEnter", "CmdlineLeave" }, {
	pattern = "@",
	callback = function(ev)
		plain_pum(ev.event == "CmdlineEnter")
	end,
})

---Sentinel returned by `input()` when the prompt is cancelled
local CANCEL = "\1<cancel>"

---Return the absolute path of the current file, or `nil` with a message when
---the buffer is not visiting one
---@return string? path
local function current_file()
	if vim.bo.buftype ~= "" then
		vim.notify("Not a file buffer: " .. vim.bo.buftype, vim.log.levels.WARN)
		return nil
	end
	local file = vim.api.nvim_buf_get_name(0)
	if file == "" then
		vim.notify("Buffer is not visiting a file", vim.log.levels.WARN)
		return nil
	end
	return file
end

---Copy a value to the system clipboard, ignoring empty values
---@param value string
local function yank(value)
	if value == "" then
		return
	end
	vim.fn.setreg("+", value)
end

---Map a key that yanks the result of a filename-modifier expression
---@param lhs string
---@param modifier string Filename modifier expression, such as `%:p:~`
---@param desc string
--- See: :help filename-modifiers
local function yank_map(lhs, modifier, desc)
	map("n", lhs, function()
		yank(vim.fn.expand(modifier))
	end, desc)
end

---Resolve a typed path against the directory the prompt started in
---@param path string
---@param base string
---@return string resolved
local function resolve(path, base)
	if path:match("^[/~$]") or path:match("^%a:[/\\]") then
		return vim.fn.fnamemodify(vim.fn.expand(path), ":p")
	end
	return vim.fn.fnamemodify(vim.fn.expand(vim.fs.joinpath(base, path)), ":p")
end

---Return the directory the prompt starts in, which is the current file's
---directory, or the cwd for a buffer that is not visiting a file
---@return string dir
local function base_dir()
	if vim.bo.buftype == "" then
		local name = vim.api.nvim_buf_get_name(0)
		if name ~= "" then
			return vim.fs.dirname(name)
		end
	end
	return vim.fn.getcwd()
end

---Prompt for a path with file completion, returned absolute, resolving
---relative paths against the directory of `default`
---@param prompt string Prompt text, without a trailing colon
---@param default string Pre-filled text, base for relative paths
---@return string? path Absolute path, `""` when empty, `nil` on cancel
local function read_path(prompt, default)
	vim.cmd("echohl FilesPrompt")
	local ok, result = pcall(vim.fn.input, {
		prompt = prompt .. ": ",
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
	return resolve(result, vim.fn.fnamemodify(default, ":h"))
end

---Ask a yes/no question on the command line, defaulting to no
---@param question string
---@return boolean accepted
local function confirm(question)
	return vim.fn.confirm(question, "&Yes\n&No", 2) == 1
end

---Offer to create a missing directory and report whether it is usable
---@param dir string
---@return boolean usable
local function ensure_dir(dir)
	if vim.fn.isdirectory(dir) == 1 then
		return true
	end
	local name = vim.fn.fnamemodify(dir, ":~")
	if not confirm("Directory " .. name .. " does not exist; create?") then
		return false
	end
	if vim.fn.mkdir(dir, "p") == 0 then
		vim.notify("Failed to create directory: " .. dir, vim.log.levels.ERROR)
		return false
	end
	return true
end

---Show the current working directory
local function show_cwd()
	vim.notify("Current directory: " .. vim.fn.getcwd(), vim.log.levels.INFO)
end

---Prompt for a path and open it, offering to create a missing directory
local function find_or_create_file()
	local file = read_path("Find file", base_dir() .. "/")
	if not file or file == "" then
		return
	end

	local dir = vim.fn.fnamemodify(file, ":h")
	if not ensure_dir(dir) then
		return
	end

	-- Create the file first, so the buffer never stays an unsaved `[New]`
	-- one that is lost when it is abandoned.
	if vim.fn.filereadable(file) == 0 and vim.fn.isdirectory(file) == 0 then
		if vim.fn.writefile({}, file) ~= 0 then
			vim.notify("Failed to create: " .. file, vim.log.levels.ERROR)
			return
		end
	end
	vim.cmd("edit " .. vim.fn.fnameescape(file))
end

---Rename the current file, offering to create the target directory
local function rename_file()
	local old = current_file()
	if not old then
		return
	end

	local new = read_path("Rename file " .. vim.fn.fnamemodify(old, ":t") .. " to", old)
	if not new or new == "" or new == old then
		return
	end
	if vim.fn.isdirectory(new) == 1 then
		vim.notify("Target is a directory: " .. new, vim.log.levels.ERROR)
		return
	end

	-- `:saveas` cannot create the target directory, so it is offered
	-- here, like the new file flow does.
	if not ensure_dir(vim.fn.fnamemodify(new, ":h")) then
		return
	end

	local bang = ""
	if vim.fn.filereadable(new) == 1 then
		if not confirm("Overwrite " .. vim.fn.fnamemodify(new, ":~") .. "?") then
			return
		end
		bang = "!"
	end

	-- `:saveas` keeps the current buffer and its undo, and leaves an
	-- empty buffer for the old path, which is removed below.
	if not pcall(vim.cmd, "saveas" .. bang .. " " .. vim.fn.fnameescape(new)) then
		vim.notify("Failed to rename to: " .. new, vim.log.levels.ERROR)
		return
	end
	if vim.fn.delete(old) ~= 0 then
		vim.notify("Renamed, but the old file remains: " .. old, vim.log.levels.ERROR)
		return
	end
	pcall(vim.cmd, "bd " .. vim.fn.bufnr(old))
	print("Renamed to " .. vim.fn.fnamemodify(new, ":~"))
end

---Delete the current file permanently, after confirmation
local function delete_file()
	local file = current_file()
	if not file then
		return
	end

	local lost = vim.bo.modified and " Unsaved changes will be lost." or ""
	if not confirm("Delete " .. vim.fn.fnamemodify(file, ":t") .. "?" .. lost) then
		return
	end

	if vim.fn.delete(file) ~= 0 then
		vim.notify("Failed to delete: " .. file, vim.log.levels.ERROR)
		return
	end
	vim.cmd("bd!")
	print("Deleted " .. vim.fn.fnamemodify(file, ":~"))
end

---Toggle the executable permission on the current file
local function toggle_executable()
	local file = current_file()
	if not file then
		return
	end

	local is_exec = vim.fn.executable(file) == 1
	local result = vim.system({ "chmod", is_exec and "-x" or "+x", file }):wait()
	if result.code ~= 0 then
		vim.notify("chmod failed: " .. (result.stderr or ""), vim.log.levels.ERROR)
		return
	end
	print((is_exec and "Removed" or "Added") .. " executable permission: " .. file)
end

---Reveal the current file in the system file explorer
local function reveal_in_explorer()
	local file = current_file()
	if not file then
		return
	end

	local os_name = require("lib.system").get_os()
	if os_name == "mac" then
		vim.fn.system({ "open", "-R", file })
	elseif os_name == "windows" then
		-- `explorer.exe` parses the raw command line and needs
		-- backslashes, so this goes through `cmd.exe` with a plain
		-- string instead of an argv list.
		local win_path = file:gsub("/", "\\")
		os.execute(string.format('start "" explorer.exe /select,"%s"', win_path))
	else
		-- `xdg-open` cannot select a file, so it opens the
		-- containing folder.
		vim.fn.system({ "xdg-open", vim.fn.fnamemodify(file, ":h") })
	end
end

---Yank the path and the cursor line of the current file as a reference
local function yank_file_line()
	local path = vim.fn.expand("%:.")
	if path == "" then
		return
	end
	yank(path .. ":" .. vim.fn.line("."))
end

map("n", "<leader>wd", "<cmd>Setwd<CR>", "Set working directory to current file")
map("n", "<leader>.", show_cwd, "Show current working directory", { silent = true })

map("n", "<leader>nf", find_or_create_file, "Find or create new file")
map("n", "<leader>nr", rename_file, "Rename current file")
map("n", "<leader>nd", delete_file, "Delete current file")
map("n", "<leader>nx", toggle_executable, "Toggle executable permission on current file")
map("n", "<leader>ne", reveal_in_explorer, "Reveal current file in file explorer")

yank_map("<leader>yp", "%:p", "Yank absolute file path")
yank_map("<leader>yr", "%:.", "Yank relative file path")
yank_map("<leader>yn", "%:t", "Yank file name")
yank_map("<leader>yd", "%:p:h", "Yank containing directory path")

map("n", "<leader>yl", yank_file_line, "Yank file and line reference")
