-- lua/config/health.lua

-- Health check for the external executables the features rely on, runnable as
-- `:checkhealth config` and discovered by a bare `:checkhealth`. The language
-- servers, which are installed through Mason, are not checked here.
--
-- A tool whose absence breaks a core feature, such as ripgrep, is reported as
-- an error. Per-language tools, such as formatters, are warnings: the features
-- that use them degrade gracefully when the tool is missing.
--
-- The requirements and their per-file documentation live in README.md and in
-- the header of each consumer.
--
-- See: lua/config/options.lua (grepprg)
-- See: lua/lib/search.lua
-- See: lua/plugins/fzf.lua
-- See: :help checkhealth

local M = {}

---Report one executable requirement.
---@param tool string
---@param why string What the tool feeds.
---@param optional? boolean Warn instead of error when missing.
local function check_tool(tool, why, optional)
	if vim.fn.executable(tool) == 1 then
		vim.health.ok(("%s is installed (%s)"):format(tool, why))
	elseif optional then
		vim.health.warn(("%s is not installed (optional: %s)"):format(tool, why))
	else
		vim.health.error(("%s is not installed (%s)"):format(tool, why))
	end
end

---Base tools, needed by several features at once.
local function check_base()
	vim.health.start("base tools")

	check_tool("git", "statusline branch, fugitive and gitsigns")
	check_tool("tmux", "split navigation through vim-tmux-navigator", true)
	check_tool("rg", "'grepprg', :Grep and lib/substitute.lua")
	check_tool("fzf", "fzf-lua")
	check_tool("fd", "fzf-lua file pickers")
	check_tool("node", "language servers installed through Mason")
	check_tool("npm", "language servers installed through Mason")

	-- LuaSnip compiles jsregexp with `make` at install and update time and only
	-- warns when it fails, so the missing toolchain is a warning.
	check_tool("make", "LuaSnip jsregexp build", true)
	check_tool("cc", "LuaSnip jsregexp build", true)
end

---Formatters run by conform on demand and on save. Missing ones only disable
---the format of their filetype.
local function check_formatters()
	vim.health.start("formatters (conform)")

	check_tool("stylua", "Lua", true)
	check_tool("clang-format", "C and C++", true)
	check_tool("astyle", "Java", true)
	check_tool("ruff", "Python", true)
	check_tool("shfmt", "shell", true)
	check_tool("yamlfmt", "YAML", true)
	check_tool("taplo", "TOML", true)
	check_tool("latexindent", "LaTeX", true)
	check_tool("asmfmt", "assembly", true)
	check_tool("sql-formatter", "SQL", true)
	check_tool("prettierd", "web filetypes", true)
	check_tool("prettier", "web filetypes, fallback of prettierd", true)
end

---Markdown export and preview through pandoc, and the LaTeX toolchain that
---texlab and VimTeX rely on.
local function check_documents()
	vim.health.start("documents")

	check_tool("pandoc", "Pandoc export and preview", true)
	check_tool("zathura", "PDF preview", true)
	check_tool("latexmk", "LaTeX compilation through VimTeX", true)
	check_tool("chktex", "texlab lint options", true)
end

---Java tools, used by the jdtls module, which is started outside the LSP stack.
local function check_java()
	vim.health.start("java")

	check_tool("java", "jdtls", true)
	check_tool("python3", "jdtls installation", true)
end

function M.check()
	check_base()
	check_formatters()
	check_documents()
	check_java()
end

return M
