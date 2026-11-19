-- lua/modules/scratch.lua

-- A persistent scratch buffer for throwaway notes and pastes. Toggling swaps
-- the buffer of the current window and leaving restores it, so the layout
-- never changes.
--
-- The content survives because the buffer is hidden, not wiped. Special
-- buffers get a vertical split instead of being replaced.
--
-- See: doc/modules.txt
-- See: lua/config/keymaps/buffers.lua

local M = {}

---The scratch buffer, or nil while it does not exist.
---@type integer?
local bufnr

---Whether the scratch buffer exists.
---@return boolean
local function alive()
	return bufnr ~= nil and vim.api.nvim_buf_is_valid(bufnr)
end

---Create the scratch buffer and its buffer-local leave mappings.
---@return integer
local function create()
	local id = vim.api.nvim_create_buf(false, false)
	-- A `scratch://` name, like `oil://` and `fugitive://`, so the buffer is
	-- never mistaken for a real file under the working directory.
	vim.api.nvim_buf_set_name(id, "scratch://_*scratch*_")
	vim.bo[id].buftype = "nofile" -- Nothing to read or write, so no swapfile.
	vim.bo[id].bufhidden = "hide" -- The window can change buffer without wiping it.

	for _, key in ipairs({ "q", "<Esc>" }) do
		vim.keymap.set("n", key, function()
			M.leave()
		end, {
			buffer = id,
			silent = true,
			nowait = true,
			desc = "Scratch: leave",
		})
	end

	return id
end

---The scratch buffer, creating it when it does not exist yet.
---@return integer
local function buffer()
	if not alive() then
		bufnr = create()
	end
	return bufnr
end

---Delete the scratch buffer and forget it. The next toggle creates a fresh one.
function M.wipe()
	if not alive() then
		return
	end
	local id = bufnr
	bufnr = nil
	vim.api.nvim_buf_delete(id, { force = true })
end

---The window that currently shows the scratch buffer, if any.
---@return integer?
local function scratch_win()
	if not alive() then
		return nil
	end
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		if vim.api.nvim_win_get_buf(win) == bufnr then
			return win
		end
	end
end

---Leave the scratch without losing the content. A window opened by `M.split()`
---closes, and a replaced buffer goes back to its previous one.
function M.leave()
	if not alive() or vim.api.nvim_get_current_buf() ~= bufnr then
		return
	end

	local win = vim.api.nvim_get_current_win()
	if vim.w[win].scratch then
		vim.w[win].scratch = nil
		vim.cmd("close")
		return
	end

	local alt = vim.fn.bufnr("#")
	if alt > 0 and alt ~= bufnr and vim.api.nvim_buf_is_valid(alt) and vim.bo[alt].buftype == "" then
		vim.cmd("buffer " .. alt)
	else
		vim.cmd("enew")
	end
end

---Show the scratch buffer in a vertical split, without touching the buffer of
---the current window. Focuses the window that already shows it.
function M.split()
	local win = scratch_win()
	if win then
		vim.api.nvim_set_current_win(win)
		return
	end
	vim.cmd("vsplit")
	vim.w.scratch = true
	vim.api.nvim_win_set_buf(0, buffer())
end

---Replace the buffer of the current window with the scratch, or open it in a
---vertical split when the current buffer is special.
function M.open()
	if vim.bo[0].buftype ~= "" then
		return M.split()
	end
	vim.api.nvim_win_set_buf(0, buffer())
end

---Show the scratch: open it in the current window, focus the window that
---already shows it, or leave it when the cursor is inside it.
function M.toggle()
	if alive() and vim.api.nvim_get_current_buf() == bufnr then
		return M.leave()
	end
	local win = scratch_win()
	if win then
		return vim.api.nvim_set_current_win(win)
	end
	M.open()
end

---Register the commands and the keymaps. `:Scratch!` wipes the buffer.
function M.setup()
	vim.api.nvim_create_user_command("Scratch", function(o)
		if o.bang then
			M.wipe()
		else
			M.toggle()
		end
	end, {
		bang = true,
		desc = "Scratch: toggle the buffer, or wipe it with :Scratch!",
	})

	vim.api.nvim_create_user_command("ScratchSplit", function()
		M.split()
	end, { desc = "Scratch: open the buffer in a vertical split" })

	local km = vim.keymap.set
	km("n", "<leader>bb", M.toggle, { desc = "Scratch: toggle" })
	km("n", "<leader>bv", M.split, { desc = "Scratch: open in vertical split" })
	km("n", "<leader>bq", M.leave, { desc = "Scratch: leave" })
	km("n", "<leader>bx", M.wipe, { desc = "Scratch: wipe buffer" })
end

return M
