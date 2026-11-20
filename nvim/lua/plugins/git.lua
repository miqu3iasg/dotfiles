-- lua/plugins/git.lua

-- Git inside Neovim, through vim-fugitive for repository operations and
-- gitsigns.nvim for hunk-level changes.
--
-- Destructive remote operations are left to the terminal, and `:GBrowse`
-- needs vim-rhubarb.
--
-- Git comes from the distribution.
--
-- $ sudo pacman -S git
--
-- See: lua/modules/close_view.lua
-- See: https://github.com/tpope/vim-fugitive
-- See: https://github.com/lewis6991/gitsigns.nvim

local keys = require("lib.keys")
local map = keys.map

local log_format = "--color=never --date=short --pretty=format:'%h %cd  %s (%an)%d'"

---Return the ordered visual selection range
---@return integer[] range `{ first, last }`
local function visual_range()
	local a, b = vim.fn.line("."), vim.fn.line("v")
	return { math.min(a, b), math.max(a, b) }
end

---Return the escaped path of the current buffer, or nil when it is not a
---regular file such as a fugitive, terminal or unnamed buffer
---@return string|nil path
local function log_target()
	local file = vim.api.nvim_buf_get_name(0)
	if file == "" or file:match("^%w+://") then
		vim.notify("Git log: buffer is not a regular file", vim.log.levels.WARN)
		return nil
	end
	return vim.fn.fnameescape(file)
end

---Open `git log` in a new tab, ported from bruhtus dotfiles
--- See: https://github.com/bruhtus/dotfiles/blob/master/.vim/after/autoload/enable/fugitive_log.vim
---@param args string
local function git_log(args)
	vim.cmd(("-tab Git log %s %s"):format(log_format, args))
end

---Return the line range of the function or method enclosing the cursor, via
---treesitter, so it does not depend on git knowing the filetype
---@return integer|nil first
---@return integer|nil last
local function enclosing_function_range()
	local ok, node = pcall(vim.treesitter.get_node)
	if not ok then
		return
	end
	while node do
		local t = node:type()
		if (t:find("function") or t:find("method")) and not t:find("call") then
			local srow, _, erow, ecol = node:range()
			-- A node ending at column 0 does not include that last row.
			if ecol == 0 then
				erow = erow - 1
			end
			return srow + 1, erow + 1
		end
		node = node:parent()
	end
end

---Open the history of the current file, following renames
local function git_log_file()
	local file = log_target()
	if file then
		git_log("--follow " .. file)
	end
end

---Open the history of the function under the cursor
local function git_log_function()
	local file = log_target()
	if not file then
		return
	end

	local first, last = enclosing_function_range()
	if first then
		git_log(("-L %d,%d:%s"):format(first, last, file))
	else
		-- Without a treesitter parser, fall back to git's own function detection.
		git_log(("-L :%s:%s"):format(vim.fn.expand("<cword>"), file))
	end
end

---Open the history of the selected line range
local function git_log_visual()
	local file = log_target()
	if not file then
		return
	end
	-- Read the range first, since leaving visual mode clears the selection.
	local range = visual_range()
	vim.cmd("normal! \27")
	git_log(("-L %d,%d:%s"):format(range[1], range[2], file))
	vim.cmd("redraw!")
end

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("GitFugitiveBlame", { clear = true }),
	pattern = "fugitiveblame",
	callback = function()
		vim.cmd("vertical resize 45")
	end,
})

require("modules.close_view").setup()

map("n", "<leader>gg", "<cmd>silent tab Git<cr>", "Git status")
map("n", "<leader>ga", "<cmd>silent Gwrite<cr>", "Stage current file")
map("n", "<leader>gu", "<cmd>Gread<cr>", "Restore file from index (undoable)")

map("n", "<leader>gc", "<cmd>Git commit<cr>", "Commit")

map("n", "<leader>gp", "<cmd>Git push<cr>", "Push")

map("n", "<leader>gl", "<cmd>-tab Git log --color=never --oneline --graph --decorate<cr>", "Git log (oneline)")
map("n", "<leader>gL", "<cmd>-tab Git log --color=never --stat -p --decorate --date=short<cr>", "Git log (expanded)")
map("n", "<leader>go", git_log_file, "Git log (file)")
map("x", "<leader>go", git_log_visual, "Git log (selection)")
map("n", "<leader>gf", git_log_function, "Git log (function)")

map("n", "<leader>gd", "<cmd>silent Gvdiffsplit<cr>", "Diff against index")
map("n", "<leader>gh", "<cmd>silent Gvdiffsplit HEAD<cr>", "Diff against HEAD")
map("n", "<leader>gb", "<cmd>silent Git blame<cr>", "Git blame")
map("n", "<leader>ge", "<cmd>.Git blame<cr>", "Git blame (line)")

map("n", "<leader>gw", "<cmd>GBrowse<cr>", "Open file in browser")
map("x", "<leader>gw", ":GBrowse<cr>", "Open selection in browser")

-- In the 3-way diff, `//2` is the target (ours) and `//3` is the merge
-- (theirs). Only the entry point uses the leader, so picking a side stays quick.
map("n", "<leader>gx", "<cmd>Gvdiffsplit!<cr>", "Resolve conflicts (3-way diff)")
map({ "n", "x" }, "gt", "<cmd>diffget //2<cr>", "Conflict: take ours (target)")
map({ "n", "x" }, "gh", "<cmd>diffget //3<cr>", "Conflict: take theirs (merge)")

local diff_overlay = false

require("gitsigns").setup({
	signcolumn = false,
	numhl = false,
	word_diff = false,
	current_line_blame = false,

	-- The keymaps are buffer-local so the native hunk motions keep working
	-- outside tracked buffers and in diff mode, such as `Gvdiffsplit`.
	on_attach = function(bufnr)
		local gs = require("gitsigns")

		---Map a key in the attached buffer only
		---@param mode string|string[]
		---@param lhs string
		---@param rhs string|function
		---@param desc string
		local function bmap(mode, lhs, rhs, desc)
			keys.map(mode, lhs, rhs, desc, { buffer = bufnr })
		end

		---Navigate hunks, falling back to the native diff motions in diff mode
		---@param direction "next"|"prev"
		---@return fun() action
		local function nav(direction)
			return function()
				if vim.wo.diff then
					vim.cmd.normal({ direction == "next" and "]c" or "[c", bang = true })
				else
					gs.nav_hunk(direction, { navigation_message = false })
				end
			end
		end

		bmap("n", "]c", nav("next"), "Next hunk")
		bmap("n", "[c", nav("prev"), "Prev hunk")
		bmap("n", "<leader>hs", gs.stage_hunk, "Stage/unstage hunk")
		bmap("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
		bmap("n", "<leader>hp", gs.preview_hunk_inline, "Preview hunk")
		bmap("n", "<leader>hb", gs.toggle_current_line_blame, "Toggle current line blame")

		bmap("x", "<leader>hs", function()
			gs.stage_hunk(visual_range())
		end, "Stage/unstage selection")

		bmap("x", "<leader>hr", function()
			gs.reset_hunk(visual_range())
		end, "Reset selection")

		bmap("n", "<leader>hd", function()
			diff_overlay = not diff_overlay
			gs.toggle_deleted(diff_overlay)
			gs.toggle_linehl(diff_overlay)
		end, "Toggle diff overlay")

		bmap({ "o", "x" }, "ih", "<cmd>Gitsigns select_hunk<cr>", "Select hunk")
	end,
})
