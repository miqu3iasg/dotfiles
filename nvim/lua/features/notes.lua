-- lua/features/notes.lua

-- Arcanum notes workflow: a flat vault of software-development notes managed
-- from Neovim. It creates drafts and typed notes from user-maintained
-- templates, promotes drafts, renames and retypes notes, keeps `updated_at`
-- current, searches by name and by content, and reopens the last note.
--
-- This module follows the same contract as the `nt` command line, documented
-- in the vault's `README.md`: the seven note types, the file name
-- `TYPE-YYYYMMDD-HHmmss[-SLUG].md`, the slug and collision rules, the
-- frontmatter fields and the `{{title}}`, `{{type}}`, `{{created_at}}` and
-- `{{updated_at}}` placeholders. It neither calls `nt` nor shares state with
-- it. The history of notes lives in Neovim's state directory.
--
-- The vault is `$ARCANUM_DIR`, or `~/documents/arcanum` when unset. Notes live
-- directly in its root. `_templates/` holds the templates and `attachments/`
-- the pasted images. Nothing here needs `obsidian.nvim`, which only adds
-- wikilink navigation and completion on top of the same files. The pickers use
-- `fzf-lua` when it is installed and fall back to `vim.ui.select`.
--
-- `setup()` must be called once to register the commands and autocmds. The
-- keymaps are defined in `lua/plugins/markdown.lua`.
--
-- See: lua/plugins/markdown.lua
-- See: lua/plugins/fzf.lua
-- See: ~/dev/arcanum/README.md
-- See: https://github.com/ibhagwan/fzf-lua

local M = {}

local uv = vim.uv or vim.loop

---@type string
local DEFAULT_VAULT = "~/dev/arcanum"

---Valid note types, in display order. `draft` is a provisional state and is
---deliberately not part of this list.
---@type string[]
local TYPES = { "script", "snippet", "doc", "bug", "adr", "idea", "content" }

---@type table<string, boolean>
local TYPE_SET = {}
for _, t in ipairs(TYPES) do
	TYPE_SET[t] = true
end

---@type integer
local SLUG_MAX = 80

---@type integer
local MAX_COLLISIONS = 99

---Accent folding for slugs. The same table lives in the `nt` script.
---@type table<string, string>
local ACCENTS = {}
for letter, chars in pairs({
	a = { "á", "à", "â", "ã", "ä", "å", "Á", "À", "Â", "Ã", "Ä", "Å" },
	e = { "é", "è", "ê", "ë", "É", "È", "Ê", "Ë" },
	i = { "í", "ì", "î", "ï", "Í", "Ì", "Î", "Ï" },
	o = { "ó", "ò", "ô", "õ", "ö", "Ó", "Ò", "Ô", "Õ", "Ö" },
	u = { "ú", "ù", "û", "ü", "Ú", "Ù", "Û", "Ü" },
	c = { "ç", "Ç" },
	n = { "ñ", "Ñ" },
	y = { "ý", "ÿ", "Ý" },
	ae = { "æ", "Æ" },
	oe = { "œ", "Œ" },
	ss = { "ß" },
}) do
	for _, char in ipairs(chars) do
		ACCENTS[char] = letter
	end
end

---Where the history of opened notes is kept. It holds two lines: the note
---that was current and the one before it.
---@type string
local HISTORY_FILE = vim.fn.stdpath("state") .. "/arcanum-last"

---@type { current: string?, previous: string? }
local history = { current = nil, previous = nil }

---@type boolean
local history_loaded = false

-- Messages

---@param msg string
---@param level? integer
local function notify(msg, level)
	vim.notify(msg, level or vim.log.levels.INFO, { title = "Arcanum" })
end

-- Vault and paths

---@param path string
---@return string?
local function realpath(path)
	return uv.fs_realpath(path)
end

---Resolve the vault directory the same way the CLI does. It does not check
---that the directory exists.
---@return string
local function vault_dir()
	local dir = vim.env.ARCANUM_DIR
	if dir == nil or dir == "" then
		dir = DEFAULT_VAULT
	end
	dir = vim.fs.normalize(dir)
	return realpath(dir) or dir
end

---Return the vault directory, or notify and return nil when it is missing.
---@return string?
local function require_vault()
	local dir = vault_dir()
	local stat = uv.fs_stat(dir)
	if not (stat and stat.type == "directory") then
		notify("Vault not found: " .. dir, vim.log.levels.ERROR)
		return nil
	end
	return dir
end

---@return string
function M.vault()
	return vault_dir()
end

---True for a Markdown file placed directly in the vault root. `README.md` and
---everything under `_templates/` or `attachments/` are not notes.
---@param path? string
---@return boolean
function M.is_note_path(path)
	if not path or path == "" or not path:match("%.md$") then
		return false
	end
	if vim.fs.basename(path) == "README.md" then
		return false
	end
	local dir = realpath(vim.fs.dirname(path))
	return dir ~= nil and dir == vault_dir()
end

-- Time and names

---@return string ts `YYYYMMDD-HHmmss`
---@return string iso `YYYY-MM-DDTHH:MM:SS`, local time
local function now()
	local t = os.time()
	return os.date("%Y%m%d-%H%M%S", t), --[[@as string]]
		os.date("%Y-%m-%dT%H:%M:%S", t) --[[@as string]]
end

---@param date string `YYYYMMDD`
---@param time string `HHmmss`
---@return boolean
local function valid_ts(date, time)
	local y, m, d = tonumber(date:sub(1, 4)), tonumber(date:sub(5, 6)), tonumber(date:sub(7, 8))
	local h, mi, s = tonumber(time:sub(1, 2)), tonumber(time:sub(3, 4)), tonumber(time:sub(5, 6))
	local days = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
	if y % 4 == 0 and (y % 100 ~= 0 or y % 400 == 0) then
		days[2] = 29
	end
	return m >= 1 and m <= 12 and d >= 1 and d <= days[m] and h < 24 and mi < 60 and s < 60
end

---Collapse control characters and trim.
---@param title? string
---@return string
local function clean_title(title)
	title = (title or ""):gsub("%c", " ")
	return vim.trim(title)
end

---Normalize a title into a slug: lowercase ASCII, spaces become hyphens, all
---other punctuation is dropped, hyphens are collapsed and trimmed, and the
---result is capped at 80 characters. It may be empty.
---@param title string
---@return string
function M.slugify(title)
	local s = title:gsub("[\xC2-\xF4][\x80-\xBF]*", function(char)
		return ACCENTS[char] or char
	end)
	s = s:lower():gsub("%s+", "-"):gsub("[^a-z0-9%-]", ""):gsub("%-+", "-"):gsub("^%-", ""):gsub("%-$", "")
	if #s > SLUG_MAX then
		s = s:sub(1, SLUG_MAX):gsub("%-+$", "")
	end
	return s
end

---Parse a note file name. Returns nil when it does not follow the convention.
---@param name string
---@return { type: string, date: string, time: string, ts: string, slug: string }?
function M.parse_name(name)
	local type_, date, time, rest = name:match("^(%a+)%-(%d%d%d%d%d%d%d%d)%-(%d%d%d%d%d%d)(.*)%.md$")
	if not type_ or (type_ ~= "draft" and not TYPE_SET[type_]) then
		return nil
	end
	local slug = ""
	if rest ~= "" then
		slug = rest:match("^%-([a-z0-9%-]+)$")
		if not slug or slug:find("^%-") or slug:find("%-$") or slug:find("%-%-") then
			return nil
		end
	end
	return { type = type_, date = date, time = time, ts = date .. "-" .. time, slug = slug }
end

---File name for the n-th attempt. On collision the counter goes to the end of
---the slug (`slug-2`) or becomes the slug when there is none. The timestamp
---never changes.
---@param type_ string
---@param ts string
---@param slug string
---@param n integer
---@return string
function M.build_name(type_, ts, slug, n)
	if n > 1 then
		slug = slug ~= "" and (slug .. "-" .. n) or tostring(n)
	end
	return type_ .. "-" .. ts .. (slug ~= "" and ("-" .. slug) or "") .. ".md"
end

---@param ts string `YYYYMMDD-HHmmss`
---@return string?
local function iso_from_ts(ts)
	local y, mo, d, h, mi, s = ts:match("^(%d%d%d%d)(%d%d)(%d%d)%-(%d%d)(%d%d)(%d%d)$")
	if not y or not valid_ts(y .. mo .. d, h .. mi .. s) then
		return nil
	end
	return ("%s-%s-%sT%s:%s:%s"):format(y, mo, d, h, mi, s)
end

---@param value string
---@return string
local function yaml_quote(value)
	return '"' .. value:gsub("\\", "\\\\"):gsub('"', '\\"') .. '"'
end

-- File access

---@param path string
---@return string?
---@return string? err
local function read_file(path)
	local fh, err = io.open(path, "rb")
	if not fh then
		return nil, err
	end
	local data = fh:read("*a")
	fh:close()
	return data
end

---Create a file that must not exist yet. A partial file is removed on failure,
---and an existing file is never touched.
---@param path string
---@param content string
---@return boolean? ok
---@return string? err
local function write_exclusive(path, content)
	local fd, err = uv.fs_open(path, "wx", 438)
	if not fd then
		return nil, err
	end
	local written, werr = uv.fs_write(fd, content, 0)
	uv.fs_close(fd)
	if written ~= #content then
		uv.fs_unlink(path)
		return nil, werr or "short write"
	end
	return true
end

---Move a file without ever replacing the destination. A hard link is atomic
---and refuses to overwrite; a plain rename is the fallback for filesystems
---without hard links.
---@param src string
---@param dst string
---@return boolean? ok
---@return string? err
local function move_noclobber(src, dst)
	if uv.fs_link(src, dst) then
		local ok, err = uv.fs_unlink(src)
		if not ok then
			uv.fs_unlink(dst)
			return nil, err
		end
		return true
	end
	if uv.fs_lstat(dst) then
		return nil, "EEXIST: destination already exists"
	end
	return uv.fs_rename(src, dst)
end

---Replace an existing file atomically through a temporary file in the same
---directory, keeping its permissions.
---@param path string
---@param content string
---@return boolean? ok
---@return string? err
local function replace_file(path, content)
	local tmp = ("%s/.nvim-notes.%d.%d"):format(vim.fs.dirname(path), uv.os_getpid(), uv.hrtime() % 1e9)
	local ok, err = write_exclusive(tmp, content)
	if not ok then
		return nil, err
	end
	local stat = uv.fs_stat(path)
	if stat then
		uv.fs_chmod(tmp, bit.band(stat.mode, 4095))
	end
	local rok, rerr = uv.fs_rename(tmp, path)
	if not rok then
		uv.fs_unlink(tmp)
		return nil, rerr
	end
	return true
end

---Names of the `.md` files of a directory, without sorting.
---@param dir string
---@return string[]
local function list_md(dir)
	local names = {}
	local handle = uv.fs_scandir(dir)
	while handle do
		local name, kind = uv.fs_scandir_next(handle)
		if not name then
			break
		end
		if kind == "file" and name:match("%.md$") and not name:find("\n", 1, true) then
			table.insert(names, name)
		end
	end
	return names
end

---Notes of the vault, newest first by the timestamp in the name. Names that
---break the convention go last. Ties are broken by name, ascending.
---@return string[]
function M.notes()
	local dir = vault_dir()
	local names = {}
	for _, name in ipairs(list_md(dir)) do
		if name ~= "README.md" then
			table.insert(names, name)
		end
	end
	local function key(name)
		local info = M.parse_name(name)
		return info and info.ts or ""
	end
	table.sort(names, function(a, b)
		local ka, kb = key(a), key(b)
		if ka ~= kb then
			return ka > kb
		end
		return a < b
	end)
	return names
end

-- Frontmatter
--
-- Only the initial block delimited by `---` is handled. This is deliberately
-- not a YAML parser: top-level `key: value` lines are located and rewritten in
-- place, and everything else is left byte for byte as it was.

---Split content into the frontmatter text (the lines between the delimiters,
---ending with a newline) and the body. The frontmatter is nil when the
---content has none, or when the block is never closed.
---@param content string
---@return string? fm
---@return string body
local function fm_split(content)
	if content:sub(1, 4) ~= "---\n" then
		return nil, content
	end
	local rest = content:sub(5)
	if rest:sub(1, 4) == "---\n" then
		return "", rest:sub(5)
	end
	if rest == "---" then
		return "", ""
	end
	local s, e = rest:find("\n---\n", 1, true)
	if s then
		return rest:sub(1, s), rest:sub(e + 1)
	end
	if rest:sub(-4) == "\n---" then
		return rest:sub(1, -4), ""
	end
	return nil, content
end

---@param text string
---@return string[]
local function fm_lines(text)
	if text == "" then
		return {}
	end
	return vim.split((text:gsub("\n$", "")), "\n", { plain = true })
end

---@param fm? string
---@param key string
---@return string? value unquoted
local function fm_get(fm, key)
	for _, line in ipairs(fm_lines(fm or "")) do
		if line:sub(1, #key + 1) == key .. ":" then
			local value = vim.trim(line:sub(#key + 2))
			local first, last = value:sub(1, 1), value:sub(-1)
			if #value >= 2 and first == last and (first == '"' or first == "'") then
				value = value:sub(2, -2)
			end
			return value
		end
	end
end

---Rewrite only the value of an existing top-level field. With `keep` the
---quote style of the old value is preserved. Returns nil when the field does
---not exist, so a missing field is never created.
---@param fm string
---@param key string
---@param value string
---@param keep? boolean
---@return string?
local function fm_set(fm, key, value, keep)
	local lines = fm_lines(fm)
	for i, line in ipairs(lines) do
		if line:sub(1, #key + 1) == key .. ":" then
			if keep then
				local quote = vim.trim(line:sub(#key + 2)):sub(1, 1)
				if quote == '"' or quote == "'" then
					value = quote .. value .. quote
				end
			end
			lines[i] = key .. ": " .. value
			return table.concat(lines, "\n") .. "\n"
		end
	end
end

---Rewrite one frontmatter field of a whole file's content.
---@param content string
---@param key string
---@param value string
---@param keep? boolean
---@return string?
local function content_set_field(content, key, value, keep)
	local fm, body = fm_split(content)
	if not fm then
		return nil
	end
	local new = fm_set(fm, key, value, keep)
	if not new then
		return nil
	end
	return "---\n" .. new .. "---\n" .. body
end

---Group frontmatter lines by top-level key. Indented lines, list items,
---comments and blanks belong to the key above them.
---@param fm string
---@return { key: string?, lines: string[] }[]
local function fm_blocks(fm)
	local blocks = {}
	for _, line in ipairs(fm_lines(fm)) do
		local key = line:match("^([%w_][%w_%. %-]*):")
		if key or #blocks == 0 then
			table.insert(blocks, { key = key, lines = { line } })
		else
			table.insert(blocks[#blocks].lines, line)
		end
	end
	return blocks
end

---Frontmatter of the template plus the fields of the draft that the template
---does not define, so no unknown field of the draft is lost.
---@param template_fm string
---@param draft_fm string
---@return string
local function fm_merge(template_fm, draft_fm)
	local known = {}
	for _, block in ipairs(fm_blocks(template_fm)) do
		if block.key then
			known[block.key] = true
		end
	end
	local out = template_fm
	for _, block in ipairs(fm_blocks(draft_fm)) do
		if block.key and not known[block.key] then
			out = out .. table.concat(block.lines, "\n") .. "\n"
		end
	end
	return out
end

-- Templates

---@return string
local function template_dir()
	return vault_dir() .. "/_templates"
end

---Template types that exist on disk. The templates are discovered, never
---listed, and a file only counts when its name is a valid type.
---@return string[]
function M.templates()
	local found = {}
	for _, name in ipairs(list_md(template_dir())) do
		found[name:gsub("%.md$", "")] = true
	end
	local types = {}
	for _, t in ipairs(TYPES) do
		if found[t] then
			table.insert(types, t)
		end
	end
	return types
end

---@param type_ string
---@return string? content
---@return string? err
local function read_template(type_)
	local path = ("%s/%s.md"):format(template_dir(), type_)
	local content = read_file(path)
	if not content then
		return nil, "Template not found: " .. path
	end
	return content
end

---Substitute the four known placeholders, literally, and leave any other
---double braces alone.
---@param content string
---@param vars { title: string, type: string, created_at: string, updated_at: string }
---@return string
local function render(content, vars)
	for name, value in pairs(vars) do
		content = content:gsub("{{" .. name .. "}}", function()
			return value
		end)
	end
	return content
end

-- Creation

---Write a new note under the first free name of the series. An existing note
---is never overwritten.
---@param dir string
---@param type_ string
---@param ts string
---@param slug string
---@param content string
---@return string? path
---@return string? err
local function create_file(dir, type_, ts, slug, content)
	for n = 1, MAX_COLLISIONS do
		local path = dir .. "/" .. M.build_name(type_, ts, slug, n)
		local ok, err = write_exclusive(path, content)
		if ok then
			return path
		end
		if not (err and err:find("EEXIST", 1, true)) then
			return nil, "Could not create " .. path .. ": " .. tostring(err)
		end
	end
	return nil, "Too many notes with the same timestamp: " .. ts
end

---Create a classified note from its template. Returns the new path, or nil and
---a message when the type is invalid or the template is missing, in which case
---nothing is written.
---@param type_ string
---@param title? string
---@return string? path
---@return string? err
function M.create(type_, title)
	if not TYPE_SET[type_] then
		return nil, "Invalid type: " .. tostring(type_)
	end
	local dir = vault_dir()
	local template, err = read_template(type_)
	if not template then
		return nil, err
	end
	local ts, iso = now()
	title = clean_title(title)
	local content = render(template, { title = title, type = type_, created_at = iso, updated_at = iso })
	return create_file(dir, type_, ts, M.slugify(title), content)
end

---@param path string
local function open(path)
	vim.cmd.edit(vim.fn.fnameescape(path))
end

---Run `on_choice` with the item chosen in fzf-lua, or in `vim.ui.select` when
---fzf-lua is missing. Cancelling calls nothing.
---@param items string[]
---@param prompt string
---@param on_choice fun(item: string)
local function pick(items, prompt, on_choice)
	local ok, fzf = pcall(require, "fzf-lua")
	if not ok then
		vim.ui.select(items, { prompt = prompt }, function(item)
			if item then
				on_choice(item)
			end
		end)
		return
	end
	fzf.fzf_exec(items, {
		prompt = prompt .. "> ",
		winopts = { height = 0.35, width = 0.35, row = 0.35 },
		actions = {
			["default"] = function(selected)
				if selected and selected[1] then
					on_choice(selected[1])
				end
			end,
		},
	})
end

---Quick capture: create a draft with the minimal frontmatter and open it,
---ready to type. There are no prompts.
function M.new_draft()
	local dir = require_vault()
	if not dir then
		return
	end
	local ts, iso = now()
	local content = ("---\ncreated_at: %s\nupdated_at: %s\n---\n\n"):format(iso, iso)
	local path, err = create_file(dir, "draft", ts, "", content)
	if not path then
		notify(err --[[@as string]], vim.log.levels.ERROR)
		return
	end
	open(path)
	vim.cmd("normal! G")
	vim.cmd("startinsert")
end

---Create a classified note: pick the type, ask for an optional title and open
---the result. Cancelling at any step creates nothing.
function M.new_note()
	if not require_vault() then
		return
	end
	local types = M.templates()
	if #types == 0 then
		notify("No templates found in " .. template_dir(), vim.log.levels.WARN)
		return
	end
	pick(types, "Type", function(type_)
		vim.schedule(function()
			vim.ui.input({ prompt = "Title (optional): " }, function(title)
				if title == nil then
					return
				end
				local path, err = M.create(type_, title)
				if not path then
					notify(err --[[@as string]], vim.log.levels.ERROR)
					return
				end
				open(path)
			end)
		end)
	end)
end

-- Relinking, renaming and promotion

---Replace `[[old]]`, `[[old|...]]` and `[[old#...]]` with the new name.
---@param content string
---@param old string
---@param new string
---@return string
---@return boolean changed
local function relink_content(content, old, new)
	local out = content
	for _, tail in ipairs({ "]]", "|", "#" }) do
		local from, to = "[[" .. old .. tail, "[[" .. new .. tail
		local pieces, start = {}, 1
		while true do
			local s, e = out:find(from, start, true)
			if not s then
				break
			end
			table.insert(pieces, out:sub(start, s - 1))
			table.insert(pieces, to)
			start = e + 1
		end
		table.insert(pieces, out:sub(start))
		out = table.concat(pieces)
	end
	return out, out ~= content
end

---Prepare the link fixes for the other notes of the vault. Nothing is written
---until `commit_relinks` runs, after the rename itself has succeeded.
---@param dir string
---@param old_name string
---@param new_name string
---@param iso string
---@return { path: string, content: string }[]
local function plan_relinks(dir, old_name, new_name, iso)
	local plan = {}
	local old_stem, new_stem = old_name:gsub("%.md$", ""), new_name:gsub("%.md$", "")
	for _, name in ipairs(list_md(dir)) do
		if name ~= "README.md" and name ~= old_name then
			local path = dir .. "/" .. name
			local content = read_file(path)
			if content then
				local fixed, changed = relink_content(content, old_stem, new_stem)
				if changed then
					fixed = content_set_field(fixed, "updated_at", iso, true) or fixed
					table.insert(plan, { path = path, content = fixed })
				end
			end
		end
	end
	return plan
end

---@param plan { path: string, content: string }[]
---@return integer fixed
local function commit_relinks(plan)
	local fixed = 0
	for _, item in ipairs(plan) do
		local ok, err = replace_file(item.path, item.content)
		if ok then
			fixed = fixed + 1
		else
			notify(("Could not update links in %s: %s"):format(vim.fs.basename(item.path), err), vim.log.levels.WARN)
		end
	end
	if fixed > 0 then
		vim.cmd("silent! checktime")
	end
	return fixed
end

---Rename a note file, optionally syncing one frontmatter field, and fix the
---wikilinks that point to it. The new file exists before the old one is
---removed, so a failure leaves the original in place. Nothing is overwritten.
---@param old_path string
---@param new_name string
---@param field? string
---@param value? string
---@return string? new_path
---@return string? err
local function rename_note(old_path, new_name, field, value)
	local dir = vim.fs.dirname(old_path)
	local old_name = vim.fs.basename(old_path)
	local new_path = dir .. "/" .. new_name
	local content, rerr = read_file(old_path)
	if not content then
		return nil, "Could not read " .. old_path .. ": " .. tostring(rerr)
	end

	local updated = content
	if field then
		updated = content_set_field(updated, field, value --[[@as string]]) or updated
	end
	updated = relink_content(updated, old_name:gsub("%.md$", ""), new_name:gsub("%.md$", ""))
	local _, iso = now()
	local plan = plan_relinks(dir, old_name, new_name, iso)

	local ok, err
	if updated == content then
		-- A plain rename keeps the inode and the modification time.
		ok, err = move_noclobber(old_path, new_path)
	else
		ok, err = write_exclusive(new_path, updated)
		if ok and not uv.fs_unlink(old_path) then
			uv.fs_unlink(new_path)
			ok, err = nil, "could not remove the old file"
		end
	end
	if not ok then
		return nil, ("Could not rename %s: %s"):format(old_name, tostring(err))
	end

	commit_relinks(plan)
	if history.current == old_path then
		history.current = new_path
	end
	if history.previous == old_path then
		history.previous = new_path
	end
	return new_path
end

---Swap the current window to `new_path` and drop the buffer of the old file.
---@param old_buf integer
---@param new_path string
local function switch_buffer(old_buf, new_path)
	local cursor = vim.api.nvim_win_get_cursor(0)
	open(new_path)
	pcall(vim.api.nvim_win_set_cursor, 0, cursor)
	if vim.api.nvim_buf_is_valid(old_buf) and old_buf ~= vim.api.nvim_get_current_buf() then
		vim.api.nvim_buf_delete(old_buf, { force = true })
	end
end

---Title suggested when a draft is promoted: its own `title` field, else the
---first useful line of the body.
---@param fm? string
---@param body string
---@return string
local function suggest_title(fm, body)
	local title = fm_get(fm, "title")
	if title and title ~= "" then
		return title
	end
	for line in vim.gsplit(body, "\n", { plain = true }) do
		local text = vim.trim(line:gsub("^%s*#+%s*", ""):gsub("^%s*[%-%*>]%s+", ""))
		if text ~= "" and text ~= "---" then
			return vim.fn.strcharpart(text, 0, SLUG_MAX)
		end
	end
	return ""
end

---@param s string
---@return boolean
local function is_blank(s)
	return s:match("^%s*$") ~= nil
end

---Promote the draft in `buf` to a classified note. The template supplies the
---frontmatter and the skeleton, the draft's fields that the template lacks
---are carried over, `created_at` is preserved, and the original body is kept
---whole after the template body. The draft is only removed once the new note
---has been written.
---@param buf integer
---@param type_ string
---@param title string
local function promote(buf, type_, title)
	local dir = require_vault()
	if not dir then
		return
	end
	local old_path = vim.api.nvim_buf_get_name(buf)
	local info = M.parse_name(vim.fs.basename(old_path))
	if not info or info.type ~= "draft" then
		notify("The current note is not a draft", vim.log.levels.WARN)
		return
	end
	local template, err = read_template(type_)
	if not template then
		notify(err --[[@as string]], vim.log.levels.ERROR)
		return
	end

	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	local content = table.concat(lines, "\n") .. "\n"
	local draft_fm, draft_body = fm_split(content)
	local _, iso = now()
	local created = fm_get(draft_fm, "created_at")
	if not created or created == "" then
		created = iso_from_ts(info.ts) or iso
	end

	local rendered = render(template, { title = title, type = type_, created_at = created, updated_at = iso })
	local tpl_fm, tpl_body = fm_split(rendered)

	local fm = tpl_fm
	if tpl_fm and draft_fm then
		fm = fm_merge(tpl_fm, draft_fm)
	elseif draft_fm then
		fm = draft_fm
	end
	if fm then
		fm = fm_set(fm, "created_at", created, true) or fm
		fm = fm_set(fm, "updated_at", iso, true) or fm
	end

	local body
	if is_blank(tpl_body) then
		body = draft_body
	elseif is_blank(draft_body) then
		body = tpl_body
	else
		body = tpl_body:gsub("\n*$", "\n") .. "\n" .. draft_body
	end
	local result = (fm and ("---\n" .. fm .. "---\n") or "") .. body

	local path, cerr = create_file(dir, type_, info.ts, M.slugify(title), result)
	if not path then
		notify(cerr --[[@as string]], vim.log.levels.ERROR)
		return
	end

	local old_name, new_name = vim.fs.basename(old_path), vim.fs.basename(path)
	local plan = plan_relinks(dir, old_name, new_name, iso)
	switch_buffer(buf, path)
	if uv.fs_stat(old_path) and not uv.fs_unlink(old_path) then
		notify("Promoted, but the draft could not be removed: " .. old_path, vim.log.levels.WARN)
	end
	commit_relinks(plan)
	notify("Promoted to " .. new_name)
end

---Insert the body of a template below the cursor. The frontmatter of the
---template is dropped and nothing existing is replaced, so the type and the
---name of the note do not change.
---@param buf integer
---@param type_ string
local function insert_template(buf, type_)
	local template, err = read_template(type_)
	if not template then
		notify(err --[[@as string]], vim.log.levels.ERROR)
		return
	end
	local path = vim.api.nvim_buf_get_name(buf)
	local info = M.parse_name(vim.fs.basename(path))
	local fm = fm_split(table.concat(vim.api.nvim_buf_get_lines(buf, 0, 40, false), "\n") .. "\n")
	local _, iso = now()
	local rendered = render(template, {
		title = fm_get(fm, "title") or "",
		type = info and info.type or type_,
		created_at = fm_get(fm, "created_at") or (info and iso_from_ts(info.ts)) or iso,
		updated_at = iso,
	})
	local _, body = fm_split(rendered)
	if is_blank(body) then
		notify("The template has no body to insert", vim.log.levels.WARN)
		return
	end
	local row = vim.api.nvim_win_get_cursor(0)[1]
	vim.api.nvim_buf_set_lines(buf, row, row, false, vim.split((body:gsub("\n$", "")), "\n", { plain = true }))
end

---`<leader>on`: promote the current draft, or insert a template into the
---current note.
function M.template()
	local buf = vim.api.nvim_get_current_buf()
	local path = vim.api.nvim_buf_get_name(buf)
	if not M.is_note_path(path) then
		notify("Not an Arcanum note", vim.log.levels.WARN)
		return
	end
	local types = M.templates()
	if #types == 0 then
		notify("No templates found in " .. template_dir(), vim.log.levels.WARN)
		return
	end
	local info = M.parse_name(vim.fs.basename(path))
	if info and info.type == "draft" then
		pick(types, "Promote to", function(type_)
			vim.schedule(function()
				if not vim.api.nvim_buf_is_valid(buf) then
					return
				end
				local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
				local fm, body = fm_split(table.concat(lines, "\n") .. "\n")
				vim.ui.input({ prompt = "Title: ", default = suggest_title(fm, body) }, function(title)
					if title ~= nil then
						promote(buf, type_, clean_title(title))
					end
				end)
			end)
		end)
		return
	end
	pick(types, "Insert template", function(type_)
		vim.schedule(function()
			if vim.api.nvim_buf_is_valid(buf) then
				insert_template(buf, type_)
			end
		end)
	end)
end

---Make sure the current buffer is a saved, conforming note and return its
---path and parsed name.
---@return string? path
---@return table? info
local function current_note()
	local buf = vim.api.nvim_get_current_buf()
	local path = vim.api.nvim_buf_get_name(buf)
	if not M.is_note_path(path) then
		notify("Not an Arcanum note", vim.log.levels.WARN)
		return nil
	end
	local info = M.parse_name(vim.fs.basename(path))
	if not info then
		notify("The file name does not follow the naming convention", vim.log.levels.WARN)
		return nil
	end
	if vim.bo[buf].modified then
		local ok = pcall(vim.cmd, "silent write")
		if not ok then
			notify("Could not save the note before changing it", vim.log.levels.ERROR)
			return nil
		end
	end
	return path, info
end

---Free file name for `type_`/`ts`/`slug`, ignoring the current file. Returns
---nil when the name would not change.
---@param dir string
---@param type_ string
---@param ts string
---@param slug string
---@param current string
---@return string?
local function free_name(dir, type_, ts, slug, current)
	for n = 1, MAX_COLLISIONS do
		local name = M.build_name(type_, ts, slug, n)
		if name == current then
			return nil
		end
		if not uv.fs_lstat(dir .. "/" .. name) then
			return name
		end
	end
	return nil
end

---Rename the current note after a new title. The type and the timestamp are
---kept, `title` is synced when the field exists, and `updated_at` is not
---touched. Wikilinks that point to the note are rewritten.
function M.rename()
	local path, info = current_note()
	if not (path and info) then
		return
	end
	local content = read_file(path) or ""
	local fm = fm_split(content)
	vim.ui.input({ prompt = "New title: ", default = fm_get(fm, "title") or info.slug:gsub("%-", " ") }, function(input)
		if input == nil then
			return
		end
		local title = clean_title(input)
		local dir = vim.fs.dirname(path)
		local name = free_name(dir, info.type, info.ts, M.slugify(title), vim.fs.basename(path))
		if not name then
			notify("Name unchanged")
			return
		end
		local buf = vim.api.nvim_get_current_buf()
		local new_path, err = rename_note(path, name, "title", yaml_quote(title))
		if not new_path then
			notify(err --[[@as string]], vim.log.levels.ERROR)
			return
		end
		switch_buffer(buf, new_path)
		notify("Renamed to " .. name)
	end)
end

---Change the type of the current note. The file is renamed and `type` is
---synced when the field exists; no template is applied and no content is
---replaced. A confirmation is asked first.
function M.retype()
	local path, info = current_note()
	if not (path and info) then
		return
	end
	local dir = vim.fs.dirname(path)
	local buf = vim.api.nvim_get_current_buf()
	pick(TYPES, "New type", function(type_)
		vim.schedule(function()
			if type_ == info.type then
				notify("Type unchanged")
				return
			end
			local name = free_name(dir, type_, info.ts, info.slug, vim.fs.basename(path))
			if not name then
				notify("Name unchanged")
				return
			end
			local question = ("Retype %s -> %s?"):format(vim.fs.basename(path), name)
			if vim.fn.confirm(question, "&Yes\n&No", 2) ~= 1 then
				return
			end
			local new_path, err = rename_note(path, name, "type", type_)
			if not new_path then
				notify(err --[[@as string]], vim.log.levels.ERROR)
				return
			end
			switch_buffer(buf, new_path)
			notify("Renamed to " .. name)
		end)
	end)
end

-- Search

---@return table? fzf
local function require_fzf()
	local ok, fzf = pcall(require, "fzf-lua")
	if not ok then
		notify("fzf-lua is required for searching", vim.log.levels.ERROR)
		return nil
	end
	return fzf
end

---`<leader>of`: fuzzy search by file name, with preview. Templates and
---attachments are not listed.
function M.find_files()
	local dir = require_vault()
	local fzf = dir and require_fzf()
	if not (dir and fzf) then
		return
	end
	local names = M.notes()
	if #names == 0 then
		notify("No notes found", vim.log.levels.WARN)
		return
	end
	fzf.fzf_exec(names, {
		cwd = dir,
		prompt = "Notes> ",
		previewer = "builtin",
		actions = fzf.defaults.actions.files,
		fzf_opts = { ["--tiebreak"] = "index" },
	})
end

---`<leader>og`: live ripgrep over the content of the notes, showing file, line
---and text. Only the vault root is searched, so templates and attachments are
---left out.
function M.grep()
	local dir = require_vault()
	local fzf = dir and require_fzf()
	if not (dir and fzf) then
		return
	end
	fzf.live_grep({
		cwd = dir,
		prompt = "Grep> ",
		rg_opts = "--column --line-number --no-heading --color=always --smart-case"
			.. " --max-columns=4096 --max-depth=1 -g '*.md' -g '!README.md' -e",
	})
end

-- History

local function load_history()
	if history_loaded then
		return
	end
	history_loaded = true
	local ok, lines = pcall(vim.fn.readfile, HISTORY_FILE)
	if ok then
		history.current = lines[1] ~= "" and lines[1] or nil
		history.previous = lines[2] ~= "" and lines[2] or nil
	end
end

local function save_history()
	pcall(vim.fn.mkdir, vim.fs.dirname(HISTORY_FILE), "p", "0700")
	pcall(vim.fn.writefile, { history.current or "", history.previous or "" }, HISTORY_FILE)
end

---Remember a note as the one currently open. The note before it is kept, so
---that `last()` can go back even while the last note is still open.
---@param path string
local function record_note(path)
	load_history()
	if history.current == path then
		return
	end
	history.previous = history.current
	history.current = path
	save_history()
end

---`<leader>ol`: reopen the last note. When that note is the one already open,
---go back to the one before it.
function M.last()
	if not require_vault() then
		return
	end
	load_history()
	local here = vim.api.nvim_buf_get_name(0)
	local target = history.current
	if target == here then
		target = history.previous
	end
	if not target then
		notify("No note history yet", vim.log.levels.WARN)
		return
	end
	if not (M.is_note_path(target) and uv.fs_stat(target)) then
		notify("The last note is no longer available: " .. target, vim.log.levels.WARN)
		return
	end
	open(target)
end

-- updated_at

---Refresh `updated_at` in the buffer that is about to be written. It only
---touches the field's value, inside the frontmatter, and only when the field
---already exists. It never creates frontmatter or the field, runs no
---subprocess and reads nothing but the frontmatter lines.
---@param buf integer
local function touch_updated_at(buf)
	if not (vim.bo[buf].modified and vim.bo[buf].modifiable) then
		return
	end
	if not M.is_note_path(vim.api.nvim_buf_get_name(buf)) then
		return
	end
	if vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] ~= "---" then
		return
	end

	local target, lnum
	local first, chunk = 1, 64
	while not lnum do
		local lines = vim.api.nvim_buf_get_lines(buf, first, first + chunk, false)
		if #lines == 0 then
			return
		end
		for i, line in ipairs(lines) do
			if line == "---" then
				lnum = first + i - 1
				break
			end
			if not target and line:sub(1, 11) == "updated_at:" then
				target = { index = first + i - 1, line = line }
			end
		end
		first = first + chunk
	end
	if not target or target.index >= lnum then
		return
	end

	local _, iso = now()
	local quote = vim.trim(target.line:sub(12)):sub(1, 1)
	quote = (quote == '"' or quote == "'") and quote or ""
	local line = "updated_at: " .. quote .. iso .. quote
	if line == target.line then
		return
	end

	local win = vim.fn.bufwinid(buf)
	local cursor = win ~= -1 and vim.api.nvim_win_get_cursor(win) or nil
	vim.api.nvim_buf_call(buf, function()
		pcall(vim.cmd, "undojoin")
		vim.api.nvim_buf_set_lines(buf, target.index, target.index + 1, false, { line })
	end)
	if cursor then
		pcall(vim.api.nvim_win_set_cursor, win, cursor)
	end
end

function M.setup()
	local km = vim.api.nvim_create_user_command
	km("ArcanumDraft", M.new_draft, { desc = "Arcanum: quick draft" })
	km("ArcanumNew", M.new_note, { desc = "Arcanum: new note (pick type and title)" })
	km("ArcanumTemplate", M.template, { desc = "Arcanum: insert template or promote draft" })
	km("ArcanumRename", M.rename, { desc = "Arcanum: rename the current note by title" })
	km("ArcanumRetype", M.retype, { desc = "Arcanum: change the type of the current note" })
	km("ArcanumFiles", M.find_files, { desc = "Arcanum: find notes by name" })
	km("ArcanumGrep", M.grep, { desc = "Arcanum: search note contents" })
	km("ArcanumLast", M.last, { desc = "Arcanum: reopen the last note" })

	local group = vim.api.nvim_create_augroup("arcanum_notes", { clear = true })
	vim.api.nvim_create_autocmd("BufWritePre", {
		group = group,
		pattern = "*.md",
		callback = function(args)
			touch_updated_at(args.buf)
		end,
	})
	vim.api.nvim_create_autocmd("BufEnter", {
		group = group,
		pattern = "*.md",
		callback = function(args)
			local path = vim.api.nvim_buf_get_name(args.buf)
			if M.is_note_path(path) then
				record_note(path)
			end
		end,
	})
end

return M
