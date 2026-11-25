-- lua/config/keymaps/command_mode.lua

-- Command-mode keymaps. `;` enters command mode and `:` repeats character
-- searches.
--
-- See: :help map.txt

local km = vim.keymap.set

km({ "n", "v" }, ";", ":", { desc = "Enter command mode" })

km({ "n", "x", "o" }, ":", ";", {
	desc = "Repeat last f/t/F/T motion (swap)",
})

km({ "n", "x", "o" }, "\\", ";", {
	desc = "Repeat last f/t/F/T motion (alt)",
})

km("c", "<C-a>", "<Home>", { desc = "Go to beginning of command" })
km("c", "<C-e>", "<End>", { desc = "Go to end of command" })
km("c", "<C-b>", "<Left>", { desc = "Move char backward" })
km("c", "<C-f>", "<Right>", { desc = "Move char forward" })
km("c", "<C-h>", "<S-Left>", { desc = "Move word backward" })
km("c", "<C-l>", "<S-Right>", { desc = "Move word forward" })

-- Keeps the native `<C-f>` behavior, which opens the command-line window,
-- since `<C-f>` above moves one character forward.
km(
	"c",
	"<C-o>",
	function() vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-f>", true, false, true), "n", true) end,
	{ desc = "Open command-line window" }
)

-- With the completion menu open, `/` accepts the selected entry and lets you
-- keep going down the path, level by level.
km(
	"c",
	"/",
	function() return vim.fn.wildmenumode() == 1 and "<C-y>" or "/" end,
	{ expr = true, desc = "Accept completion and keep going down the path" }
)

-- Expands a star typed right after a double star into `/*`, which completes
-- the recursive glob that `:find` and `:edit` accept.
km("c", "*", function()
	local before = vim.fn.getcmdline():sub(1, vim.fn.getcmdpos() - 1)
	return before:match("%*%*$") and "/*" or "*"
end, { expr = true, desc = "Third * in a row becomes **/*" })
