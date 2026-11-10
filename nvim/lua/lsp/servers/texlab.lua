-- lua/lsp/servers/texlab.lua

-- LaTeX through texlab, which provides completion, hover and navigation. The
-- settings here only change how completion matches: fuzzy matching lets
-- abbreviations such as "thm" and "eqn" find "\theorem" and
-- "\begin{equation}". Compilation stays with VimTeX, not with the server.
--
-- :MasonInstall texlab
--
-- See: lua/plugins/latex.lua
-- See: https://github.com/latex-lsp/texlab

return {
	config = {
		settings = { texlab = { completion = { matcher = "fuzzy-ignore-case" } } },
	},
}
