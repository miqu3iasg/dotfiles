-- lua/lib/autoformat.lua

-- Single source of truth for the autoformat-on-save state. Readers and callers
-- go through this module, never the variables.
--
-- Formatting runs only when neither `g:disable_autoformat` nor
-- `b:disable_autoformat` is set.
--
-- See: doc/lib.txt

local M = {}

---Check whether autoformat is enabled for `bufnr`.
---@param bufnr? integer Defaults to the current buffer.
---@return boolean enabled
function M.enabled(bufnr)
	bufnr = bufnr or 0
	return not (vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat)
end

---Disable autoformat globally.
function M.disable()
	vim.g.disable_autoformat = true
end

---Enable autoformat globally and clear the override of the current buffer.
function M.enable()
	vim.b.disable_autoformat = false
	vim.g.disable_autoformat = false
end

---Toggle the global state and notify the new one.
function M.toggle()
	if vim.g.disable_autoformat then
		M.enable()
	else
		M.disable()
	end
	vim.notify("Autoformat: " .. (vim.g.disable_autoformat and "OFF" or "ON"))
end

---Toggle buffer-local autoformat state.
---@param bufnr? integer Defaults to current buffer.
---@return boolean enabled New buffer-local state.
function M.toggle_buffer(bufnr)
	bufnr = bufnr or 0
	vim.b[bufnr].disable_autoformat = not vim.b[bufnr].disable_autoformat
	vim.notify("Buffer autoformat: " .. (vim.b[bufnr].disable_autoformat and "OFF" or "ON"))
	return not vim.b[bufnr].disable_autoformat
end

return M
