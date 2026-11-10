-- lua/config/autocmds.lua

-- Global autocmds for window layout, editing conveniences, big files, startup
-- and session handling, and utility buffers.

vim.api.nvim_create_autocmd("VimResized", {
	group = vim.api.nvim_create_augroup("cg/vim_resized", { clear = true }),
	desc = "Keep splits evenly sized after resizing the terminal",
	callback = function()
		vim.cmd("wincmd =")
	end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
	group = vim.api.nvim_create_augroup("cg/text_yank_post", { clear = true }),
	desc = "Highlight yanked text",
	callback = function()
		vim.hl.on_yank()
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("no_auto_comment", {}),
	desc = "Do not continue comments on new lines",
	callback = function()
		vim.opt_local.formatoptions:remove({ "c", "r", "o" })
	end,
})

-- A buffer is big based on file size and line length.
-- See: lua/lib/bigfile.lua
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("cg/bigfile", { clear = true }),
	desc = "Disable heavy features on big files",
	callback = function(ev)
		if not require("lib.bigfile").is_big(ev.buf) then
			return
		end
		pcall(vim.treesitter.stop, ev.buf)
		vim.b[ev.buf].completion = false
		vim.diagnostic.enable(false, { bufnr = ev.buf })
		vim.opt_local.foldmethod = "manual"
		vim.opt_local.spell = false
		vim.opt_local.cursorline = false
		vim.opt_local.relativenumber = false
	end,
})

vim.api.nvim_create_autocmd("BufRead", {
	group = vim.api.nvim_create_augroup("dotenv_ft", { clear = true }),
	desc = "Use dosini syntax highlighting for dotenv files",
	pattern = { ".env", ".env.*" },
	callback = function()
		vim.bo.filetype = "dosini"
	end,
})

-- Runs when Neovim starts with no arguments or with a single directory. It is
-- `nested` so the restored session fires its own autocmds, such as filetype,
-- and scheduled so it runs after startup has finished.
-- See: lua/modules/sessions.lua
-- See: lua/plugins/oil.lua
vim.api.nvim_create_augroup("StartupBehavior", { clear = true })
vim.api.nvim_create_autocmd("VimEnter", {
	group = "StartupBehavior",
	desc = "Restore the tmux session of the directory, or open Oil",
	nested = true,
	callback = function()
		local argc = vim.fn.argc()
		local no_files = argc == 0 or (argc == 1 and vim.fn.isdirectory(vim.fn.argv(0)) == 1)

		if not no_files then
			return
		end

		vim.schedule(function()
			local sessions = require("modules.sessions")
			if sessions.enabled() and sessions.load() then
				return
			end

			if argc == 0 then
				require("oil").open()
			else
				require("oil").open(vim.fn.argv(0))
			end
		end)
	end,
})

-- The save is wrapped in `pcall` so a failure never blocks quitting.
-- See: lua/modules/sessions.lua
vim.api.nvim_create_autocmd("VimLeavePre", {
	group = vim.api.nvim_create_augroup("SessionSave", { clear = true }),
	desc = "Save the session of the current directory on exit, inside tmux only",
	callback = function()
		local sessions = require("modules.sessions")
		if sessions.enabled() then
			pcall(sessions.save)
		end
	end,
})

vim.api.nvim_create_augroup("CreateDirs", { clear = true })
vim.api.nvim_create_autocmd("BufWritePre", {
	group = "CreateDirs",
	desc = "Create missing parent directories on save",
	pattern = "*",
	callback = function(event)
		-- Virtual buffers such as oil:// and fugitive:// have no real directory.
		if event.match:match("^%w+://") then
			return
		end
		local file_path = vim.fn.expand("<afile>:p:h")
		if vim.fn.isdirectory(file_path) == 0 then
			vim.fn.mkdir(file_path, "p")
		end
	end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
	group = vim.api.nvim_create_augroup("LastCursorPos", { clear = true }),
	desc = "Jump to the last cursor position when opening a file",
	callback = function(args)
		local valid_line = vim.fn.line([['"]]) >= 1 and vim.fn.line([['"]]) < vim.fn.line("$")
		local name = vim.api.nvim_buf_get_name(args.buf)
		-- The file name is used because the FileType event has not fired yet on
		-- BufReadPost, so the filetype is still unset.
		local is_commit = name:match("/(COMMIT_EDITMSG|MERGE_MSG|TAG_EDITMSG|NOTES_EDITMSG)$") ~= nil
		if valid_line and not is_commit then
			vim.cmd([[normal! g`"]])
		end
	end,
})

-- Special buffers, which have a nonempty 'buftype', are skipped. The view is
-- restored so the cursor and scroll position do not move.
vim.api.nvim_create_autocmd("BufWritePre", {
	group = vim.api.nvim_create_augroup("cg/whitespace", {}),
	desc = "Strip trailing whitespace on save",
	pattern = "*",
	callback = function(args)
		if not vim.bo[args.buf].modifiable or vim.bo[args.buf].buftype ~= "" then
			return
		end

		local view = vim.fn.winsaveview()
		vim.cmd([[keepjumps keeppatterns silent! %s/\s\+$//e]])
		vim.fn.winrestview(view)
	end,
})

-- Utility buffers share the close behavior and the clean UI below.
-- See: lua/modules/compile.lua
-- See: lua/modules/close_view.lua
---@type string[]
local utility_filetypes = {
	"checkhealth",
	"conform-info",
	"fugitive",
	"fugitiveblame",
	"help",
	"nvim-pack",
	"lspinfo",
	"man",
	"nvim-undotree",
	"qf",
}

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("cg/close_utility_buffers", { clear = true }),
	desc = "Unlist utility buffers and map keys to close their window",
	pattern = utility_filetypes,
	callback = function(args)
		vim.bo[args.buf].buflisted = false
		for _, key in ipairs({ "q", "<Esc>" }) do
			vim.keymap.set("n", key, "<cmd>close<cr>", {
				buffer = args.buf,
				silent = true,
				nowait = true,
				desc = "close buffer",
			})
		end
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("cg/utility_nolist", { clear = true }),
	desc = "Disable listchars in utility buffers",
	pattern = utility_filetypes,
	callback = function()
		vim.opt_local.list = false
	end,
})

vim.api.nvim_create_autocmd("TermOpen", {
	group = vim.api.nvim_create_augroup("cg/term_open", { clear = true }),
	desc = "Clean the UI and enter insert mode when a terminal opens",
	callback = function()
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false
		vim.opt_local.signcolumn = "no"
		vim.opt_local.spell = false
		vim.cmd("startinsert")
	end,
})

-- A fixed width keeps the file window's layout.
-- See: :help undotree
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("cg/undotree_layout", { clear = true }),
	desc = "Open the built-in undotree on the far left",
	pattern = "nvim-undotree",
	callback = function()
		vim.cmd.wincmd("H")
		vim.api.nvim_win_set_width(0, 40)
	end,
})
