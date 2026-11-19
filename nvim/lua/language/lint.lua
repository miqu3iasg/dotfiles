-- lua/language/lint.lua

-- External linters through nvim-lint. Python is the only linted language
-- right now, with ruff, the same tool conform uses for formatting.
--
-- Ruff reads its rules from the project, so none live here.
--
-- Ruff comes from Mason or the system.
--
-- :MasonInstall ruff
-- $ sudo pacman -S ruff
--
-- See: lua/language/init.lua
-- See: https://github.com/mfussenegger/nvim-lint

local lint = require("lint")

---@class LanguageLint
local M = {}

lint.linters_by_ft = {
	python = { "ruff" },
}

-- Separate namespace, so linting toggles without touching server diagnostics.
local ruff_namespace = lint.get_namespace("ruff")

local lint_enabled = true

---Run the linters of the current buffer, but only while linting is enabled.
local function try_lint()
	if lint_enabled then
		lint.try_lint()
	end
end

---Enable or disable linting at once.
---@param enable? boolean Force a state; omit to toggle.
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

---Reapply the lint state after the diagnostics display is toggled on.
--- See: lua/config/keymaps/misc.lua
function M.resync()
	if not lint_enabled then
		vim.diagnostic.enable(false, { ns_id = ruff_namespace })
	end
end

vim.api.nvim_create_autocmd({ "BufWritePost", "FileType" }, {
	group = vim.api.nvim_create_augroup("Linting", { clear = true }),
	callback = try_lint,
})

vim.keymap.set("n", "<leader>ui", function()
	toggle_lint()
end, { desc = "Toggle linting" })

return M
