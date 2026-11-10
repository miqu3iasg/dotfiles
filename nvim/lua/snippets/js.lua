-- lua/snippets/js.lua

-- JavaScript snippets for JSDoc documentation comments, the standard that
-- editors and language servers read in both JavaScript and TypeScript. The
-- TypeScript alias and the react filetypes inherit this file through the
-- completions module. Indentation assumes two spaces.
--
-- See: https://jsdoc.app
-- See: https://www.typescriptlang.org/docs/handbook/jsdoc-supported-types.html

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
	-- Function documentation, above the function. Duplicate the @param lines
	-- as needed and remove @returns when the function returns nothing.
	s("doc", {
		t({ "/**", " * " }),
		i(1, "Description."),
		t({ "", " * @param " }),
		i(2, "name"),
		t(" - "),
		i(3, "Description."),
		t({ "", " * @param " }),
		i(4, "name"),
		t(" - "),
		i(5, "Description."),
		t({ "", " * @returns " }),
		i(6, "Description."),
		t({ "", " */" }),
		i(0),
	}),

	-- Function documentation without @returns, for functions that return
	-- nothing.
	s("docv", {
		t({ "/**", " * " }),
		i(1, "Description."),
		t({ "", " * @param " }),
		i(2, "name"),
		t(" - "),
		i(3, "Description."),
		t({ "", " */" }),
		i(0),
	}),

	-- Class documentation, above the class.
	s("docc", {
		t({ "/**", " * " }),
		i(1, "Class description."),
		t({ "", " */" }),
		i(0),
	}),

	-- Parameter line, to add one more @param inside an existing block.
	s("docp", {
		t(" * @param "),
		i(1, "name"),
		t(" - "),
		i(2, "Description."),
		i(0),
	}),

	-- One-line documentation comment for fields and constants.
	s("docf", {
		t("/** "),
		i(1, "Description."),
		t(" */"),
		i(0),
	}),

	-- Deprecated documentation followed by the @deprecated tag.
	s("dep", {
		t({ "/**", " * " }),
		i(1, "Description."),
		t({ "", " * @deprecated " }),
		i(2, "Use something else instead."),
		t({ "", " */" }),
		i(0),
	}),
}
