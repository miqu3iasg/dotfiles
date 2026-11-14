-- lua/lib/search.lua

-- Helpers for searching the project and the current buffer using only built-in
-- Neovim features: `:grep` (quickfix), `:vimgrep` (quickfix, Vim regex),
-- `:lvimgrep` (location list) and visual selections. Call `setup()` once to
-- set the fallback grep program for when ripgrep is missing, then use the
-- other functions from keymaps or commands. The quickfix window is opened by
-- a global autocmd, not from here.
--
-- See: lua/config/keymaps/search.lua
-- See: lua/config/autocmds.lua

local M = {}

---Configure the fallback `grepprg` and `grepformat` for when ripgrep is not
---installed. Neovim itself sets `rg --vimgrep -uu` as the default when ripgrep
---is found, and `config/options.lua` narrows that to respect `.gitignore` and
---follow the smartcase rule; this only covers the missing-ripgrep case.
function M.setup()
	if vim.fn.executable("rg") == 1 then
		return
	end

	vim.o.grepprg = "grep -rIn --exclude-dir=.git $* ."
	vim.o.grepformat = "%f:%l:%m"
end

---Get the text of the current visual selection. Must be called while still in
---visual mode, since it reads the mode and the `v` mark.
---@return string
function M.get_selection()
	local region = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = vim.fn.mode() })
	return table.concat(region, "\n")
end

---Run a full `:grep`-style command line and report the result: the quickfix
---window opens through the `QuickFixCmdPost` autocmd, and an empty list
---closes the window again and warns. The list is emptied first, because a
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

---Run `:vimgrep` in the project, which uses Vim's own regex engine and works
---even without ripgrep installed. The quickfix window opens through the
---`QuickFixCmdPost` autocmd; this only warns when nothing matched.
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

---Temporarily highlight `positions` as a visual reference, without searching
---or affecting the search register or `hlsearch`.
---@param positions (integer|integer[])[] Positions in the `matchaddpos()`
---format: a line number, `{ line, col, len }`, etc.
---@param ms? integer Duration in milliseconds.
function M.flash(positions, ms)
	local win = vim.api.nvim_get_current_win()
	local id = vim.fn.matchaddpos("Visual", positions)

	vim.defer_fn(function()
		pcall(vim.fn.matchdelete, id, win)
	end, ms or 400)
end

return M
