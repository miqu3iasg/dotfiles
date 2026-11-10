-- lua/plugins/markdown.lua

-- Markdown note-taking workflow built on obsidian.nvim and img-clip.nvim, with
-- the Arcanum vault as the only workspace. obsidian.nvim provides wikilink
-- navigation, completion and the other Obsidian features. Everything that
-- creates, names, promotes, renames or searches notes lives in
-- `lua/features/notes.lua`, and the keymaps below only delegate to it.
--
-- The vault is `$ARCANUM_DIR`, or `~/documents/arcanum` when unset. It must
-- already exist. Notes live directly in its root, templates in `_templates/`
-- and pasted images in `attachments/`. The personal Obsidian vault is not
-- configured here and is only used through the Obsidian app.
--
-- Notes are searched through fzf-lua, so `fzf.lua` must be loaded before this
-- file. obsidian.nvim, img-clip.nvim and plenary.nvim must be installed through
-- the plugin manager.
--
-- Markdown preview in the browser comes from markdown-preview.nvim. It is
-- configured through `vim.g.mkdp_*` globals, which must be set before the
-- plugin loads, and it is toggled with `<leader>op`. The plugin needs Node.js
-- and a one-time install step, which the plugin manager must run as its
-- build hook (`:call mkdp#util#install()`).
--
-- Pasted images are saved in `<vault>/attachments`. Inside the vault they use
-- the wikilink template, and anywhere else they use the standard Markdown
-- link.
--
-- Markdown language-server features require Marksman to be both installed and
-- enabled in `lua/lsp/`. The Obsidian app is only needed to open
-- notes in it. On Arch Linux:
--
-- $ sudo pacman -S obsidian
--
-- Install Marksman through Mason:
--
-- :MasonInstall marksman
--
-- See: lua/features/notes.lua
-- See: after/ftplugin/markdown.lua
-- See: lua/lsp/servers/marksman.lua
-- See: ~/.local/bin/nt
-- See: https://github.com/HakonHarnes/img-clip.nvim
-- See: https://github.com/obsidian-nvim/obsidian.nvim
-- See: https://github.com/nvim-lua/plenary.nvim
-- See: https://github.com/ibhagwan/fzf-lua
-- See: https://github.com/iamcco/markdown-preview.nvim

local notes = require("features.notes")

local VAULT_PATH = notes.vault()

local km = vim.keymap.set

notes.setup()

require("img-clip").setup({
	default = {
		dir_path = function()
			if notes.is_note_path(vim.api.nvim_buf_get_name(0)) then
				return VAULT_PATH .. "/attachments"
			end
			local root = vim.fs.root(0, { ".git", ".obsidian" }) or vim.fn.expand("%:p:h")
			return root .. "/attachments"
		end,
		relative_to_current_file = false,
		relative_template_path = true,
		use_absolute_path = false,
		file_name = "%Y-%m-%d-%H-%M-%S",
		prompt_for_file_name = false,
		insert_mode_after_paste = false,
		embed_image_as_base64 = false,
		verbose = false,
		drag_and_drop = {
			enabled = true,
			insert_mode = true,
		},
	},

	filetypes = {
		markdown = {
			url_encode_path = true,
			template = "![$CURSOR]($FILE_PATH)",
			download_images = true,
		},
	},

	dirs = {
		[VAULT_PATH] = {
			url_encode_path = false,
			template = "![[$FILE_NAME]]",
		},
	},
})

vim.g.mkdp_auto_start = 0
vim.g.mkdp_auto_close = 1
vim.g.mkdp_refresh_slow = 0
vim.g.mkdp_theme = "dark"
vim.g.mkdp_filetypes = { "markdown" }
vim.g.mkdp_echo_preview_url = 1
vim.g.mkdp_page_title = "${name}"

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("markdown_preview_keymap", { clear = true }),
	pattern = "markdown",
	callback = function()
		km("n", "<leader>op", "<cmd>MarkdownPreviewToggle<cr>", {
			buffer = true,
			silent = true,
			desc = "Toggle browser preview",
		})
	end,
})

km("n", "<leader>od", notes.new_draft, { desc = "Quick draft" })
km("n", "<leader>on", notes.new_note, { desc = "New note (pick type and title)" })
km("n", "<leader>ot", notes.template, { desc = "Insert template" })
km("n", "<leader>of", notes.find_files, { desc = "Find notes by name" })
km("n", "<leader>og", notes.grep, { desc = "Search note contents" })
km("n", "<leader>ol", notes.last, { desc = "Reopen the last note" })
km("n", "<leader>ov", notes.open_vault, { desc = "Open the vault folder" })
km("n", "<leader>ow", "<cmd>e ~/TODO.md<cr>", { desc = "Open TODO file" })

local opts = {
	legacy_commands = false,

	workspaces = {
		{ name = "Arcanum", path = VAULT_PATH },
	},
	-- Notes are created by features.notes, which owns names, templates and dates.
	new_notes_location = "current_dir",

	ui = {
		enable = false,
	},
	footer = {
		enabled = false,
	},
	frontmatter = {
		enabled = false,
	},

	link = {
		style = "wiki",
		format = "shortest",
	},
	attachments = {
		folder = "attachments",
	},
	completion = {
		min_chars = 2,
		match_case = true,
		create_new = false,
	},
	picker = {
		name = "fzf-lua",
	},
}

require("obsidian").setup(opts)

vim.api.nvim_create_autocmd("CmdlineChanged", {
	group = vim.api.nvim_create_augroup("obsidian_cmdline_wildtrigger", { clear = true }),
	callback = function()
		if vim.fn.getcmdtype() ~= ":" then
			return
		end
		local cmdline = vim.fn.getcmdline()
		if not cmdline:match("^Obsidian[A-Za-z0-9]*$") then
			return
		end
		vim.fn.wildtrigger()
	end,
})

vim.api.nvim_create_autocmd("User", {
	pattern = "ObsidianNoteEnter",
	callback = function()
		local function map(lhs, rhs, desc)
			km("n", lhs, rhs, {
				buffer = true,
				silent = true,
				desc = desc,
			})
		end

		map("<leader>oo", "<cmd>Obsidian open<cr>", "Open this note in the Obsidian app")
		map("<leader>or", "<cmd>Obsidian rename<cr>", "Rename note by title")
		map("<leader>ob", "<cmd>Obsidian backlinks<cr>", "Backlinks of this note")
		map("<leader>oi", "<cmd>Obsidian links<cr>", "Links in this note")

		km("v", "<leader>ok", "<cmd>Obsidian link<cr>", {
			buffer = true,
			silent = true,
			desc = "Link selection to existing note",
		})
	end,
})
