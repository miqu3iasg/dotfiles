-- lua/lsp/servers/texlab.lua

-- LaTeX through texlab, which provides completion, hover, navigation, build
-- support and document diagnostics. Abbreviations such as "thm" and "eqn"
-- match "\theorem" and "\begin{equation}" through the fuzzy matcher, and
-- chktex runs on open and save for structural warnings. Compilation stays with
-- VimTeX (see lua/plugins/latex.lua), and texlab only backs the server `build`
-- and `forwardSearch` requests.
--
-- :MasonInstall texlab
--
-- $ sudo pacman -S texlive-basic texlive-latex texlive-latexextra texlive-binextra
--
-- See: lua/plugins/latex.lua
-- See: https://github.com/latex-lsp/texlab

---@type UserLspServerModule
return {
	config = {
		settings = {
			texlab = {
				completion = { matcher = "fuzzy-ignore-case" },
				build = {
					executable = "latexmk",
					args = { "-pdf", "-interaction=nonstopmode", "-synctex=1", "%f" },
					forwardSearchAfter = false,
					onSave = false,
				},
				chktex = { onOpenAndSave = true },
			},
		},
	},
}
