-- lua/config/keymaps/search.lua

-- Keymaps for scrolling, search navigation, search highlights and quickfix
-- navigation. Most of them recenter the cursor after moving.
--
-- See: lua/features/compile.lua
-- See: lua/features/todos.lua

local km = vim.keymap.set

--- Temporarily highlights `positions` as a visual reference, without searching
--- or affecting the search register or `hlsearch`.
---@param positions (integer|integer[])[] Positions in the `matchaddpos()`
---format: a line number, `{ line, col, len }`, etc.
---@param ms? integer Duration in milliseconds
local function flash(positions, ms)
	local win = vim.api.nvim_get_current_win()
	local id = vim.fn.matchaddpos("Visual", positions)

	vim.defer_fn(function()
		pcall(vim.fn.matchdelete, id, win)
	end, ms or 400)
end

-- Scroll
km("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center cursor" })
km("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center cursor" })
km("n", "<C-f>", "<C-f>zz", { desc = "Page down and center cursor" })
km("n", "<C-b>", "<C-b>zz", { desc = "Page up and center cursor" })

-- Search results
km("n", "n", "nzzzv", { desc = "Next search result, center cursor and open fold" })
km("n", "N", "Nzzzv", { desc = "Previous search result, center cursor and open fold" })
km("n", "*", "*zzzv", { desc = "Search word forward and center cursor" })
km("n", "#", "#zzzv", { desc = "Search word backward and center cursor" })
km("n", "g*", "g*zzzv", { desc = "Search partial word forward and center cursor" })
km("n", "g#", "g#zzzv", { desc = "Search partial word backward and center cursor" })
km("n", "}", "}zz", { desc = "Jump to next paragraph and center cursor" })
km("n", "{", "{zz", { desc = "Jump to previous paragraph and center cursor" })

-- Search selection
km("v", "*", [[y/\V<C-r>=escape(@", '/\')<CR><CR>]], { desc = "Search selection forward" })
km("v", "#", [[y?\V<C-r>=escape(@", '/\')<CR><CR>]], { desc = "Search selection backward" })

-- Search word
km("n", "<leader>sw", function()
	local word = vim.fn.escape(vim.fn.expand("<cword>"), "\\/.*$^~[]")

	vim.fn.setreg("/", [[\<]] .. word .. [[\>]])
	vim.o.hlsearch = true
end, { desc = "Search word under cursor" })

-- Highlights
km("n", "<leader>hw", function()
	local lnum, col = vim.fn.line("."), vim.fn.col(".")
	local _, s, e = unpack(vim.fn.matchstrpos(vim.fn.getline("."), [[\k*\%]] .. col .. [[c\k\+]]))
	if s < 0 then
		return
	end
	flash({ { lnum, s + 1, e - s } })
end, { desc = "Flash word under cursor" })

km("n", "<leader>hl", function()
	flash({ vim.fn.line(".") })
end, { desc = "Flash current line" })

km("n", "zh", function()
	vim.cmd("match none")
	vim.cmd("nohlsearch")
end, {
	desc = "Clear search highlights",
})

km("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlights" })

-- Quickfix
km("n", "]q", "<cmd>cnext<cr>zz", { desc = "Next quickfix item" })
km("n", "[q", "<cmd>cprev<cr>zz", { desc = "Previous quickfix item" })
km("n", "]Q", "<cmd>clast<cr>", { desc = "Last quickfix item" })
km("n", "[Q", "<cmd>cfirst<cr>", { desc = "First quickfix item" })
