-- lua/snippets/lua.lua

-- Lua snippets for LuaLS documentation annotations, the typed comment style
-- used throughout this configuration: function documentation with typed
-- parameters and returns, class definitions, custom type declarations, and
-- single param, return and field lines. LuaLS has no @usage annotation;
-- references go in @see. Indentation assumes tabs.
--
-- See: doc/snippets.txt
-- See: https://luals.github.io/wiki/annotations/
-- See: https://github.com/LuaLS/lua-language-server/wiki/Annotations

local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node

return {
	-- Function documentation, above the function. Duplicate the @param lines
	-- as needed and remove @return when the function returns nothing.
	s("doc", {
		t("--- "),
		i(1, "Description."),
		t({ "", "---@param " }),
		i(2, "param"),
		t(" "),
		i(3, "type"),
		t(" "),
		i(4, "Description."),
		t({ "", "---@return " }),
		i(5, "type"),
		t(" "),
		i(6, "Description."),
		t({ "", "" }),
		i(0),
	}),

	-- Function documentation without @return, for functions that return
	-- nothing.
	s("docv", {
		t("--- "),
		i(1, "Description."),
		t({ "", "---@param " }),
		i(2, "param"),
		t(" "),
		i(3, "type"),
		t(" "),
		i(4, "Description."),
		t({ "", "" }),
		i(0),
	}),

	-- Function documentation with a generic type parameter, for functions
	-- whose parameter and return types relate through a variable.
	s("docg", {
		t("--- "),
		i(1, "Description."),
		t({ "", "---@generic " }),
		i(2, "T"),
		t({ "", "---@param " }),
		i(3, "param"),
		t(" "),
		i(4, "T"),
		t(" "),
		i(5, "Description."),
		t({ "", "---@return " }),
		i(6, "T"),
		t(" "),
		i(7, "Description."),
		t({ "", "" }),
		i(0),
	}),

	-- Class definition with a field. Inherit from a parent type by adding
	-- ": Parent" after the class name, and duplicate the @field lines as
	-- needed.
	s("docc", {
		t("---"),
		i(1, "Name"),
		t({ " description.", "---@class " }),
		i(2, "Name"),
		t({ "", "---@field " }),
		i(3, "field"),
		t(" "),
		i(4, "type"),
		t(" "),
		i(5, "Description."),
		t({ "", "" }),
		i(0),
	}),

	-- Custom type declarations: pick an alias, an enum or an exact class.
	-- Exact classes flag fields missing from @field lines.
	s("docx", {
		c(1, {
			sn(nil, {
				t("--- "),
				i(1, "Description."),
				t({ "", "---@alias " }),
				i(2, "Name"),
				t(" "),
				i(3, "type"),
			}),
			sn(nil, {
				t("--- "),
				i(1, "Description."),
				t({ "", "---@enum " }),
				i(2, "Name"),
				t({ "", "---@field [1] " }),
				i(3, "value"),
			}),
			sn(nil, {
				t("--- "),
				i(1, "Description."),
				t({ "", "---@class " }),
				i(2, "Name"),
				t(" (exact)"),
				t({ "", "---@field " }),
				i(3, "field"),
				t(" "),
				i(4, "type"),
				t(" "),
				i(5, "Description."),
			}),
		}),
		t({ "", "" }),
		i(0),
	}),

	-- Module documentation, at the top of the file, above the first
	-- statement.
	s("docm", {
		t("-- "),
		i(1, "Short description."),
		t({ "", "--", "-- " }),
		i(2, "Longer description."),
		t({ "", "" }),
		i(0),
	}),

	-- Parameter line, to add one more @param inside an existing block.
	s("docp", {
		t("---@param "),
		i(1, "param"),
		t(" "),
		i(2, "type"),
		t(" "),
		i(3, "Description."),
		i(0),
	}),

	-- Return line, to document one more value of a multi-return function.
	s("docret", {
		t("---@return "),
		i(1, "type"),
		t(" "),
		i(2, "Description."),
		i(0),
	}),

	-- Field line, to add one more @field inside an existing class. The
	-- scope is optional: public, private, protected or package.
	s("docf", {
		t("---@field "),
		c(1, {
			t(""),
			sn(nil, { i(1, "private"), t(" ") }),
			sn(nil, { i(1, "protected"), t(" ") }),
			sn(nil, { i(1, "public"), t(" ") }),
			sn(nil, { i(1, "package"), t(" ") }),
		}),
		i(2, "field"),
		t(" "),
		i(3, "type"),
		t(" "),
		i(4, "Description."),
		i(0),
	}),

	-- Reference line, to point at a related function, class or page.
	s("docs", {
		t("---@see "),
		i(1, "Reference"),
		i(0),
	}),

	-- Marks the annotated function as asynchronous.
	s("doca", {
		t("---@async"),
		i(0),
	}),

	-- Deprecation notice, telling the language server to flag calls.
	s("docd", {
		t("---@deprecated"),
		i(0),
	}),

	-- Warns that the return value should not be discarded.
	s("docn", {
		t("---@nodiscard"),
		i(0),
	}),
}
