-- lua/lsp/servers/tailwindcss.lua

-- Tailwind CSS class completion, hover and color hints, attached to HTML, CSS,
-- SCSS and React buffers, to templ templates, which map to HTML through
-- `includeLanguages`, and to plain JavaScript and TypeScript, where helper
-- calls build the class string.
--
-- :MasonInstall tailwindcss-language-server
--
-- See: https://github.com/tailwindlabs/tailwindcss-intellisense

---@type UserLspServerModule
return {
	config = {
		filetypes = { "templ", "html", "css", "scss", "javascript", "javascriptreact", "typescript", "typescriptreact" },
		settings = {
			tailwindCSS = {
				includeLanguages = { templ = "html" },
				-- Detects classes inside helper calls such as `cn("...")`.
				classFunctions = { "cn", "clsx", "cx", "cva", "tv", "twMerge" },
			},
		},
	},
}
