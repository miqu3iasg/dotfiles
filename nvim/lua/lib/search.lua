-- lua/lib/search.lua

-- Project and buffer search through `:grep`, `:vimgrep` and `:lvimgrep`, and
-- actions on every match of the last search pattern. Call `setup()` once,
-- then use the other functions from keymaps.
--
-- See: doc/lib.txt
-- See: lua/config/keymaps/search.lua
-- See: lua/config/autocmds.lua
-- See: :help matchbufline()

local M = {}

---Configure the fallback `grepprg` and `grepformat` for when ripgrep is missing.
function M.setup()
	if vim.fn.executable("rg") ~= 1 then
		vim.o.grepprg = "grep -rIn --exclude-dir=.git $* ."
		vim.o.grepformat = "%f:%l:%m"
	end
end

---Get the text of the current visual selection. Must be called while still in
---visual mode, since it reads the mode and the `v` mark.
---@return string
function M.get_selection()
	local region = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = vim.fn.mode() })
	return table.concat(region, "\n")
end

---Run a full `:grep`-style command line, emptying the list first because a
---failed command would keep the previous one.
---@param command string Command line passed to `:silent`, such as `grep! -w -- foo`.
---@param label string Pattern shown in the no-match notification.
function M.run(command, label)
	vim.fn.setqflist({}, " ")
	vim.cmd(("silent %s"):format(command))
	vim.cmd("redraw!")

	if #vim.fn.getqflist() == 0 then
		-- An empty list does not close the window by itself, so a no-match
		-- leaves behind a useless empty window otherwise.
		vim.cmd("cclose")
		vim.notify("No matches for: " .. label, vim.log.levels.WARN)
	end
end

---Run `:grep` in the project for `pattern`, which is shell-escaped, so it is
---safe to pass raw user input.
---@param pattern string
---@param flags? string Extra flags for the grep program, such as `-F -w`.
function M.grep(pattern, flags)
	if pattern == "" then
		return
	end

	M.run(("grep! %s -- %s"):format(flags or "", vim.fn.shellescape(pattern, true)), pattern)
end

---Run `:lvimgrep` on the current buffer and open the location list when there
---are results. The pattern is a Vim regex, matched as-is.
---@param pattern string
function M.buffer_grep(pattern)
	if pattern == "" then
		return
	end

	-- A failed command keeps the previous list, so it is emptied first.
	vim.fn.setloclist(0, {}, " ")
	local ok = pcall(vim.cmd, ("lvimgrep /%s/j %%"):format(vim.fn.escape(pattern, "/")))
	if ok and #vim.fn.getloclist(0) > 0 then
		vim.cmd("lopen")
	else
		vim.cmd("lclose")
		vim.notify("No matches for: " .. pattern, vim.log.levels.WARN)
	end
end

---Run `:vimgrep` in the project, which works even without ripgrep installed.
---@param pattern string
function M.vimgrep(pattern)
	if pattern == "" then
		return
	end

	-- A failed command keeps the previous list, so it is emptied first.
	vim.fn.setqflist({}, " ")
	local ok = pcall(vim.cmd, ("silent vimgrep! /%s/j **/*"):format(vim.fn.escape(pattern, "/")))
	if not ok or #vim.fn.getqflist() == 0 then
		vim.cmd("cclose")
		vim.notify("No matches for: " .. pattern, vim.log.levels.WARN)
	end
end

---Return the last search pattern, notifying when there is none
---@return string|nil pattern
local function last_pattern()
	local pat = vim.fn.getreg("/")
	if pat == "" then
		vim.notify("No previous search pattern", vim.log.levels.WARN)
		return nil
	end
	return pat
end

---Prefix a pattern with a case flag, so `matchbufline()` follows 'smartcase'
---the way a search does, since the function itself ignores it
---@param pat string
---@return string
local function with_case(pat)
	if pat:find("\\[cC]") then
		return pat
	end
	-- Uppercase letters after a backslash, such as `\S`, do not count.
	local bare = pat:gsub("\\.", "")
	if vim.o.ignorecase and not (vim.o.smartcase and bare:find("%u")) then
		return "\\c" .. pat
	end
	return "\\C" .. pat
end

---Yank every match of the last search pattern into a register, one per line
---Matches that span more than one line are not supported
---@param reg? string Register name, `"` by default.
function M.yank_matches(reg)
	local pat = last_pattern()
	if not pat then
		return
	end

	local found = vim.fn.matchbufline(vim.api.nvim_get_current_buf(), with_case(pat), 1, "$")
	if #found == 0 then
		vim.notify("No matches", vim.log.levels.WARN)
		return
	end

	local texts = vim.tbl_map(function(m)
		return m.text
	end, found)
	vim.fn.setreg(reg or '"', texts, "l")
	vim.notify(("Yanked %d matches"):format(#texts))
end

---Delete every match of the last search pattern in the buffer, keeping the
---cursor, the jumplist and the search pattern untouched
function M.delete_matches()
	if not last_pattern() then
		return
	end

	local view = vim.fn.winsaveview()
	-- An empty pattern in `:s` means the last search pattern.
	local ok, err = pcall(vim.cmd, "keeppatterns keepjumps %s///ge")
	vim.fn.winrestview(view)

	if not ok then
		vim.notify(tostring(err), vim.log.levels.ERROR)
	end
end

return M
