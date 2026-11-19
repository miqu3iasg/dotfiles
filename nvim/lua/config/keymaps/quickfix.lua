-- lua/config/keymaps/quickfix.lua

-- Quickfix and location list keymaps, for navigating entries and for editing
-- the list window.
--
-- See: lua/config/keymaps/search.lua
-- See: :help quickfix

local km = vim.keymap.set

---Delete the entry under the cursor from the list that owns the current
---window, which is the location list when the window is one.
local function delete_entry()
	local win = vim.fn.win_getid()
	local is_loclist = vim.fn.getwininfo(win)[1].loclist == 1

	-- `getqflist` takes no window id, so the two calls cannot be unified.

	local items = is_loclist and vim.fn.getloclist(win) or vim.fn.getqflist()
	local title = is_loclist and vim.fn.getloclist(win, { title = 0 }).title or vim.fn.getqflist({ title = 0 }).title
	table.remove(items, vim.fn.line("."))

	if is_loclist then
		vim.fn.setloclist(win, {}, " ", { items = items, title = title })
	else
		vim.fn.setqflist({}, " ", { items = items, title = title })
	end
end

km("n", "]q", "<cmd>cnext<cr>zz", { desc = "Next quickfix item" })
km("n", "[q", "<cmd>cprev<cr>zz", { desc = "Previous quickfix item" })
km("n", "]Q", "<cmd>clast<cr>", { desc = "Last quickfix item" })
km("n", "[Q", "<cmd>cfirst<cr>", { desc = "First quickfix item" })
km("n", "<leader>q", function()
	local qf_win = vim.fn.getqflist({ winid = 0 }).winid
	if qf_win ~= 0 then
		vim.cmd("cclose")
	else
		vim.cmd("copen")
	end
end, { desc = "Toggle quickfix list" })
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
