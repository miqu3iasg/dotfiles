-- lua/snippets/lua.lua

-- Lua snippets for LuaLS documentation annotations, the typed comment style
-- used throughout this configuration: function documentation with typed
-- parameters and returns, class definitions, and single param and field
-- lines. Indentation assumes tabs.
--
-- See: https://luals.github.io/wiki/annotations/
-- See: https://github.com/LuaLS/lua-language-server/wiki/Annotations

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

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
		i(0),
	}),

	-- Class definition with a field. Duplicate the @field lines as needed.
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

	-- Field line, to add one more @field inside an existing class.
	s("docf", {
		t("---@field "),
		i(1, "field"),
		t(" "),
		i(2, "type"),
		t(" "),
		i(3, "Description."),
		i(0),
	}),
}
