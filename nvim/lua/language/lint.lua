-- lua/language/lint.lua

-- External linters through nvim-lint, kept apart from `lua/language/servers/`
-- because linters do not start a server: each one is a command-line tool run on
-- demand, and its findings are attached to the buffer as plain diagnostics.
-- Python is the only linted language right now, with ruff.
--
-- Ruff replaces flake8 (pyflakes and pycodestyle) and is orders of magnitude
-- faster. It is the same tool conform uses for formatting, so no extra
-- dependency enters the config. Mason can install it:
--
-- :MasonInstall ruff
--
-- $ sudo pacman -S ruff
--
-- Ruff reads its options from the project's `pyproject.toml`, `ruff.toml` or
-- `.ruff.toml`, so per-project rules need no configuration here. `ruff format`
-- is deliberately not run as a linter rule, since formatting stays with
-- conform.
--
-- The toggle below follows the same shape as the server toggle of
-- `lua/language/init.lua`, and lint jobs are skipped while linting is off. Lint
-- findings are plain diagnostics, so they only show up when the global
-- diagnostics display is on as well.
--
-- See: lua/language/init.lua
-- See: lua/config/keymaps/misc.lua
-- See: https://github.com/mfussenegger/nvim-lint
-- See: https://docs.astral.sh/ruff

local lint = require("lint")

lint.linters_by_ft = {
	python = { "ruff" },
}

-- Namespace of the ruff diagnostics, so linting can be switched off without
-- touching the diagnostics that come from the language servers.
local ruff_namespace = lint.get_namespace("ruff")

local lint_enabled = true

---Run the linters of the current buffer, but only while linting is enabled.
local function try_lint()
	if lint_enabled then
		lint.try_lint()
	end
end

---Enable or disable linting at once. Disabling hides the ruff diagnostics
---through the namespace and stops new lint runs, while enabling shows the
---diagnostics again and lints the current buffer right away.
---@param enable? boolean Forces a state. When omitted, the current state is toggled.
---@return boolean enabled The new state.
local function toggle_lint(enable)
	if enable == nil then
		lint_enabled = not lint_enabled
	else
		lint_enabled = enable
	end

	if lint_enabled then
		vim.diagnostic.enable(true, { ns_id = ruff_namespace })
		lint.try_lint()
	else
		vim.diagnostic.enable(false, { ns_id = ruff_namespace })
	end

	vim.notify("Linting " .. (lint_enabled and "enabled" or "disabled"), vim.log.levels.INFO)

	return lint_enabled
end

vim.api.nvim_create_autocmd({ "BufWritePost", "FileType" }, {
	group = vim.api.nvim_create_augroup("Linting", { clear = true }),
	callback = try_lint,
})

vim.keymap.set("n", "<leader>uL", function()
	toggle_lint()
end, { desc = "Toggle linting" })
