-- lua/config/keymaps/windows.lua

-- Keymaps to navigate, move, split, resize and zoom windows.

local km = vim.keymap.set

-- Navigate
km("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
km("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
km("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })
km("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Move
km("n", "<leader>mh", "<C-w>H", { desc = "Move window to far left" })
km("n", "<leader>mj", "<C-w>J", { desc = "Move window to bottom" })
km("n", "<leader>mk", "<C-w>K", { desc = "Move window to top" })
km("n", "<leader>ml", "<C-w>L", { desc = "Move window to far right" })

-- Swap and rotate
km("n", "<leader>mx", "<C-w>x", { desc = "Swap window with next" })
km("n", "<leader>mr", "<C-w>r", { desc = "Rotate windows" })

-- Split and close
km("n", "<leader>sv", "<cmd>vsplit<CR>", { desc = "Split window vertically" })
km("n", "<leader>sh", "<cmd>split<CR>", { desc = "Split window horizontally" })
km("n", "<leader>se", "<C-w>=", { desc = "Equalize window sizes" })
km("n", "<leader>sc", "<cmd>close<CR>", { desc = "Close current window" })
km("n", "<leader>so", "<cmd>only<CR>", { desc = "Close other windows" })

-- Resize
km("n", "+", "<cmd>resize +5<cr>", { desc = "Increase window height" })
km("n", "_", "<cmd>resize -5<cr>", { desc = "Decrease window height" })
km("n", "=", "<cmd>vertical resize +5<cr>", { desc = "Increase window width" })
km("n", "-", "<cmd>vertical resize -5<cr>", { desc = "Decrease window width" })

-- Zoom
-- See: lua/features/window_zoom.lua
km("n", "<leader>sm", function()
	require("features.window_zoom").toggle()
end, { desc = "Toggle window zoom" })
