-- lua/config/keymaps/quickfix.lua

-- Keymaps for the quickfix and location lists: navigation between entries,
-- open and close commands and in-window keys for editing the list. The
-- navigation works from any buffer; the editing works inside the list window.
--
-- See: lua/config/keymaps/search.lua
-- See: :help quickfix

local km = vim.keymap.set

---Delete the entry under the cursor from the list that owns the current
---window, which is the location list when the window is one. The list is
---replaced in place, so the window stays open and the cursor keeps its line.
local function delete_entry()
	local win = vim.fn.win_getid()
	local is_loclist = vim.fn.getwininfo(win)[1].loclist == 1
	local get = is_loclist and vim.fn.getloclist or vim.fn.getqflist
	local set = is_loclist and vim.fn.setloclist or vim.fn.setqflist

	local items = get(win)
	local title = get(win, { title = 0 }).title
	table.remove(items, vim.fn.line("."))
	set(win, {}, " ", { items = items, title = title })
end

-- Navigation from any buffer, recentered on the new entry
km("n", "]q", "<cmd>cnext<cr>zz", { desc = "Next quickfix item" })
km("n", "[q", "<cmd>cprev<cr>zz", { desc = "Previous quickfix item" })
km("n", "]Q", "<cmd>clast<cr>", { desc = "Last quickfix item" })
km("n", "[Q", "<cmd>cfirst<cr>", { desc = "First quickfix item" })
km("n", "<leader>qq", "<cmd>copen<cr>", { desc = "Open quickfix list" })
km("n", "<leader>qc", "<cmd>cclose<cr>", { desc = "Close quickfix list" })
km("n", "<leader>s[", "<cmd>colder<cr>", { desc = "Older quickfix list" })
km("n", "<leader>s]", "<cmd>cnewer<cr>", { desc = "Newer quickfix list" })

km("n", "]l", "<cmd>lnext<cr>zz", { desc = "Next location item" })
km("n", "[l", "<cmd>lprev<cr>zz", { desc = "Previous location item" })
km("n", "]L", "<cmd>llast<cr>", { desc = "Last location item" })
km("n", "[L", "<cmd>lfirst<cr>", { desc = "First location item" })

-- Keys inside the list window are buffer-local, so they are set when the
-- window opens. `q` and `<Esc>` close it through the utility-buffer autocmd.
-- See: lua/config/autocmds.lua
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("cg/quickfix_keys", { clear = true }),
	desc = "Set the keys of the quickfix window",
	pattern = "qf",
	callback = function(args)
		km("n", "dd", delete_entry, { buffer = args.buf, desc = "Delete entry under cursor" })
		km("n", "<Tab>", "za", { buffer = args.buf, desc = "Toggle the fold of the current file" })
	end,
})
