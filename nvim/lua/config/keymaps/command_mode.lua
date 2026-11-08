-- lua/config/keymaps/command_mode.lua

-- Keymaps for command mode. The native `:` is repurposed to repeat character
-- searches.

local km = vim.keymap.set

-- Enter command mode
km({ "n", "v" }, ";", ":", { desc = "Enter command mode" })

-- Repeat character search
km({ "n", "x", "o" }, ":", ";", {
	desc = "Repeat last f/t/F/T motion (swap)",
})

km({ "n", "x", "o" }, "\\", ";", {
	desc = "Repeat last f/t/F/T motion (alt)",
})

-- Command-line editing
km("c", "<C-a>", "<Home>", { desc = "Go to beginning of command" })
km("c", "<C-e>", "<End>", { desc = "Go to end of command" })
km("c", "<C-b>", "<Left>", { desc = "Move char backward" })
km("c", "<C-f>", "<Right>", { desc = "Move char forward" })
km("c", "<C-h>", "<S-Left>", { desc = "Move word backward" })
km("c", "<C-l>", "<S-Right>", { desc = "Move word forward" })

-- Keeps the native `<C-f>` behavior, which opens the command-line window,
-- since `<C-f>` above moves one character forward.
km("c", "<C-o>", function()
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-f>", true, false, true), "n", true)
end, { desc = "Open command-line window" })
