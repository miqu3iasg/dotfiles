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
local substitute = require("lib.substitute")

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
-- See: lua/lib/substitute.lua (pattern escaping)
km("n", "<leader>sw", function()
	vim.fn.setreg("/", substitute.escape_pattern(vim.fn.expand("<cword>"), true))
	vim.o.hlsearch = true
end, { desc = "Search word under cursor" })

-- <Esc> clears the search highlights.
km("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlights" })

-- Grep in the project (quickfix)
km("n", "<leader>eg", function()
	search.grep(vim.fn.input("Grep> "))
end, { desc = "Grep in project (regex)" })

km("n", "<leader>ew", function()
	search.grep(vim.fn.expand("<cword>"), "-F -w")
end, { desc = "Grep word under cursor in project" })

km("v", "<leader>eg", function()
	local text = search.get_selection()
	vim.cmd("normal! \27") -- leave visual mode
	search.grep(text, "-F")
end, { desc = "Grep selection in project" })

-- Grep in the current buffer (location list)
km("n", "<leader>el", function()
	search.buffer_grep(vim.fn.input("Buffer grep> "))
end, { desc = "Grep in current buffer (loclist)" })

-- Lines matching the last search, in the current buffer
km("n", "<leader>e/", "<cmd>g//#<cr>", { desc = "List lines matching last search" })

-- Lines containing the word under the cursor (also in included files)
km("n", "<leader>ei", "[I", { desc = "List lines with word under cursor" })

-- Files, buffers and history
km("n", "<leader>ef", ":find ", { desc = "Find file by name" })
-- Scoped fuzzy find through 'findfunc' (see: lua/lib/search.lua)
km("n", "<leader>en", ":find n: ", { desc = "Fuzzy find file in ~/dotfiles/nvim" })
km("n", "<leader>es", ":find s: ", { desc = "Fuzzy find file in ~/dev/repos/studies" })
km("n", "<leader>eb", ":ls<cr>:b<space>", { desc = "Pick buffer" })
km("n", "<leader>eo", "<cmd>oldfiles<cr>:edit #<", { desc = "Pick recent file" })
km("n", "<leader>em", "<cmd>marks<cr>:normal! `", { desc = "Pick mark" })
km("n", "<leader>eh", ":help ", { desc = "Search help" })
km("n", "<leader>eH", ":helpgrep ", { desc = "Grep in all help files" })
