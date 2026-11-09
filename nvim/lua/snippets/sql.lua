-- lua/snippets/sql.lua

-- SQL snippets for queries, joins, clauses, data manipulation, schema
-- definitions, common table expressions, and comments. Helper functions generate
-- consistent index names and reusable JOIN clauses, while mirrored nodes keep
-- table aliases and repeated identifiers synchronized.

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local rep = require("luasnip.extras").rep

-- Extracts the final identifier component from a name or qualified identifier.
local function bare(name)
	return name:match("([%w_]+)$") or ""
end

-- Generates an index name from the table and indexed column names.
local function index_name(args)
	local cols = args[2][1]:gsub("[%s,]+", "_")
	return "idx_" .. bare(args[1][1]) .. "_" .. cols
end

-- Creates a JOIN clause with synchronized table aliases.
local function join_snip(trig, kind)
	return s(trig, {
		t(kind .. " JOIN "),
		i(1, "table"),
		t(" "),
		i(2, "b"),
		t(" ON "),
		rep(2),
		t("."),
		i(3, "id"),
		t(" = "),
		i(4, "a"),
		t("."),
		i(5, "fk"),
		i(0),
	})
end

return {
	-- Selects all columns from a table.
	s("sel", { t("SELECT * FROM "), i(1, "table"), t(";"), i(0) }),

	-- Selects columns from a table with a WHERE condition.
	s("selw", {
		t("SELECT "),
		i(1, "*"),
		t({ "", "FROM " }),
		i(2, "table"),
		t({ "", "WHERE " }),
		i(3, "condition"),
		t(";"),
		i(0),
	}),

	-- Counts rows matching a condition.
	s("selc", {
		t("SELECT COUNT(*) FROM "),
		i(1, "table"),
		t({ "", "WHERE " }),
		i(2, "condition"),
		t(";"),
		i(0),
	}),

	-- Counts rows per group and orders the largest groups first.
	s("selg", {
		t("SELECT "),
		i(1, "column"),
		t({ ", COUNT(*) AS total", "FROM " }),
		i(2, "table"),
		t({ "", "GROUP BY " }),
		rep(1),
		t({ "", "ORDER BY total DESC;" }),
		i(0),
	}),

	-- Selects all columns from two tables joined by mirrored aliases.
	s("selj", {
		t("SELECT "),
		rep(2),
		t(".*, "),
		rep(4),
		t(".*"),
		t({ "", "FROM " }),
		i(1, "table"),
		t(" "),
		i(2, "a"),
		t({ "", "INNER JOIN " }),
		i(3, "other"),
		t(" "),
		i(4, "b"),
		t(" ON "),
		rep(2),
		t("."),
		i(5, "id"),
		t(" = "),
		rep(4),
		t("."),
		i(6, "fk"),
		t({ "", "WHERE " }),
		i(7, "condition"),
		t(";"),
		i(0),
	}),

	-- INNER and LEFT JOIN clauses with synchronized aliases.
	join_snip("ij", "INNER"),
	join_snip("lj", "LEFT"),

	-- Ordering with an editable sort direction.
	s("ob", { t("ORDER BY "), i(1, "column"), t(" "), c(2, { t("ASC"), t("DESC") }), i(0) }),

	-- Groups rows by a column.
	s("gb", { t("GROUP BY "), i(1, "column"), i(0) }),

	-- Inserts a single row.
	s("ins", {
		t("INSERT INTO "),
		i(1, "table"),
		t(" ("),
		i(2, "col1, col2"),
		t({ ")", "VALUES (" }),
		i(3, "val1, val2"),
		t(");"),
		i(0),
	}),

	-- Inserts multiple rows.
	s("insm", {
		t("INSERT INTO "),
		i(1, "table"),
		t(" ("),
		i(2, "col1, col2"),
		t({ ")", "VALUES", "    (" }),
		i(3, "v1, v2"),
		t({ "),", "    (" }),
		i(4, "v1, v2"),
		t(");"),
		i(0),
	}),

	-- Updates rows matching a condition.
	s("upd", {
		t("UPDATE "),
		i(1, "table"),
		t({ "", "SET " }),
		i(2, "column"),
		t(" = "),
		i(3, "value"),
		t({ "", "WHERE " }),
		i(4, "condition"),
		t(";"),
		i(0),
	}),

	-- Deletes rows matching a condition.
	s("del", {
		t("DELETE FROM "),
		i(1, "table"),
		t({ "", "WHERE " }),
		i(2, "condition"),
		t(";"),
		i(0),
	}),

	-- Creates a table with an ID, a required column, and a creation timestamp.
	s("ct", {
		t("CREATE TABLE "),
		i(1, "table"),
		t({ " (", "    id BIGSERIAL PRIMARY KEY,", "    " }),
		i(2, "name"),
		t(" "),
		i(3, "VARCHAR(255)"),
		t({
			" NOT NULL,",
			"    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP",
			");",
		}),
		i(0),
	}),

	-- Adds a column to an existing table.
	s("at", {
		t("ALTER TABLE "),
		i(1, "table"),
		t({ "", "ADD COLUMN " }),
		i(2, "column"),
		t(" "),
		i(3, "type"),
		t(";"),
		i(0),
	}),

	-- Creates an index with a name derived from its table and columns.
	s("ci", {
		t("CREATE INDEX "),
		f(index_name, { 1, 2 }),
		t(" ON "),
		i(1, "table"),
		t(" ("),
		i(2, "column"),
		t(");"),
		i(0),
	}),

	-- Common table expression followed by a query of its results.
	s("cte", {
		t("WITH "),
		i(1, "cte_name"),
		t({ " AS (", "    SELECT " }),
		i(2, "*"),
		t({ "", "    FROM " }),
		i(3, "table"),
		t({ "", "    WHERE " }),
		i(4, "condition"),
		t({ "", ")", "SELECT " }),
		i(5, "*"),
		t({ "", "FROM " }),
		rep(1),
		t(";"),
		i(0),
	}),

	-- CASE expression with editable conditions and result values.
	s("case", {
		t({ "CASE", "    WHEN " }),
		i(1, "condition"),
		t(" THEN "),
		i(2, "result"),
		t({ "", "    ELSE " }),
		i(3, "other"),
		t({ "", "END AS " }),
		i(4, "alias"),
		i(0),
	}),

	-- Single-line SQL comment.
	s("cm", { t("-- "), i(1, "comment"), i(0) }),

	-- Multi-line block comment.
	s("cmm", {
		t({ "/*", " * " }),
		i(1, "comment"),
		t({ "", " */" }),
		i(0),
	}),
}
