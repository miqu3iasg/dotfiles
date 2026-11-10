-- lua/config/keymaps/buffers.lua

-- Keymaps to manage buffers.
--
-- See: lua/lib/buffers.lua

local buffers = require("lib.buffers")

---Set a keymap, silent by default.
---@param mode string|string[]
---@param lhs string
---@param rhs string|fun()
---@param opts? table<string, any> Extra mapping options.
local function km(mode, lhs, rhs, opts)
	opts = vim.tbl_extend("keep", opts or {}, { silent = true })
	vim.keymap.set(mode, lhs, rhs, opts)
end

-- Create and save
km("n", "<leader>bn", "<cmd>enew<CR>", { desc = "New buffer" })
km("n", "<leader>bw", "<cmd>write ++p<CR>", { desc = "Save buffer" })
km("n", "<leader>bs", "<cmd>noautocmd write<CR>", { desc = "Save buffer without auto-formatting" })

-- Close
km("n", "<leader>bd", function()
	local buf = vim.api.nvim_get_current_buf()

	if buffers.save_if_modified(buf) then
		buffers.delete_keep_layout(buf)
	else
		vim.notify("Could not save buffer, not deleted", vim.log.levels.WARN)
	end
end, { desc = "Save and delete buffer" })

km("n", "<leader>bo", function()
	local current_win = vim.api.nvim_get_current_win()
	local current_buf = vim.api.nvim_get_current_buf()

	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		if win ~= current_win and buffers.is_normal_window(win) then
			pcall(vim.api.nvim_win_close, win, true)
		end
	end

	buffers.delete_where(function(info)
		return info.bufnr ~= current_buf
	end)
end, { desc = "Close other windows and buffers" })

-- Navigate
km("n", "]b", "<cmd>bnext<CR>", { desc = "Next buffer" })
km("n", "[b", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
km("n", "<leader><Space>", "<C-^>", { desc = "Toggle between last two buffers" })

-- Scratch
km("n", "<leader>bS", "<cmd>Scratch<CR>", { desc = "Toggle scratch buffer" })
