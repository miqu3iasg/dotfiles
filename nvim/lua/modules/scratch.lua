-- lua/modules/scratch.lua

-- A persistent scratch buffer for throwaway notes and pastes. `M.toggle()`
-- opens it in a vertical split or closes its window, and the content survives
-- every close and toggle: the buffer is hidden, not wiped, and lasts until the
-- session ends or `:Scratch!` deletes it.
--
-- The buffer is unnamed in the buffer list (`buflisted` off), has no filetype
-- and no swapfile, and is displayed with the virtual name `scratch://_*scratch*_`. Inside its
-- window, `q` and `<Esc>` close the window without losing the content.
--
-- The command is registered by `setup()`, which must be called once at
-- startup; the keymap lives in `config/keymaps/buffers.lua`.
--
-- See: lua/config/keymaps/buffers.lua

local M = {}

---The scratch buffer, or nil while it does not exist.
---@type integer?
local bufnr

---Create the scratch buffer and its buffer-local close mappings.
local function create()
	bufnr = vim.api.nvim_create_buf(false, false)
	-- A `scratch://` name, like `oil://` and `fugitive://`, so the buffer is
	-- never mistaken for a real file under the working directory.
	vim.api.nvim_buf_set_name(bufnr, "scratch://_*scratch*_")
	vim.bo[bufnr].buftype = "nofile" -- Nothing to read or write, so no swapfile.
	vim.bo[bufnr].bufhidden = "hide" -- The window can close without wiping it.

	for _, key in ipairs({ "q", "<Esc>" }) do
		vim.keymap.set("n", key, "<cmd>close<cr>", {
			buffer = bufnr,
			silent = true,
			nowait = true,
			desc = "Close scratch window",
		})
	end
end

---Delete the scratch buffer and forget it. The next toggle creates a fresh one.
function M.wipe()
	if bufnr == nil then
		return
	end
	local id = bufnr
	bufnr = nil
	if vim.api.nvim_buf_is_valid(id) then
		vim.api.nvim_buf_delete(id, { force = true })
	end
end

---Show the scratch buffer in a vertical split, focus its window when it is
---already visible, or close its window when the cursor is inside it.
function M.toggle()
	if bufnr ~= nil and vim.api.nvim_buf_is_valid(bufnr) then
		if vim.api.nvim_get_current_buf() == bufnr then
			vim.cmd.close()
			return
		end
		for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
			if vim.api.nvim_win_get_buf(win) == bufnr then
				vim.api.nvim_set_current_win(win)
				return
			end
		end
	else
		bufnr = nil
		create()
	end

	vim.cmd.vsplit()
	vim.api.nvim_win_set_buf(0, bufnr)
end

---Register the `:Scratch` command. `:Scratch!` wipes the buffer instead.
function M.setup()
	vim.api.nvim_create_user_command("Scratch", function(o)
		if o.bang then
			M.wipe()
		else
			M.toggle()
		end
	end, {
		bang = true,
		desc = "Toggle the persistent scratch buffer, or wipe it with :Scratch!",
	})
end

return M
