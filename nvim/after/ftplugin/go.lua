-- after/ftplugin/go.lua

-- gofmt style, the single standard the Go community formats code with.
-- The runtime ftplugin already sets what gofmt needs: hard tabs for
-- indentation (`noexpandtab`, `softtabstop=0`, `shiftwidth=0`), `//` comments
-- and section movements. This file only adds what it lacks: the tab display
-- width, the line limit of `golines`, comment continuation, and terminal
-- keymaps for the `go` toolchain, following the shape of `java.lua`.
--
-- The indentation is final on purpose: `go run` on save runs gofmt and would
-- rewrite anything else, so the buffer options below are what `gofmt` itself
-- expects.
--
-- The `go` CLI comes from the distribution:
--
-- $ sudo pacman -S go
--
-- See: after/ftplugin/java.lua
-- See: lua/plugins/formatting.lua (goimports-reviser, golines)
-- See: lua/language/servers/gopls.lua
-- See: https://go.dev/doc/effective_go#formatting

local opt = vim.opt_local

opt.tabstop = 4 -- Display width of a tab; gofmt only cares about tabs themselves.
opt.textwidth = 100 -- Matches `golines --max-len=100` in conform.
opt.formatoptions:append("croql") -- Continue // comments.

local function map(lhs, rhs, desc)
	vim.keymap.set("n", lhs, rhs, { buffer = true, silent = true, desc = desc })
end

---Run a `go` command in a terminal split from the module root, which is the
---nearest directory with a `go.mod` or `go.work`, falling back to the file's
---directory for module-less programs.
---@param subcmd string Arguments passed to `go`.
local function go_term(subcmd)
	local root = vim.fs.root(0, { "go.mod", "go.work" })
	vim.cmd(("split | lcd %s | terminal go %s"):format(
		vim.fn.fnameescape(root or vim.fn.expand("%:p:h")),
		subcmd
	))
end

map("<leader>jr", function()
	go_term("run .")
end, "Go: run current package")

map("<leader>jt", function()
	go_term("test ./...")
end, "Go: run tests")

map("<leader>jb", function()
	go_term("build ./...")
end, "Go: build packages")
