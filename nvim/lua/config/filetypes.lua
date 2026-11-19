-- lua/config/filetypes.lua

-- Filetype detection that Neovim's runtime misses. Most config formats are
-- already covered upstream, so add an entry only when `:setfiletype` is wrong.
--
-- See: :help vim.filetype.add

vim.filetype.add({
	filename = {
		[".env"] = "dosini",
	},
	pattern = {
		-- variants such as `.env.local`. No leading `/` in the pattern, so a
		-- relative buffer name like `.env.local` also matches.
		["%.env%..*"] = "dosini",
	},
})
