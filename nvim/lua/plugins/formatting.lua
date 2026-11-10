-- lua/plugins/formatting.lua

-- Formatting through conform.nvim, which runs external formatters on demand and
-- on save, with a chain of formatters per filetype.
--
-- Conform runs external formatter executables, so they must be on PATH. Mason
-- can install many of them, such as stylua, ruff, rustfmt, google-java-format,
-- fourmolu, yamlfmt, ktlint, swiftformat and zigfmt, but the ones below may
-- need to be installed manually.
--
-- On Arch Linux, most system-level formatters come from pacman: Node.js for the
-- web formatters, clang-format for C and C++, Go, a TeX distribution with
-- latexindent for LaTeX, typstyle for Typst, shfmt for shell, taplo for TOML,
-- astyle for Java, nixfmt, perltidy, scalafmt and buf for Protobuf:
--
-- $ sudo pacman -S nodejs npm clang go texlive-basic texlive-bin texlive-latexextra texlive-fontsextra typstyle shfmt taplo-cli astyle nixfmt perltidy scalafmt buf
--
-- JavaScript, TypeScript, HTML, CSS, JSON, Markdown, GraphQL and Vue use
-- Prettier. Prettierd is preferred when available, and Conform falls back to
-- Prettier through `stop_after_first = true`. Both can also come from Mason. SQL
-- and Elm formatting are Node-based too:
--
-- $ npm install -g prettier prettierd sql-formatter elm-format
--
-- Markdown uses `prettier` instead of `prettierd` so that `--tab-width 4` can be
-- passed. The `*` and `+` bullets are preserved by extra steps, which are
-- explained next to `md_stash_bullets`.
--
-- Astro formatting needs the Astro CLI, which should come from the project's own
-- dependencies rather than a global install:
--
-- $ npm install astro
--
-- The remaining formatters come from other package managers:
--
-- $ pip install xmlformatter
--
-- $ gem install rubocop
--
-- $ R -e 'install.packages("styler")'
--
-- Some formatters need no separate install because they ship with their language
-- tooling, such as `mix format` with Elixir and `terraform fmt` with Terraform.
-- The binaries for Julia (runic), Clojure (cljfmt) and Dockerfile (dockerfmt)
-- must be installed by hand or through Mason.
--
-- See: lua/lib/autoformat.lua
-- See: lua/modules/markdown_lists.lua
-- See: https://github.com/stevearc/conform.nvim

local autoformat = require("lib.autoformat")

vim.keymap.set("n", "<leader>k", function()
	require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "Format buffer" })

vim.keymap.set("n", "<leader>uf", autoformat.toggle, { desc = "Toggle autoformat" })

local md_lists = require("modules.markdown_lists")

---Bullet markers saved by buffer while a markdown format is running.
---@type table<integer, string[]>
local md_bullets = {}

require("conform").setup({
	notify_on_error = true,
	formatters_by_ft = {
		lua = { "stylua" },
		go = { "goimports-reviser", "golines" },
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
		markdown = { "md_stash_bullets", "prettier_md", "md_restore" },
		tex = { "latexindent" },
		typst = { "typstyle" },
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
			-- Reads the style from `~/.clang-format`.
			-- See: resources/clang-format.example.yaml
			prepend_args = { "--style=file" },
		},

		golines = {
			prepend_args = { "--base-formatter=gofumpt", "--max-len=100" },
		},

		-- Prettier with 4 columns of indentation, so nested lists get 4. It uses
		-- `prettier` instead of `prettierd` because prettierd does not accept
		-- command-line flags.
		prettier_md = require("conform.util").merge_formatter_configs(require("conform.formatters.prettier"), {
			prepend_args = { "--tab-width", "4" },
		}),

		-- Prettier rewrites the `*` and `+` bullets as `-`, or alternates `-` and
		-- `*` between neighbouring lists. This step and `md_restore` save the
		-- markers before formatting and put them back afterwards.
		md_stash_bullets = {
			format = function(_, ctx, lines, callback)
				md_bullets[ctx.buf] = md_lists.bullet_markers(lines)
				callback(nil, lines)
			end,
		},

		-- Prettier never writes tabs in lists, so each group of 4 leading spaces
		-- becomes a tab. Setting `vim.g.markdown_use_tabs = false` turns that off.
		-- See: after/ftplugin/markdown.lua
		md_restore = {
			format = function(_, ctx, lines, callback)
				lines = md_lists.restore_bullets(lines, md_bullets[ctx.buf])
				md_bullets[ctx.buf] = nil
				if vim.g.markdown_use_tabs ~= false then
					lines = md_lists.tabify(lines, 4)
				end
				callback(nil, lines)
			end,
		},

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
