-- lua/plugins/formatting.lua

-- Formatting through conform.nvim, which runs external formatters on demand
-- and on save.
--
-- Every formatter is an external executable and must be on PATH.
--
-- $ sudo pacman -S nodejs npm clang shfmt taplo-cli astyle nixfmt perltidy scalafmt buf
-- $ npm install -g prettier prettierd sql-formatter elm-format
-- $ pip install xmlformatter
-- $ gem install rubocop
-- $ R -e 'install.packages("styler")'
--
-- See: lua/lib/autoformat.lua
-- See: lua/modules/markdown_lists.lua
-- See: https://github.com/stevearc/conform.nvim

local autoformat = require("lib.autoformat")

vim.keymap.set("n", "<leader>k", function()
	require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "Format buffer" })

vim.keymap.set("n", "<leader>uf", autoformat.toggle, { desc = "Toggle autoformat" })

require("conform").setup({
	notify_on_error = true,
	formatters_by_ft = {
		lua = { "stylua" },
		c = { "clang_format" },
		cpp = { "clang_format" },
		java = { "astyle" },
		python = { "ruff_organize_imports", "ruff_format" },
		sh = { "shfmt" },
		bash = { "shfmt" },
		javascript = { "prettierd", "prettier", stop_after_first = true },
		javascriptreact = { "prettierd", "prettier", stop_after_first = true },
		typescript = { "prettierd", "prettier", stop_after_first = true },
		typescriptreact = { "prettierd", "prettier", stop_after_first = true },
		html = { "prettierd", "prettier", stop_after_first = true },
		css = { "prettierd", "prettier", stop_after_first = true },
		scss = { "prettierd", "prettier", stop_after_first = true },
		json = { "prettierd", "prettier", stop_after_first = true },
		jsonc = { "prettierd", "prettier", stop_after_first = true },
		yaml = { "yamlfmt" },
		toml = { "taplo" },
		xml = { "xmlformatter" },
		sql = { "sql_formatter" },
		dockerfile = { "dockerfmt" },
		terraform = { "terraform_fmt" },
		markdown = { "prettier_md" },
		asm = { "asmfmt" },

		-- Runs on filetypes that have no formatter of their own.
		["_"] = { "trim_whitespace", "trim_newlines" },
	},
	formatters = {
		["google-java-format"] = {
			prepend_args = { "--aosp", "--skip-javadoc-formatting" },
		},

		astyle = {
			prepend_args = { "--style=allman", "--indent=spaces=4" },
		},

		clang_format = {
			-- Reads the style from `~/.clang-format`, which links to
			-- `~/dotfiles/clang/.clang-format`.
			prepend_args = { "--style=file" },
		},

		-- Prettier with 4 columns of indentation and prose-wrap preserve, using
		-- the CLI because prettierd accepts no flags.
		prettier_md = require("conform.util").merge_formatter_configs(require("conform.formatters.prettier"), {
			prepend_args = { "--tab-width", "4", "--prose-wrap", "preserve" },
		}),

		shfmt = {
			prepend_args = { "-i", "2", "-ci" },
		},

		sql_formatter = {
			prepend_args = {
				"-l",
				"mysql",
				"-c",
				'{"keywordCase":"upper","dataTypeCase":"upper","functionCase":"upper","tabWidth":4}',
			},
		},
	},
	format_on_save = function(bufnr)
		if not autoformat.enabled(bufnr) then
			return
		end
		return { timeout_ms = 2000, lsp_format = "fallback" }
	end,
})
