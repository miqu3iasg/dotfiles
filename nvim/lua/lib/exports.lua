-- lua/lib/exports.lua

-- Single source of truth for where exported documents go, used by the pandoc
-- setup.
--
-- The root comes from `M.markers`, falling back to the note's folder, or from
-- `vim.g.exports_root`. An unnamed buffer counts as `scratch`.
--
-- See: doc/lib.md
-- See: doc/pandoc.md

local M = {}

---@type string
M.exports_dirname = "exports"

-- Markers are searched from highest to lowest priority, and the closest parent
-- that has any of them wins.
---@type (string|string[])[]
M.markers = {
	".exports-root",
	{ ".git", ".jj", ".hg", ".svn" },
	{
		".obsidian",
		"README.md",
		"README.markdown",
		"README",
		"LICENSE",
		"LICENSE.md",
		"LICENSE.txt",
		"Makefile",
		".editorconfig",
	},
}

---@param src integer|string Buffer number or file path.
---@return string
local function path_of(src)
	if type(src) == "number" then
		local name = vim.api.nvim_buf_get_name(src)
		return name ~= "" and name or (vim.uv.cwd() .. "/scratch")
	end
	return src
end

---Root folder that holds `exports/` for `src`. `vim.g.exports_root`
---wins over everything when set. Otherwise it is the closest parent matching
---`M.markers`, falling back to the folder of `src`.
---@param src integer|string
---@return string
function M.root(src)
	if vim.g.exports_root and vim.g.exports_root ~= "" then
		return vim.fs.normalize(vim.g.exports_root)
	end
	local path = path_of(src)
	return vim.fs.root(path, M.markers) or vim.fs.dirname(path)
end

---File name of `src` without directory and extension, so `/a/note.md` gives
---`note`.
---@param src integer|string
---@return string
function M.basename(src)
	return vim.fn.fnamemodify(path_of(src), ":t:r")
end

---@param src integer|string
---@return string
function M.exports_dir(src)
	return M.root(src) .. "/" .. M.exports_dirname
end

---Folder of the note relative to the root, with a trailing slash. It is empty
---when the note sits at the root or outside it.
---@param src integer|string
---@return string
function M.reldir(src)
	local path = path_of(src)
	local root = M.root(src)
	local dir = vim.fs.dirname(path)
	if dir:sub(1, #root + 1) == root .. "/" then
		return dir:sub(#root + 2) .. "/"
	end
	return ""
end

---Path of the final document, `<root>/exports/<reldir>/<name>.<ext>`.
---@param src integer|string
---@param ext? string Extension without the dot, `"pdf"` by default.
---@return string
function M.output_path(src, ext)
	return M.exports_dir(src) .. "/" .. M.reldir(src) .. M.basename(src) .. "." .. (ext or "pdf")
end

---Output path template for tools that expand file-name variables themselves.
---It uses the variables `$root`, `$dir` and `$name` and
---mirrors `M.output_path`, so the two layouts stay in sync.
---@return string
function M.output_pattern()
	return ("$root/%s/$dir/$name"):format(M.exports_dirname)
end

return M
