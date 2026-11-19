-- lua/config/keymaps/buffers.lua

-- Buffer management keymaps.
--
-- See: lua/lib/buffers.lua
-- See: lua/modules/scratch.lua
-- See: :help map.txt

local buffers = require("lib.buffers")

local keys = require("lib.keys")
local map = keys.map

map("n", "<leader>bn", "<cmd>enew<CR>", "New buffer")
map("n", "<leader>bw", "<cmd>write ++p<CR>", "Save buffer")
map("n", "<leader>bs", "<cmd>noautocmd write<CR>", "Save buffer without auto-formatting")

map("n", "<leader>bd", function()
	local buf = vim.api.nvim_get_current_buf()

	if buffers.save_if_modified(buf) then
		buffers.delete_keep_layout(buf)
	else
		vim.notify("Could not save buffer, not deleted", vim.log.levels.WARN)
	end
end, "Save and delete buffer")

map("n", "<leader>bo", function()
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
end, "Close other windows and buffers")

map("n", "]b", "<cmd>bnext<CR>", "Next buffer")
map("n", "[b", "<cmd>bprevious<CR>", "Previous buffer")
map("n", "<leader><Space>", "<C-^>", "Toggle between last two buffers")
