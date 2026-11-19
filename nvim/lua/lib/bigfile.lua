-- lua/lib/bigfile.lua

-- Detects big buffers, such as large files or minified output, so features can
-- switch off before they become sluggish.
--
-- The verdict is cached in `vim.b.bigfile` and never recomputed.
--
-- See: doc/lib.txt
-- See: lua/plugins/completions.lua

local M = {}

-- Cutoff values shared by every feature that checks for big buffers.
local max_size = 5 * 1024 * 1024
local max_line_length = 2000
local sample_lines = 500

---Check whether a buffer should be treated as a big file by its size or its
---line lengths. The verdict is cached and never recomputed.
---@param bufnr? integer Defaults to the current buffer.
---@return boolean big
function M.is_big(bufnr)
	bufnr = bufnr or 0

	if vim.b[bufnr].bigfile ~= nil then
		return vim.b[bufnr].bigfile
	end

	-- The file size is the cheapest signal and catches logs, generated assets and
	-- dumps, which tend to punish parsers and language servers.
	local filename = vim.api.nvim_buf_get_name(bufnr)
	local stat = filename ~= "" and vim.uv.fs_stat(filename) or nil
	if stat and stat.size > max_size then
		vim.b[bufnr].bigfile = true
		return true
	end

	-- Long lines are common in minified output. Only the beginning of the file is
	-- sampled so the check itself stays cheap.
	local line_count = vim.api.nvim_buf_line_count(bufnr)
	local line_limit = math.min(line_count, sample_lines)
	local ok, lines = pcall(vim.api.nvim_buf_get_lines, bufnr, 0, line_limit, false)
	if ok then
		for _, line in ipairs(lines) do
			if #line > max_line_length then
				vim.b[bufnr].bigfile = true
				return true
			end
		end
	end

	vim.b[bufnr].bigfile = false
	return false
end

return M
