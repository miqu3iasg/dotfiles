-- lua/language/servers/tailwindcss.lua

-- Tailwind CSS completion, hover and color hints, with templ mapped to HTML
-- and the class helpers found inside calls such as `cn("...")`.
--
-- tailwindcss-language-server comes from Mason.
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
				classFunctions = { "cn", "clsx", "cx", "cva", "tv", "twMerge" },
			},
		},
	},
}
