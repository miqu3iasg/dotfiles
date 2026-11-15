-- lua/snippets/js.lua

-- JavaScript snippets for JSDoc documentation comments, the standard that
-- editors and language servers read in both JavaScript and TypeScript. The
-- TypeScript alias and the react filetypes inherit this file through the
-- completions module. Indentation assumes two spaces.
--
-- Every type-bearing tag carries its type in curly braces, as JSDoc parses
-- them: `@param {string} name - Description.` and `@returns {Type}`. Type
-- expressions work inside the braces: `[name]` for optional parameters,
-- `[name=value]` for defaults, `{(string|string[])}` for unions and
-- `{...number}` for rest parameters. Blocks end with a line break so the
-- declaration they document sits right below; delete the tag lines that do
-- not apply.
--
-- See: doc/snippets.txt
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
		i(1, "Summary sentence ending with a period."),
		t({ "", " *", " * @param {" }),
		i(2, "string"),
		t("} "),
		i(3, "name"),
		t(" - "),
		i(4, "Description."),
		t({ "", " * @param {" }),
		i(5, "string"),
		t("} "),
		i(6, "name"),
		t(" - "),
		i(7, "Description."),
		t({ "", " * @returns {" }),
		i(8, "type"),
		t("} "),
		i(9, "Description."),
		t({ "", " */", "" }),
		i(0),
	}),

	-- Function documentation without @returns, for functions that return
	-- nothing.
	s("docv", {
		t({ "/**", " * " }),
		i(1, "Summary sentence ending with a period."),
		t({ "", " *", " * @param {" }),
		i(2, "string"),
		t("} "),
		i(3, "name"),
		t(" - "),
		i(4, "Description."),
		t({ "", " */", "" }),
		i(0),
	}),

	-- Class documentation for constructor functions and classes: @class
	-- marks the constructor, @classdesc holds the longer description and the
	-- constructor parameters follow as @param lines.
	s("docx", {
		t({ "/**", " * " }),
		i(1, "Summary sentence ending with a period."),
		t({ "", " *", " * @class", " * @classdesc " }),
		i(2, "Longer description of the class."),
		t({ "", " *", " * @constructor", " * @param {" }),
		i(3, "string"),
		t("} "),
		i(4, "name"),
		t(" - "),
		i(5, "Description."),
		t({ "", " */", "" }),
		i(0),
	}),

	-- Class documentation, above the class.
	s("docc", {
		t({ "/**", " * " }),
		i(1, "Summary sentence ending with a period."),
		t({ "", " *", " * " }),
		i(2, "Longer description."),
		t({ "", " */", "" }),
		i(0),
	}),

	-- Parameter line, to add one more @param inside an existing block.
	s("docp", {
		t(" * @param {"),
		i(1, "string"),
		t("} "),
		i(2, "name"),
		t(" - "),
		i(3, "Description."),
		i(0),
	}),

	-- Throws line, to add one more @throws inside an existing block.
	s("doct", {
		t(" * @throws {"),
		i(1, "Error"),
		t("} "),
		i(2, "if ..."),
		i(0),
	}),

	-- See line, to add a reference inside an existing block.
	s("seeref", {
		t(" * @see "),
		i(1, "{@link RelatedClass}"),
		i(0),
	}),

	-- Example block, above a declaration or inside an existing block.
	s("doce", {
		t({ "/**", " * @example", " * " }),
		i(1, "example code"),
		t({ "", " */", "" }),
		i(0),
	}),

	-- Type definition with property lines, for object shapes used as
	-- parameter or return types. Duplicate the @property lines as needed.
	s("deft", {
		t({ "/**", " * " }),
		i(1, "Summary sentence ending with a period."),
		t({ "", " *", " * @typedef {Object} " }),
		i(2, "Name"),
		t({ "", " * @property {" }),
		i(3, "string"),
		t("} "),
		i(4, "prop"),
		t(" - "),
		i(5, "Description."),
		t({ "", " */", "" }),
		i(0),
	}),

	-- Callback type definition, for functions passed around as values.
	s("defcb", {
		t({ "/**", " * " }),
		i(1, "Summary sentence ending with a period."),
		t({ "", " *", " * @callback " }),
		i(2, "Name"),
		t({ "", " * @param {" }),
		i(3, "type"),
		t("} "),
		i(4, "name"),
		t(" - "),
		i(5, "Description."),
		t({ "", " */", "" }),
		i(0),
	}),

	-- One-line documentation comment for fields and constants.
	s("docf", {
		t("/** "),
		i(1, "Summary sentence."),
		t({ " */", "" }),
		i(0),
	}),

	-- Deprecated documentation followed by the @deprecated tag.
	s("dep", {
		t({ "/**", " * " }),
		i(1, "Summary sentence ending with a period."),
		t({ "", " *", " * @deprecated " }),
		i(2, "Use `X` instead."),
		t({ "", " */", "" }),
		i(0),
	}),
}
