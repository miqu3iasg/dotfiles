-- lua/config/keymaps/marks.lua

-- Explicit, described alternatives to the native mark motions.
--
-- See: :help mark-motions

local km = vim.keymap.set

-- Explicitly expose the native mapping for discoverability and consistency
km("n", "m", "m", { desc = "Set mark" })

km({ "n", "v", "o" }, "gm", "`", { desc = "Jump to mark (exact position)" })
km({ "n", "v", "o" }, "gM", "'", { desc = "Jump to mark (start of line)" })

-- Delete a named mark using the `dm{a-zA-Z}` convention
km("n", "dm", function()
	local ok, char = pcall(vim.fn.getcharstr)

	if ok and char:match("^%a$") then
		pcall(vim.cmd.delmarks, char)
	end
end, { desc = "Delete mark" })

-- Delete all lowercase marks in the current buffer
km("n", "<leader>dm", "<cmd>silent! delmarks!<CR>", { desc = "Delete all marks in buffer" })
