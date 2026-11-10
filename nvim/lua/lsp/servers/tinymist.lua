-- lua/lsp/servers/tinymist.lua

-- Typst through tinymist, with typstyle as the formatter and PDF export on
-- save. Export targets the same root and layout as the latexmk and pandoc
-- exporters, which `lua/shared/exports.lua` defines once for all of them.
--
-- Mason installs the server, but the `typst` CLI and `typstyle` come from the
-- distribution:
--
-- $ sudo pacman -S typst typstyle
--
-- See: lua/shared/exports.lua
-- See: https://github.com/Myriad-Dreamin/tinymist

return {
	config = {
		-- Uses the same root as the other exporters.
		root_dir = function(bufnr, on_dir)
			on_dir(require("shared.exports").root(bufnr))
		end,
		settings = {
			formatterMode = "typstyle",
			exportPdf = "onSave",
			-- Mirrors `exports.output_path()`.
			outputPath = require("shared.exports").output_pattern(),
			-- Highlighting comes from treesitter only.
			semanticTokens = "disable",
			lint = { enabled = false },
		},
	},
}
