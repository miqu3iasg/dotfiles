-- lua/config/filetypes.lua

-- Filetype detection that Neovim's runtime misses. Only add entries here
-- when `:setfiletype` did not pick the right type; most common configs
-- (zsh, systemd, ignore files, *.conf, *.rc json) are already covered
-- upstream.

vim.filetype.add({
	filename = {
		-- dotenv files
		[".env"] = "dosini",
	},
	pattern = {
		-- variants such as `.env.local`. No leading `/` in the pattern, so a
		-- relative buffer name like `.env.local` also matches.
		["%.env%..*"] = "dosini",
	},
})
