-- lua/lsp/lint.lua

-- External linters through nvim-lint, kept apart from `lua/lsp/servers/`
-- because linters do not start a server: each one is a command-line tool run on
-- demand, and its findings are attached to the buffer as plain diagnostics.
-- Python is the only linted language right now, with flake8.
--
-- Flake8 can come from Mason or from the distribution. Mason prepends its bin
-- folder to the PATH visible to Neovim, so either source works:
--
-- :MasonInstall flake8
--
-- $ sudo pacman -S python-flake8
--
-- Flake8 reads its options from the project's `setup.cfg`, `.flake8` or
-- `tox.ini`, so per-project rules need no configuration here.
--
-- The toggle below follows the same shape as the server toggle of
-- `lua/lsp/init.lua`, and lint jobs are skipped while linting is off. Lint
-- findings are plain diagnostics, so they only show up when the global
-- diagnostics display is on as well.
--
-- See: lua/lsp/init.lua
-- See: lua/config/keymaps/misc.lua
-- See: https://github.com/mfussenegger/nvim-lint
-- See: https://flake8.pycqa.org

local lint = require("lint")

lint.linters_by_ft = {
	python = { "flake8" },
}

-- Namespace of the flake8 diagnostics, so linting can be switched off without
-- touching the diagnostics that come from the language servers.
local flake8_namespace = lint.get_namespace("flake8")

local lint_enabled = true

---Run the linters of the current buffer, but only while linting is enabled.
local function try_lint()
	if lint_enabled then
		lint.try_lint()
	end
end

---Enable or disable linting at once. Disabling hides the flake8 diagnostics
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
		vim.diagnostic.enable(true, { ns_id = flake8_namespace })
		lint.try_lint()
	else
		vim.diagnostic.enable(false, { ns_id = flake8_namespace })
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
