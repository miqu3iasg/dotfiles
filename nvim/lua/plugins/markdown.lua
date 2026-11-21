-- lua/plugins/markdown.lua

-- Markdown note-taking through obsidian.nvim and img-clip.nvim. Note creation,
-- naming and search live in `lua/modules/notes.lua`.
--
-- The vault is `$ARCANUM_DIR`, or `~/dev/arcanum` when unset, and must exist.
--
-- $ sudo pacman -S obsidian
-- :MasonInstall marksman
-- :packadd markdown-preview.nvim
--
-- See: lua/modules/notes.lua
-- See: after/ftplugin/markdown.lua
-- See: ~/.local/bin/nt
-- See: https://github.com/obsidian-nvim/obsidian.nvim
-- See: https://github.com/iamcco/markdown-preview.nvim

local notes = require("modules.notes")

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

-- Run this manually after installing or updating the plugin, otherwise the
-- preview stays empty; `vim.pack` cannot run it.
-- :call mkdp#util#install()
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

km("n", "<leader>oa", notes.new_draft, { desc = "Quick draft" })
km("n", "<leader>oc", notes.capture, { desc = "Capture task into TODO.md" })
km("n", "<leader>on", notes.new_note, { desc = "New note (pick type and title)" })
km("n", "<leader>od", notes.daily, { desc = "Open today's daily note" })
km("n", "<leader>ot", notes.template, { desc = "Insert template" })
km("n", "<leader>of", notes.find_files, { desc = "Find notes by name" })
km("n", "<leader>og", notes.grep, { desc = "Search note contents" })
km("n", "<leader>ol", notes.last, { desc = "Reopen the last note" })
km("n", "<leader>ov", notes.open_vault, { desc = "Open the vault folder" })
km("n", "<leader>ow", "<cmd>e ~/dev/arcanum/TODO.md<cr>", { desc = "Open TODO file" })

km("n", "<leader>ok", function()
	notes.daily(1)
end, { desc = "Open tomorrow's daily note" })

km("n", "<leader>oj", function()
	notes.daily(-1)
end, { desc = "Open yesterday's daily note" })

local opts = {
	legacy_commands = false,

	workspaces = {
		{ name = vim.fs.basename(VAULT_PATH), path = VAULT_PATH },
	},
	-- Notes are created by modules.notes, which owns names, templates and dates.
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
		if not cmdline:match("^(Obsidian|Notes)[A-Za-z0-9]*$") then
			return
		end
		vim.fn.wildtrigger()
	end,
})

vim.api.nvim_create_autocmd("User", {
	pattern = "ObsidianNoteEnter",
	callback = function()
		local bmap = require("lib.keys").bmap

		bmap("n", "<leader>oo", "<cmd>Obsidian open<cr>", "Open this note in the Obsidian app")
		bmap("n", "<leader>or", "<cmd>Obsidian rename<cr>", "Rename note by title")
		bmap("n", "<leader>ob", "<cmd>Obsidian backlinks<cr>", "Backlinks of this note")
		bmap("n", "<leader>oi", "<cmd>Obsidian links<cr>", "Links in this note")
		bmap("v", "<leader>ok", "<cmd>Obsidian link<cr>", "Link selection to existing note")
	end,
})
