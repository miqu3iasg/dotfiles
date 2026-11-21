-- lua/config/keymaps/search.lua

-- Scrolling, search navigation, highlights, grep, matches of the last search
-- and file pickers.
--
-- See: lua/config/options.lua
-- See: lua/lib/search.lua
-- See: lua/config/keymaps/quickfix.lua

local km = vim.keymap.set
local search = require("lib.search")
local substitute = require("lib.substitute")

search.setup()

km("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center cursor" })
km("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center cursor" })
km("n", "<C-f>", "<C-f>zz", { desc = "Page down and center cursor" })
km("n", "<C-b>", "<C-b>zz", { desc = "Page up and center cursor" })

km("n", "n", "nzzzv", { desc = "Next search result, center cursor and open fold" })
km("n", "N", "Nzzzv", { desc = "Previous search result, center cursor and open fold" })
km("n", "*", "*zzzv", { desc = "Search word forward and center cursor" })
km("n", "#", "#zzzv", { desc = "Search word backward and center cursor" })
km("n", "g*", "g*zzzv", { desc = "Search partial word forward and center cursor" })
km("n", "g#", "g#zzzv", { desc = "Search partial word backward and center cursor" })
km("n", "}", "}zz", { desc = "Jump to next paragraph and center cursor" })
km("n", "{", "{zz", { desc = "Jump to previous paragraph and center cursor" })

km("v", "*", [[y/\V<C-r>=escape(@", '/\')<CR><CR>]], { desc = "Search selection forward" })
km("v", "#", [[y?\V<C-r>=escape(@", '/\')<CR><CR>]], { desc = "Search selection backward" })

-- See: lua/lib/substitute.lua (pattern escaping)
km("n", "<leader>sw", function()
	vim.fn.setreg("/", substitute.escape_pattern(vim.fn.expand("<cword>"), true))
	vim.o.hlsearch = true
end, { desc = "Search word under cursor" })

km("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlights" })

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

km("n", "<leader>el", function()
	search.buffer_grep(vim.fn.input("Buffer grep> "))
end, { desc = "Grep in current buffer (loclist)" })

km("n", "<leader>ef", ":find ", { desc = "Find file by name" })
km("n", "<leader>eb", ":ls<cr>:b<space>", { desc = "Pick buffer" })
km("n", "<leader>eo", "<cmd>oldfiles<cr>:edit #<", { desc = "Pick recent file" })
km("n", "<leader>em", "<cmd>marks<cr>:normal! `", { desc = "Pick mark" })
km("n", "<leader>eh", ":help ", { desc = "Search help" })
km("n", "<leader>eH", ":helpgrep ", { desc = "Grep in all help files" })

km("n", "ym", function()
	search.yank_matches(vim.v.register)
end, { desc = "Yank all matches of last search (accepts a register)" })

km("n", "cm", ":%s///g<Left><Left>", {
	desc = "Substitute all matches of last search (type the replacement)",
})

km("n", "<leader>er", function()
	local root = vim.fs.root(0, { ".git" }) or vim.fn.getcwd()
	return ":edit " .. vim.fn.fnameescape(root) .. "/**/*"
end, { expr = true, desc = "Edit file from project root" })

km("n", "<leader>en", ":find ~/dotfiles/nvim/", { desc = "Find file in ~/dotfiles/nvim" })
km("n", "<leader>es", ":find ~/dev/repos/studies/", { desc = "Find file in ~/dev/repos/studies" })
