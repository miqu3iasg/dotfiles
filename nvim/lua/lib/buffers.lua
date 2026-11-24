-- lua/lib/buffers.lua

-- Buffer inspection, saving and deletion that keep the window layout intact.
--
-- See: doc/lib.md

local M = {}

---Check whether `buf` is a terminal buffer.
---@param buf integer
---@return boolean
function M.is_terminal(buf)
	return vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "terminal"
end

---Check whether `win` is a regular window instead of a floating one.
---@param win integer
---@return boolean
function M.is_normal_window(win)
	return vim.api.nvim_win_get_config(win).relative == ""
end

---Save `buf` when it has changes and a real file name, and report whether it
---is safe to delete. Special, unnamed and unsaved buffers are not.
---@param buf? integer Defaults to the current buffer.
---@return boolean safe
function M.save_if_modified(buf)
	buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf

	if M.is_terminal(buf) or not vim.bo[buf].modified then
		return true
	end
	if vim.bo[buf].buftype ~= "" or vim.api.nvim_buf_get_name(buf) == "" then
		return false
	end

	vim.api.nvim_buf_call(buf, function()
		pcall(vim.cmd, "silent! update")
	end)
	return not vim.bo[buf].modified
end

---Delete `buf`, forcing terminals and keeping modified buffers.
---@param buf integer
---@return boolean ok
---@return string? err
function M.delete(buf)
	return pcall(vim.api.nvim_buf_delete, buf, { force = M.is_terminal(buf) })
end

---Return the most recently used listed buffer other than `buf`.
---@param buf integer
---@return integer?
function M.pick_replacement(buf)
	local best
	for _, info in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
		if info.bufnr ~= buf and (not best or info.lastused > best.lastused) then
			best = info
		end
	end
	return best and best.bufnr
end

---Delete `buf` and point every window that showed it at a replacement buffer.
---@param buf integer
---@return boolean ok
---@return string? err
function M.delete_keep_layout(buf)
	local wins = vim.fn.win_findbuf(buf)
	if #wins > 0 then
		local repl = M.pick_replacement(buf) or vim.api.nvim_create_buf(true, false)
		for _, win in ipairs(wins) do
			vim.api.nvim_win_set_buf(win, repl)
		end
	end
	return M.delete(buf)
end

---Save and delete every listed buffer that passes `filter` and warn about the
---ones kept because their save failed.
---@param filter? fun(info: table): boolean Receives a `getbufinfo()` entry. When omitted, every listed buffer matches.
function M.delete_where(filter)
	local kept = 0
	for _, info in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
		if not filter or filter(info) then
			if M.save_if_modified(info.bufnr) then
				M.delete(info.bufnr)
			else
				kept = kept + 1
			end
		end
	end
	if kept > 0 then
		vim.notify(kept .. " buffer(s) could not be saved, kept", vim.log.levels.WARN)
	end
end

return M
