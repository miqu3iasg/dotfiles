-- lua/config/keymaps/search.lua

-- Keymaps for scrolling, search navigation, search highlights and project
-- search. Most of them recenter the cursor after moving.
-- Project search uses only built-in Neovim features, no plugins.
--
-- See: lua/config/options.lua
-- See: lua/lib/search.lua
-- See: lua/config/keymaps/quickfix.lua
-- See: lua/modules/compile.lua

local km = vim.keymap.set
local search = require("lib.search")

search.setup()

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
	search.flash({ { lnum, s + 1, e - s } })
end, { desc = "Flash word under cursor" })

km("n", "<leader>hl", function()
	search.flash({ vim.fn.line(".") })
end, { desc = "Flash current line" })

-- <Esc> clears the search highlights.
km("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlights" })

-- Grep in the project (quickfix)
km("n", "<leader>sg", function()
	search.grep(vim.fn.input("Grep> "))
end, { desc = "Grep in project (regex)" })

km("n", "<leader>sr", function()
	search.grep(vim.fn.expand("<cword>"), "-F -w")
end, { desc = "Grep word under cursor in project" })

km("v", "<leader>sg", function()
	local text = search.get_selection()
	vim.cmd("normal! \27") -- leave visual mode
	search.grep(text, "-F")
end, { desc = "Grep selection in project" })

-- Grep in the current buffer (location list)
km("n", "<leader>sl", function()
	search.buffer_grep(vim.fn.input("Buffer grep> "))
end, { desc = "Grep in current buffer (loclist)" })

-- Grep in the project with the Vim regex engine, no ripgrep needed.
-- <leader>sv belongs to the window keymaps, hence the capital.
km("n", "<leader>sV", function()
	search.vimgrep(vim.fn.input("Vimgrep> "))
end, { desc = "Vimgrep in project (Vim regex)" })

-- Lines matching the last search, in the current buffer
km("n", "<leader>s/", "<cmd>g//#<cr>", { desc = "List lines matching last search" })

-- Lines containing the word under the cursor (also in included files)
km("n", "<leader>si", "[I", { desc = "List lines with word under cursor" })

-- Files, buffers and history
km("n", "<leader>sf", ":find *", { desc = "Find file by name" })
km("n", "<leader>su", ":ls<cr>:b<space>", { desc = "Pick buffer" })
km("n", "<leader>sp", "<cmd>oldfiles<cr>:edit #<", { desc = "Pick recent file" })
km("n", "<leader>sa", "<cmd>marks<cr>:normal! `", { desc = "Pick mark" })
km("n", "<leader>sh", ":help ", { desc = "Search help" })
km("n", "<leader>sH", ":helpgrep ", { desc = "Grep in all help files" })
