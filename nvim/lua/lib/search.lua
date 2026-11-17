-- lua/lib/search.lua

-- Helpers for searching the project and the current buffer using only built-in
-- Neovim features: `:grep` (quickfix), `:vimgrep` (quickfix, Vim regex),
-- `:lvimgrep` (location list) and visual selections. `:find` also becomes a
-- fuzzy file picker through 'findfunc' (`:h fuzzy-file-picker`). Call `setup()`
-- once to set the fallback grep program for when ripgrep is missing, then use
-- the other functions from keymaps or commands. The quickfix window is opened
-- by a global autocmd, not from here.
--
-- See: lua/config/keymaps/search.lua
-- See: :h fuzzy-file-picker (the 'findfunc' recipe in cmdline.txt)
-- See: lua/config/autocmds.lua

local M = {}

-- Labels of the fixed scopes of the fuzzy file picker, queried as
-- `:find <dev/studies> <name>`. `root` is the expanded directory behind
-- the label; `:find` may also hand over the expanded root when executing.
local scopes = {
	{ label = "<dotfiles/nvim>", root = vim.fn.expand("~/dotfiles/nvim") },
	{ label = "<dev/studies>", root = vim.fn.expand("~/dev/repos/studies") },
}

-- Directories skipped when building the file cache, since `globpath()`
-- ignores 'wildignore'.
local ignored_dirs = { ".git", "node_modules", "target", "dist", ".venv", "venv", "__pycache__" }

-- Cache of file names per root, emptied on every command line by the
-- `CmdlineEnter` autocmd in `setup()`.
local files = {}

---Collect the file names under `root`, cached per root. Relative names for
---the project root, `~`-shortened ones for the fixed scopes.
---@param root string
---@return string[]
local function collect(root)
	local cached = files[root]
	if cached then
		return cached
	end

	local names = {}
	for _, name in ipairs(vim.fn.globpath(root, "**", false, true)) do
		local skip = vim.fn.isdirectory(name) == 1
		for _, dir in ipairs(ignored_dirs) do
			skip = skip or name:find("^" .. dir .. "/") ~= nil or name:find("/" .. dir .. "/") ~= nil
		end
		if not skip then
			table.insert(names, vim.fn.fnamemodify(name, root == "." and ":." or ":~"))
		end
	end

	files[root] = names
	return names
end

---Configure the fallback `grepprg` and `grepformat` for when ripgrep is not
---installed. Neovim itself sets `rg --vimgrep -uu` as the default when ripgrep
---is found, and `config/options.lua` narrows that to respect `.gitignore` and
---follow the smartcase rule; this only covers the missing-ripgrep case.
function M.setup()
	if vim.fn.executable("rg") ~= 1 then
		vim.o.grepprg = "grep -rIn --exclude-dir=.git $* ."
		vim.o.grepformat = "%f:%l:%m"
	end

	-- The native fuzzy file picker (`:h fuzzy-file-picker`): `:find` matches
	-- cached file names with `matchfuzzy()` instead of file searching.
	vim.o.findfunc = "v:lua.require'lib.search'.find"

	local group = vim.api.nvim_create_augroup("cg/find", { clear = true })

	-- The cache is emptied on every command line and rebuilt on demand, like
	-- the recipe in the docs, so new files are found again.
	-- shortcut: rescans on every command line; if that ever feels slow, invalidate only on 'DirChanged'.
	vim.api.nvim_create_autocmd("CmdlineEnter", {
		group = group,
		pattern = ":",
		callback = function()
			files = {}
		end,
	})

	-- Accept the first completion match on <Enter>, like a fuzzy finder does.
	vim.api.nvim_create_autocmd("CmdlineLeavePre", {
		group = group,
		callback = function()
			local info = vim.fn.cmdcomplete_info()
			if #info.matches == 0 or info.selected ~= -1 then
				return
			end
			if vim.fn.getcmdline():match("^%s*fin%d?%s") then
				vim.fn.setcmdline(("find %s"):format(info.matches[1]))
			end
		end,
	})
end

---Get the text of the current visual selection. Must be called while still in
---visual mode, since it reads the mode and the `v` mark.
---@return string
function M.get_selection()
	local region = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = vim.fn.mode() })
	return table.concat(region, "\n")
end

---Run a full `:grep`-style command line and report the result: the quickfix
---window opens through the `QuickFixCmdPost` autocmd, and an empty list
---closes the window again and warns. The list is emptied first, because a
---failed command would keep the previous one.
---@param command string Command line passed to `:silent`, such as `grep! -w -- foo`.
---@param label string Pattern shown in the no-match notification.
function M.run(command, label)
	vim.fn.setqflist({}, " ")
	vim.cmd(("silent %s"):format(command))
	vim.cmd("redraw!")

	if #vim.fn.getqflist() == 0 then
		-- An empty list does not close the window by itself, so a no-match
		-- leaves behind a useless empty window otherwise.
		vim.cmd("cclose")
		vim.notify("No matches for: " .. label, vim.log.levels.WARN)
	end
end

---Run `:grep` in the project for `pattern`, which is shell-escaped, so it is
---safe to pass raw user input.
---@param pattern string
---@param flags? string Extra flags for the grep program, such as `-F -w`.
function M.grep(pattern, flags)
	if pattern == "" then
		return
	end

	M.run(("grep! %s -- %s"):format(flags or "", vim.fn.shellescape(pattern, true)), pattern)
end

---Run `:lvimgrep` on the current buffer and open the location list when there
---are results. The pattern is a Vim regex, matched as-is.
---@param pattern string
function M.buffer_grep(pattern)
	if pattern == "" then
		return
	end

	-- A failed command keeps the previous list, so it is emptied first.
	vim.fn.setloclist(0, {}, " ")
	local ok = pcall(vim.cmd, ("lvimgrep /%s/j %%"):format(vim.fn.escape(pattern, "/")))
	if ok and #vim.fn.getloclist(0) > 0 then
		vim.cmd("lopen")
	else
		vim.cmd("lclose")
		vim.notify("No matches for: " .. pattern, vim.log.levels.WARN)
	end
end

---Run `:vimgrep` in the project, which uses Vim's own regex engine and works
---even without ripgrep installed. The quickfix window opens through the
---`QuickFixCmdPost` autocmd; this only warns when nothing matched.
---@param pattern string
function M.vimgrep(pattern)
	if pattern == "" then
		return
	end

	-- A failed command keeps the previous list, so it is emptied first.
	vim.fn.setqflist({}, " ")
	local ok = pcall(vim.cmd, ("silent vimgrep! /%s/j **/*"):format(vim.fn.escape(pattern, "/")))
	if not ok or #vim.fn.getqflist() == 0 then
		vim.cmd("cclose")
		vim.notify("No matches for: " .. pattern, vim.log.levels.WARN)
	end
end

---Fuzzy-match `query` against `names`, with the glob magic characters
---ignored, so wildcard queries still find something.
---@param names string[]
---@param query string
---@return string[]
local function match_fuzzy(names, query)
	local fuzzy = (query:gsub("[%*%?%[%]]", ""))
	if fuzzy == "" then
		return names
	end
	return vim.fn.matchfuzzy(names, fuzzy)
end

---The 'findfunc' implementation (`:h findfunc`): match the `:find` argument
---against the cached file names with `matchfuzzy()`. An argument that starts
---with a scope root, either as typed or as `:find` expands it while
---executing, restricts the search to that directory; wildcard and exact path
---arguments keep the native glob semantics.
---@param arg string
---@return string[]
function M.find(arg)
	for _, scope in ipairs(scopes) do
		for _, prefix in ipairs({ scope.label, scope.root }) do
			if arg:sub(1, #prefix) == prefix then
				local query = (arg:sub(#prefix + 1):gsub("^%s*", ""))
				local names = collect(scope.root)

				if query ~= "" then
					-- A wildcard or an exact path keeps the native glob
					-- semantics, but only against the real root, since the
					-- label is not a file system path.
					local matches = {}
					if prefix == scope.root then
						matches = vim.tbl_map(function(name)
							return vim.fn.fnamemodify(name, ":~")
						end, vim.fn.glob(vim.fn.expand(prefix .. "/" .. query), false, true))
					end
					if #matches > 0 then
						return matches
					end
					return match_fuzzy(names, query)
				end

				return names
			end
		end
	end

	-- The label of a scope is still being typed: complete with all of its files.
	local out = {}
	for _, scope in ipairs(scopes) do
		if #arg > 0 and scope.label:sub(1, #arg) == arg then
			vim.list_extend(out, collect(scope.root))
		end
	end
	if #out > 0 then
		return out
	end

	-- Wildcard and exact path arguments keep the glob semantics of `:find`.
	if arg:find("[/~*]") then
		local matches = vim.fn.glob(vim.fn.expand(arg), false, true)
		if #matches > 0 then
			return matches
		end
	end

	return match_fuzzy(collect("."), arg)
end

return M
