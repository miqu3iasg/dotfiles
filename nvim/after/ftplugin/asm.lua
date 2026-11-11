-- after/ftplugin/asm.lua

-- Matches the layout that `asmfmt` produces: tabs for indentation and blanks
-- for alignment, labels at column zero and one tab of indent for instructions.
-- Comment alignment is left to the formatter, which aligns each comment block.
--
-- `<localleader>la` aligns the columns of the block around the cursor (or of
-- the selection) interactively, with the same rules asmfmt uses on format.
--
-- See: lua/plugins/formatting.lua (asmfmt)
-- See: lua/modules/asm_align.lua
-- See: https://github.com/klauspost/asmfmt

local opt = vim.opt_local

opt.expandtab = false
opt.tabstop = 8
opt.shiftwidth = 8
opt.softtabstop = 8

-- The formatter enforces no line limit, but 80 columns keeps comments and
-- operand columns inside the classic assembly page width.
opt.textwidth = 80

opt.commentstring = "// %s"
opt.comments = "s1:/*,mb:*,ex:*/,://"

-- Never wrap code, only comments.
opt.formatoptions:append("cro")
opt.formatoptions:remove("t")

---@param mode string|string[]
---@param lhs string
---@param rhs string|fun()
---@param desc string
local function map(mode, lhs, rhs, desc)
	vim.keymap.set(mode, lhs, rhs, { buffer = true, silent = true, desc = desc })
end

map({ "n", "x" }, "<localleader>la", require("modules.asm_align").action(), "Asm: align block")
