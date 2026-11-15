-- lua/plugins/fzf.lua

-- Fuzzy finder for files, buffers, text, diagnostics and help, built on
-- fzf-lua. It gives a single interface for navigating a project.
--
-- The plugin loads on demand. `lib.lazy` installs it without sourcing it, and
-- the first picker keymap loads it, runs the setup and opens the picker. The
-- keymaps below are stubs, so every picker is reachable before the plugin is
-- loaded.
--
-- The external tools must be installed on the system, since fzf-lua only wraps
-- them. On Arch Linux:
--
-- $ sudo pacman -S fzf grep ripgrep fd
--
-- See: lua/lib/lazy.lua
-- See: https://github.com/ibhagwan/fzf-lua
-- See: https://github.com/bruhtus/dotfiles/blob/master/.vim/after/autoload/enable/fzf.vim
-- See: https://github.com/bruhtus/dotfiles/blob/master/.vim/plugin/fzf.vim
-- See: https://github.com/james-orcales/james-orcales/blob/main/home/.config/nvim/init.lua

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

---Build the options table passed to `fzf.setup()`.
---@return table<string, any>
local function make_opts()
	local actions = require("fzf-lua").actions

	return {
		winopts = {
			on_create = function(e)
				if e.winid and vim.api.nvim_win_is_valid(e.winid) then
					vim.api.nvim_win_set_config(e.winid, { title = "" })
				end
			end,

			height = 0.95,
			width = 0.90,
			row = 0.35,
			col = 0.50,
			border = "single",

			-- height = 0.22,
			-- width = 1.0,
			-- row = 1.0,
			-- col = 0.0,
			-- border = { "", "─", "", "", "", "", "", "" },
			-- backdrop = false,

			title = false,
			title_flags = false,
			preview = {
				default = "bat",
				hidden = true,
				layout = "horizontal",
				title = false,
				horizontal = "right:50%",
				wrap = true,
				scrollbar = false,
			},
		},

		fzf_opts = {
			["--ansi"] = true,
			["--layout"] = "default",
			["--highlight-line"] = true,
			["--info"] = "inline-right",
			["--pointer"] = " ",
			["--no-scrollbar"] = true,
			["--no-separator"] = true,
		},

		fzf_colors = {
			["bg+"] = { "bg", "CursorLine" },
			["fg+"] = { "fg", "Normal" },
			["prompt"] = { "fg", "Normal" },
			["gutter"] = { "bg", "Normal" },
			-- The pointer and the multi-select marker use the selected line
			-- background, which makes their column invisible.
			["pointer"] = { "bg", "CursorLine" },
			["marker"] = { "bg", "CursorLine" },
			["hl"] = { "fg", "Special" },
			["hl+"] = { "fg", "Special" },
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
				["ctrl-g"] = "execute(less -c -i --incsearch --search-options=W -g {})",
				["ctrl-z"] = "abort",
				["ctrl-u"] = "unix-line-discard",
				["ctrl-q"] = "select-all+accept",
			},
		},

		-- The fzf-lua defaults plus the extra ignores.
		files = {
			rg_opts = "--color=never --files --hidden --follow " .. rg_globs,
			fd_opts = "--color=never --hidden --type f --type l " .. fd_excludes,
		},

		-- The line and column fields are hidden from the results.
		grep = {
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

---Set the border highlights of the fzf-lua window and its preview. It also runs
---on every colorscheme change, because a colorscheme resets the highlight
---groups.
local function set_fzf_hl()
	vim.api.nvim_set_hl(0, "FzfLuaBorder", { fg = "#2a2a2a" })
	vim.api.nvim_set_hl(0, "FzfLuaPreviewBorder", { fg = "#2a2a2a" })
end

set_fzf_hl()
vim.api.nvim_create_autocmd("ColorScheme", {
	group = vim.api.nvim_create_augroup("cg/fzf_hl", { clear = true }),
	callback = set_fzf_hl,
})

---Set up fzf-lua. Called once per session by `lib.lazy`, after fzf-lua is
---loaded; the setup needs the module, so it cannot run as a `configure`.
function M.after()
	require("fzf-lua").setup(make_opts())
end

---Load fzf-lua on first use and return it. The loader is guarded, so after the
---first keypress this is a cached require.
---@return table
local function fzf()
	require("lib.lazy").load("fzf-lua")
	return require("fzf-lua")
end

local km = vim.keymap.set

km("n", "<leader>ff", function()
	fzf().files()
end, { desc = "Fzf: find files in cwd (respects .gitignore)" })

km("n", "<leader>fd", function()
	fzf().files({ cwd = vim.fn.expand("%:p:h") })
end, { desc = "Fzf: find files in the current buffer's directory" })

km("n", "<leader>fz", function()
	fzf().zoxide()
end, { desc = "Fzf: jump to a frequent directory (zoxide)" })

km("n", "<leader>fr", function()
	fzf().files({ cwd = vim.fn.expand("~/dev/repos") })
end, { desc = "Fzf: find files in ~/dev/repos" })

km("n", "<leader>fn", function()
	fzf().files({ cwd = vim.fn.expand("~/dotfiles/nvim") })
end, { desc = "Fzf: find files in ~/dotfiles/nvim" })

km("n", "<leader>fb", function()
	fzf().buffers()
end, { desc = "Fzf: switch between open buffers" })

km("n", "<leader>fo", function()
	fzf().oldfiles()
end, { desc = "Fzf: reopen recently edited files" })

km("n", "<leader>fg", function()
	fzf().live_grep({ rg_glob = true })
end, { desc = "Fzf: live grep in cwd" })

km("n", "<leader>fw", function()
	fzf().grep_cword()
end, { desc = "Fzf: grep the word under the cursor in cwd" })

km("v", "<leader>fw", function()
	fzf().grep_visual()
end, { desc = "Fzf: grep the visual selection" })

km("n", "<leader>fl", function()
	fzf().blines()
end, { desc = "Fzf: search lines in the current buffer" })

km("n", "<leader>fh", function()
	fzf().help_tags()
end, { desc = "Fzf: search Neovim help tags" })

km("n", "<leader>fm", function()
	fzf().man_pages()
end, { desc = "Fzf: search man pages" })

km("n", "<leader>fx", function()
	fzf().diagnostics_document()
end, { desc = "Fzf: list LSP diagnostics in current buffer" })

km("n", "<leader>fX", function()
	fzf().diagnostics_workspace()
end, { desc = "Fzf: list LSP diagnostics in workspace" })

km("n", "<leader>fk", function()
	fzf().keymaps()
end, { desc = "Fzf: search all keymaps" })

km("n", "<leader>fc", function()
	fzf().resume()
end, { desc = "Fzf: resume the last picker with its previous query" })

-- Notes buffers also trigger the load, so the obsidian picker resolves before
-- any picker was opened.
require("lib.lazy").setup({
	src = "https://github.com/ibhagwan/fzf-lua",
	filetypes = { "markdown" },
	after = M.after,
})

return M
