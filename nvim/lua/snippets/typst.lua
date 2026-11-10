-- lua/snippets/typst.lua

-- Typst snippets for the most frequent markup: headings, emphasis and code
-- blocks. The server side of Typst lives in tinymist.
--
-- See: lua/language/servers/tinymist.lua
-- See: lua/plugins/formatting.lua

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
	-- Heading. Repeat `=` for deeper levels, e.g. `== Section`.
	s("h", {
		t("= "),
		i(1, "Title"),
		i(0),
	}),

	-- Emphasis.
	s("em", {
		t("_"),
		i(1),
		t("_"),
		i(0),
	}),

	-- Code block.
	s("code", {
		t({ "```", "" }),
		i(1),
		t({ "", "```" }),
		i(0),
	}),
}
