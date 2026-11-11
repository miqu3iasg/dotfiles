-- after/ftplugin/asm.lua

-- Matches the layout that `asmfmt` produces: tabs for indentation and blanks
-- for alignment, labels at column zero and one tab of indent for instructions.
-- Comment alignment is left to the formatter, which aligns each comment block.
--
-- See: lua/plugins/formatting.lua (asmfmt)
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
