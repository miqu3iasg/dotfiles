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
---installed. With ripgrep, `grepprg` is left to `config/options.lua`, and the
---default `grepformat` already understands `--vimgrep` output.
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

---Run `:grep` in the project. The quickfix window opens by itself through the
---`QuickFixCmdPost` autocmd; this only warns when nothing matched. The pattern
---is shell-escaped, so it is safe to pass raw user input.
---@param pattern string
---@param flags? string Extra flags for the grep program, such as `-F -w`.
function M.grep(pattern, flags)
	if pattern == "" then
		return
	end

	vim.cmd(("silent grep! %s -- %s"):format(flags or "", vim.fn.shellescape(pattern, true)))
	vim.cmd("redraw!")

	if #vim.fn.getqflist() == 0 then
		vim.notify("No matches for: " .. pattern, vim.log.levels.WARN)
	end
end

---Run `:lvimgrep` on the current buffer and open the location list when there
---are results. The pattern is a Vim regex, matched as-is.
---@param pattern string
function M.buffer_grep(pattern)
	if pattern == "" then
		return
	end

	local ok = pcall(vim.cmd, ("lvimgrep /%s/j %%"):format(vim.fn.escape(pattern, "/")))
	if ok and #vim.fn.getloclist(0) > 0 then
		vim.cmd("lopen")
	else
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

	local ok = pcall(vim.cmd, ("silent vimgrep! /%s/j **/*"):format(vim.fn.escape(pattern, "/")))
	if not ok or #vim.fn.getqflist() == 0 then
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
