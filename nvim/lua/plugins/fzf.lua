-- lua/plugins/fzf.lua

-- Fuzzy finder for files, buffers, text, diagnostics and help, built on
-- fzf-lua, styled after the Emacs minibuffer (Vertico/Consult): bottom panel,
-- a mode-line-like bar on top, plain-text prompts, no icons and no preview.
--
-- The plugin lazy-loads on the first picker, and the keymaps are stubs that
-- load it on demand.
--
-- $ sudo pacman -S fzf grep ripgrep fd bat
--
-- See: lua/lib/lazy.lua
-- See: https://github.com/ibhagwan/fzf-lua

local M = {}

-- Skipped by the file and grep pickers to keep them fast.
---@type string[]
local ignored_dirs = {
	".git",
	"node_modules",
	".venv",
	"venv",
	"__pycache__",
	".mypy_cache",
	".pytest_cache",
	".cache",
	".gradle",
	".idea",
	".next",
	"target",
	"dist",
}

-- The ripgrep glob `-g "!name"` excludes a directory at any depth. The fd flag
-- `--exclude name` does the same for the detailed file picker.
local rg_globs = {}
local fd_excludes = {}

for _, dir in ipairs(ignored_dirs) do
	table.insert(rg_globs, string.format('-g "!%s"', dir))
	table.insert(fd_excludes, string.format("--exclude %s", dir))
end

rg_globs = table.concat(rg_globs, " ")
fd_excludes = table.concat(fd_excludes, " ")

---Build the options table passed to `fzf.setup()`. A built-in base profile is
---added by `M.after`; everything here overrides it.
---@return table<string, any>
local function make_opts()
	local actions = require("fzf-lua").actions

	return {
		winopts = {
			backdrop = false,
			title = false,
			title_flags = false,

			on_create = function(e)
				if e.winid and vim.api.nvim_win_is_valid(e.winid) then
					vim.api.nvim_win_set_config(e.winid, { title = "" })
				end
			end,

			preview = {
				default = "bat",
				hidden = true,
				title = false,
				wrap = true,
				scrollbar = false,
			},
		},

		defaults = {
			file_icons = false,
			git_icons = false,
		},

		fzf_opts = {
			["--info"] = "hidden",
			["--ansi"] = true,
			["--layout"] = "default",
			["--highlight-line"] = true,
			["--pointer"] = " ",
			["--no-scrollbar"] = true,
			["--no-separator"] = true,
			["--history"] = vim.fn.stdpath("data") .. "/fzf_history",
			-- ["--header"] = ":: C-g cancel  C-n/C-p move  M-n/M-p history  C-q select all  C-x split  C-t tab",
			-- ["--header-border"] = "none",
		},

		fzf_colors = {
			["bg+"] = { "bg", "CursorLine" },
			["fg+"] = { "fg", "Normal" },
			["prompt"] = { "fg", "Normal", "bold" },
			["info"] = { "fg", "Comment" },
			["gutter"] = { "bg", "Normal" },
			["pointer"] = { "bg", "CursorLine" },
			["marker"] = { "bg", "CursorLine" },
			["hl"] = { "fg", "Special", "bold", "underline" },
			["hl+"] = { "fg", "Special", "bold", "underline" },
		},

		previewers = {
			builtin = {
				title = false,
				treesitter = { enabled = true },
			},
		},

		actions = {
			files = {
				["enter"] = actions.file_edit_or_qf,
				["ctrl-t"] = actions.file_tabedit,
				["ctrl-x"] = actions.file_split,
			},
		},

		keymap = {
			builtin = {
				["<C-f>"] = "preview-page-down",
				["<C-b>"] = "preview-page-up",
			},
			fzf = {
				["ctrl-g"] = "abort",
				["ctrl-n"] = "down",
				["ctrl-p"] = "up",
				["alt-n"] = "next-history",
				["alt-p"] = "previous-history",
				["ctrl-k"] = "kill-line",
				["ctrl-z"] = "abort",
				["ctrl-u"] = "unix-line-discard",
				["ctrl-q"] = "select-all+accept",
			},
		},

		-- The fzf-lua defaults plus the extra ignores. Paths are shown whole,
		-- as in `find-file` and `consult-buffer`.
		files = {
			prompt = "Find file: ",
			rg_opts = "--color=never --files --hidden --follow " .. rg_globs,
			fd_opts = "--color=never --hidden --type f --type l " .. fd_excludes,
		},

		oldfiles = { prompt = "Recent file: " },
		buffers = { prompt = "Switch to buffer: " },
		blines = { prompt = "Line: " },
		commands = { prompt = "M-x " },
		helptags = { prompt = "Describe: " },
		keymaps = { prompt = "Describe key: " },
		diagnostics = { prompt = "Diagnostic: ", diag_icons = false },
		lsp = {
			prompt_postfix = ": ",
			symbols = { symbol_style = 3 }, -- kind as text, no icon
		},

		-- The line and column fields are hidden from the results.
		grep = {
			prompt = "Ripgrep: ",
			rg_opts = "--column --line-number --no-heading --color=always --smart-case --max-columns=4096 "
				.. rg_globs
				.. " -e",
			fzf_opts = {
				["--delimiter"] = ":",
				["--with-nth"] = "1,4..",
			},
		},
	}
end

---Set the border highlights of the fzf-lua window and its preview.
local function set_fzf_hl()
	local sl = vim.api.nvim_get_hl(0, { name = "CursorLine", link = false })
	local bar = sl.bg or sl.fg or 0x2a2a2a
	vim.api.nvim_set_hl(0, "FzfLuaBorder", { fg = bar, bg = bar })
	vim.api.nvim_set_hl(0, "FzfLuaPreviewBorder", { fg = bar })
end

set_fzf_hl()
vim.api.nvim_create_autocmd("ColorScheme", {
	group = vim.api.nvim_create_augroup("cg/fzf_hl", { clear = true }),
	callback = set_fzf_hl,
})

---Set up fzf-lua. Called once per session by `lib.lazy`, after fzf-lua is
---loaded; the setup needs the module, so it cannot run as a `configure`.
function M.after()
	local opts = make_opts()

	-- The profile goes first, so every key in `opts` overrides it.
	table.insert(opts, 1, { "ivy", "hide" })

	local fzf_lua = require("fzf-lua")
	fzf_lua.setup(opts)

	fzf_lua.register_ui_select()
end

---Load fzf-lua on first use and return it. The loader is guarded, so after the
---first keypress this is a cached require.
---@return table
local function fzf()
	require("lib.lazy").load("fzf-lua")
	return require("fzf-lua")
end

local km = vim.keymap.set

km(
	"n",
	"<leader>fr",
	function() fzf().files({ cwd = vim.fn.expand("~/dev/repos/studies") }) end,
	{ desc = "Fzf: find files in ~/dev/repos/studies/" }
)
km(
	"n",
	"<leader>fn",
	function() fzf().files({ cwd = vim.fn.expand("~/dotfiles/nvim") }) end,
	{ desc = "Fzf: find files in ~/dotfiles/nvim" }
)
km(
	"n",
	"<leader>fd",
	function() fzf().files({ cwd = vim.fn.expand("%:p:h") }) end,
	{ desc = "Fzf: find files in the current buffer's directory" }
)
km("n", "<leader>fg", function() fzf().live_grep({ rg_glob = true }) end, { desc = "Fzf: live grep in cwd" })
km("n", "<leader>ff", function() fzf().files() end, { desc = "Fzf: find files in cwd" })
km("n", "<leader>fo", function() fzf().oldfiles() end, { desc = "Fzf: reopen recently edited files" })
km("n", "<leader>fw", function() fzf().grep_cword() end, { desc = "Fzf: grep the word under the cursor in cwd" })
km("v", "<leader>fw", function() fzf().grep_visual() end, { desc = "Fzf: grep the visual selection" })
km("n", "<leader>fc", function() fzf().resume() end, { desc = "Fzf: resume the last picker" })
km("n", "<leader>fb", function() fzf().buffers() end, { desc = "Fzf: switch buffer" })

-- Notes buffers also trigger the load, so the obsidian picker resolves before
-- any picker was opened.
require("lib.lazy").setup({
	src = "https://github.com/ibhagwan/fzf-lua",
	filetypes = { "markdown" },
	after = M.after,
})

return M
