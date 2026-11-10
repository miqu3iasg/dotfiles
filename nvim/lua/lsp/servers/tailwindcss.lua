-- lua/lsp/servers/tailwindcss.lua

-- Tailwind CSS class completion, hover and color hints, attached to HTML, CSS
-- and React buffers and to templ templates, which map to HTML through
-- `includeLanguages`.
--
-- :MasonInstall tailwindcss-language-server
--
-- See: https://github.com/tailwindlabs/tailwindcss-intellisense

return {
	config = {
		filetypes = { "templ", "html", "css", "javascriptreact", "typescriptreact" },
		settings = {
			tailwindCSS = {
				includeLanguages = { templ = "html" },
				-- Detects classes inside helper calls such as `cn("...")`.
				classFunctions = { "cn", "clsx", "cx", "cva", "tv", "twMerge" },
			},
		},
	},
}
