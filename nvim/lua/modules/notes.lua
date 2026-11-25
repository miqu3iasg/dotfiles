-- lua/modules/notes.lua

-- Flat Markdown note vault behind the `:Notes*` commands: drafts, typed
-- notes from templates, daily notes, task capture and search.
--
-- The vault is `$ARCANUM_DIR`, or `~/dev/arcanum` when unset. Only `.md`
-- files directly in its root are notes.
--
-- The pickers and the search run on fzf-lua, which needs fzf and ripgrep.
--
-- $ sudo pacman -S fzf ripgrep
--
-- See: doc/modules.md
-- See: lua/plugins/markdown.lua
-- See: ~/dev/arcanum/README.md

local M = {}

local uv = vim.uv or vim.loop
local unpack = table.unpack or unpack
local WARN, ERROR = vim.log.levels.WARN, vim.log.levels.ERROR

local DEFAULT_VAULT = "~/dev/arcanum"
local SLUG_MAX = 80
-- One UTF-8 character: a lead byte followed by its continuation bytes.
local UTF8_CHAR = "[%z\1-\127\194-\244][\128-\191]*"

---Valid note types; `draft` is provisional and deliberately not part of them
---@type string[]
local TYPES = { "script", "snippet", "doc", "bug", "adr", "idea", "content" }

---Short description of each note type, shown in the picker header
---@type table<string, string>
local TYPE_HELP = {
	script = "automation script",
	snippet = "reusable code",
	doc = "documentation",
	bug = "coding error",
	adr = "technical decision note",
	idea = "idea to explore",
	content = "content draft",
}

---Build the picker header from the given names that have a description
---Names without one, such as generic templates, are left out
---@param types string[]
---@return string header `<enter> accept | type (description) | ...`
local function types_header(types)
	local parts = { "<enter> accept" }
	for _, t in ipairs(types) do
		if TYPE_HELP[t] then
			table.insert(parts, ("%s (%s)"):format(t, TYPE_HELP[t]))
		end
	end
	return table.concat(parts, " | ")
end

---Accented characters mapped to their ASCII fold, built from `base = "chars"` groups
---@type table<string, string>
local ACCENTS = {}
for base, chars in pairs({
	a = "áàâãäå",
	e = "éèêë",
	i = "íìîï",
	o = "óòôõö",
	u = "úùûü",
	c = "ç",
	n = "ñ",
	y = "ýÿ",
	ae = "æ",
	oe = "œ",
	ss = "ß",
}) do
	for ch in chars:gmatch(UTF8_CHAR) do
		ACCENTS[ch] = base
	end
end

---Show a message titled "Notes"
---@param msg string
---@param level? integer `vim.log.levels` value, INFO by default
local function notify(msg, level) vim.notify(msg, level or vim.log.levels.INFO, { title = "Notes" }) end

---Format a time with `os.date`, typed as a string
---@param fmt string `strftime` format
---@param t? integer time, now by default
---@return string formatted
local function date(fmt, t)
	return os.date(fmt, t) --[[@as string]]
end

---Return the current time as a file name stamp and as an ISO timestamp
---@return string ts `YYYYMMDD-HHmmss`
---@return string iso `YYYY-MM-DDTHH:MM:SS`, local time
local function now()
	local t = os.time()
	return date("%Y%m%d-%H%M%S", t), date("%Y-%m-%dT%H:%M:%S", t)
end

-- Vault

---Resolve the vault directory without checking that it exists
---@return string dir
local function vault_dir()
	local dir = vim.env.ARCANUM_DIR
	if not dir or dir == "" then
		dir = DEFAULT_VAULT
	end
	dir = vim.fs.normalize(dir)
	return uv.fs_realpath(dir) or dir
end

---Return the vault directory, or notify and return nil when it is missing
---@return string? dir
local function require_vault()
	local dir = vault_dir()
	local stat = uv.fs_stat(dir)
	if not (stat and stat.type == "directory") then
		notify("Vault not found: " .. dir, ERROR)
		return nil
	end
	return dir
end

---Return the vault directory
---@return string dir
function M.vault() return vault_dir() end

---Check whether a path is a note of the vault
---`README.md` and everything under `_templates/` or `attachments/` are not notes
---@param path? string
---@return boolean is_note
function M.is_note_path(path)
	if not path or path == "" or not path:match("%.md$") then
		return false
	end
	if vim.fs.basename(path) == "README.md" then
		return false
	end
	local dir = uv.fs_realpath(vim.fs.dirname(path))
	return dir ~= nil and dir == vault_dir()
end

-- Names

---Normalize a title into a lowercase ASCII slug
---@param title string
---@return string slug
function M.slugify(title)
	local s = vim.fn.tolower(title):gsub(UTF8_CHAR, ACCENTS)
	s = s:gsub("%s+", "-"):gsub("[^a-z0-9%-]", ""):gsub("%-+", "-"):gsub("^%-", ""):gsub("%-$", "")
	if #s > SLUG_MAX then
		s = s:sub(1, SLUG_MAX):gsub("%-+$", "")
	end
	return s
end

---@class notes.NameInfo
---@field type string note type, or `daily` and `draft`
---@field ts string timestamp `YYYYMMDD-HHmmss` taken from the file name

---Parse a note file name into its type and timestamp
---Return nil when the name breaks the convention
---@param name string file name, without directory
---@return notes.NameInfo? info
function M.parse_name(name)
	local daily = name:match("^daily%-(%d%d%d%d%d%d%d%d)%.md$")
	if daily then
		-- Midnight places the daily after the typed notes of its own day.
		return { type = "daily", ts = daily .. "-000000" }
	end
	local type_, ts = name:match("^(%a+)%-(%d%d%d%d%d%d%d%d%-%d%d%d%d%d%d)")
	if type_ and (type_ == "draft" or vim.list_contains(TYPES, type_)) then
		return { type = type_, ts = ts }
	end
end

-- Files

---Read a whole file, nil when it cannot be opened
---@param path string
---@return string? content
local function read_file(path)
	local fh = io.open(path, "rb")
	if not fh then
		return nil
	end
	local data = fh:read("*a")
	fh:close()
	return data
end

---Create a file that must not exist yet, never touching an existing one
---@param path string
---@param content string
---@return boolean? ok
---@return string? err
local function write_new(path, content)
	local fd, err = uv.fs_open(path, "wx", 438)
	if not fd then
		return nil, err
	end
	uv.fs_write(fd, content, 0)
	uv.fs_close(fd)
	return true
end

---List the `.md` files of a directory, unsorted
---@param dir string
---@return string[] names
local function list_md(dir)
	local names = {}
	for name, kind in vim.fs.dir(dir) do
		if kind == "file" and name:match("%.md$") then
			names[#names + 1] = name
		end
	end
	return names
end

---List the notes of the vault, newest first by the timestamp in the name
---Names that break the convention go last, and ties are broken by name
---@return string[] names
function M.notes()
	local names = vim.tbl_filter(function(n) return n ~= "README.md" end, list_md(vault_dir()))
	local key = {}
	for _, name in ipairs(names) do
		local info = M.parse_name(name)
		key[name] = info and info.ts or ""
	end
	table.sort(names, function(a, b)
		if key[a] ~= key[b] then
			return key[a] > key[b]
		end
		return a < b
	end)
	return names
end

-- Frontmatter: only the initial `---` block, handled line by line, no YAML parser.

---Find the closing `---` of the frontmatter, 0 when there is none
---@param lines string[] lines of the note
---@return integer index
local function fm_end(lines)
	if lines[1] ~= "---" then
		return 0
	end
	for i = 2, #lines do
		if lines[i] == "---" then
			return i
		end
	end
	return 0
end

---Read a frontmatter value, unquoted
---Return nil when the key is missing or empty
---@param lines string[] lines of the note
---@param key string plain key name, not a pattern
---@return string? value
local function fm_get(lines, key)
	for i = 2, fm_end(lines) - 1 do
		local v = lines[i]:match("^" .. key .. ":%s*(.-)%s*$")
		if v then
			local quoted = v:match('^"(.*)"$')
			if quoted then
				v = quoted:gsub('\\(["\\])', "%1")
			end
			return v ~= "" and v or nil
		end
	end
end

-- Templates

---Return the template directory of the vault
---@return string dir
local function template_dir() return vault_dir() .. "/_templates" end

---List the template names on disk, sorted
---With `typed_only`, keep the names of valid note types, which leaves out generic templates such as `meeting`
---@param typed_only? boolean
---@return string[] names
function M.template_names(typed_only)
	local names = {}
	for _, file in ipairs(list_md(template_dir())) do
		local name = file:gsub("%.md$", "")
		if not typed_only or vim.list_contains(TYPES, name) then
			names[#names + 1] = name
		end
	end
	table.sort(names)
	return names
end

---List the templates that fit the current buffer
---Notes of the vault take typed templates only, any other Markdown file takes all of them
---@return string[] names
local function template_choices() return M.template_names(M.is_note_path(vim.api.nvim_buf_get_name(0))) end

---Read the content of a template
---@param name string template name, without extension
---@return string? content
---@return string? err
local function read_template(name)
	local path = ("%s/%s.md"):format(template_dir(), name)
	local content = read_file(path)
	if not content then
		return nil, "Template not found: " .. path
	end
	return content
end

---Return the zero-padded number for the next note of a type
---It counts the existing notes, so deleting one makes its number be reused
---@param type_ string
---@return string number
local function next_number(type_)
	local count = 0
	for _, name in ipairs(M.notes()) do
		local info = M.parse_name(name)
		if info and info.type == type_ then
			count = count + 1
		end
	end
	return ("%03d"):format(count + 1)
end

---Generate a random (version 4) UUID
---@return string uuid
local function uuid()
	local b = { uv.random(16):byte(1, 16) }
	b[7] = b[7] % 16 + 64 -- version 4
	b[9] = b[9] % 64 + 128 -- variant 10xx
	return ("%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x"):format(unpack(b))
end

---Placeholders written bare when a template quotes them
---Every other placeholder is quoted as a YAML string
---@type table<string, boolean>
local RAW = { date = true, id = true }

---Quote a value as a YAML double-quoted string
---@param v string
---@return string quoted
local function quote(v) return '"' .. v:gsub('[\\"]', "\\%0") .. '"' end

---@class notes.RenderCtx
---@field title? string note title, empty when omitted
---@field date string ISO timestamp for `{{date}}`
---@field id? string existing id to keep, a new UUID when omitted
---@field vars? table<string, string> extra placeholders

---Substitute the `{{name}}` placeholders of a template
---Unknown names are left as they are
---@param content string template text
---@param ctx notes.RenderCtx
---@return string rendered
local function render(content, ctx)
	local vars = { title = ctx.title or "", date = ctx.date, id = ctx.id or uuid() }
	if content:find("{{adr_number}}", 1, true) then
		vars.adr_number = next_number("adr")
	end
	for name, value in pairs(ctx.vars or {}) do
		vars[name] = value
	end

	-- A `key: "{{var}}"` line gets an escaped YAML string, so a title with
	-- quotes or colons cannot break the frontmatter. The values of RAW names
	-- are safe, so they go in without quotes.
	content = content:gsub('(\n[%w_%-]+:[ \t]*)"{{([%w_]+)}}"', function(key, name)
		local v = vars[name]
		if v == nil then
			return nil
		end
		return key .. (RAW[name] and v or quote(v))
	end)
	return (content:gsub("{{([%w_]+)}}", function(name) return vars[name] end))
end

-- Creation

---Open a file in the current window
---@param path string
local function open(path) vim.cmd.edit(vim.fn.fnameescape(path)) end

---Create a classified note from its template
---Return nil and a message when the type is invalid, the template is missing or the file exists, writing nothing
---@param type_ string note type, one of `TYPES`
---@param title? string
---@return string? path
---@return string? err
function M.create(type_, title)
	if not vim.list_contains(TYPES, type_) then
		return nil, "Invalid type: " .. tostring(type_)
	end
	local template, err = read_template(type_)
	if not template then
		return nil, err
	end
	local ts, iso = now()
	title = vim.trim(title or "")
	local slug = M.slugify(title)
	local name = type_ .. "-" .. ts .. (slug ~= "" and "-" .. slug or "") .. ".md"
	local path = vault_dir() .. "/" .. name
	local ok, werr = write_new(path, render(template, { title = title, date = iso }))
	if not ok then
		return nil, "Could not create " .. path .. ": " .. tostring(werr)
	end
	return path
end

---Create and open a draft in insert mode, with no prompts
function M.new_draft()
	local dir = require_vault()
	if not dir then
		return
	end
	local ts, iso = now()
	local path = ("%s/draft-%s.md"):format(dir, ts)
	local fm = ("---\nid: %s\ndescription:\naliases: []\ndate: %s\n---\n\n"):format(uuid(), iso)
	local ok, err = write_new(path, fm)
	if not ok then
		return notify("Could not create " .. path .. ": " .. tostring(err), ERROR)
	end
	open(path)
	vim.cmd("normal! G")
	vim.cmd.startinsert()
end

---Return the compact date of the day `offset` days from today
---@param offset integer days from today, negative for the past
---@return string compact `YYYYMMDD`
local function daily_date(offset)
	-- `os.time` normalizes the day overflow, and noon keeps DST shifts from
	-- moving the day.
	local t = os.date("*t") --[[@as osdate]]
	return date("%Y%m%d", os.time({ year = t.year, month = t.month, day = t.day + offset, hour = 12 }))
end

---Open the daily note of `offset` days from today
---Create it from the `daily` template when it does not exist
---@param offset? integer days from today, 0 by default
---@return string? path
function M.daily(offset)
	local dir = require_vault()
	if not dir then
		return
	end
	offset = offset or 0
	local path = ("%s/daily-%s.md"):format(dir, daily_date(offset))
	if not uv.fs_stat(path) then
		local template, err = read_template("daily")
		if not template then
			return notify(err --[[@as string]], ERROR)
		end
		local content = render(template, {
			date = date("%Y-%m-%dT%H:%M:%S"),
			vars = {
				previous_note = "[[daily-" .. daily_date(offset - 1) .. "]]",
				next_note = "[[daily-" .. daily_date(offset + 1) .. "]]",
			},
		})
		local ok, werr = write_new(path, content)
		-- EEXIST: another session created it first, open theirs.
		if not ok and not tostring(werr):find("EEXIST", 1, true) then
			return notify("Could not create " .. path .. ": " .. tostring(werr), ERROR)
		end
	end
	open(path)
	return path
end

---Append a Markdown task to `TODO.md` in the vault root
---Create the file when missing, and ask for the text when `title` is omitted
---@param title? string
function M.capture(title)
	local dir = require_vault()
	if not dir then
		return
	end
	if not title or title == "" then
		return vim.ui.input({ prompt = "Capture task: " }, function(t)
			if t and t ~= "" then
				M.capture(t)
			end
		end)
	end
	local path = dir .. "/TODO.md"
	local fh, err = io.open(path, "a")
	if not fh then
		return notify("Could not append to " .. path .. ": " .. tostring(err), ERROR)
	end
	fh:write("- [ ] ", title, "\n")
	fh:close()
	vim.cmd.checktime() -- reload TODO.md if it is open
	notify("Captured: " .. title)
end

-- Templates in an existing note

---Check for a Markdown buffer backed by a file on disk
---@param buf integer
---@return boolean is_markdown
local function is_markdown_buf(buf)
	if vim.bo[buf].buftype ~= "" or vim.bo[buf].filetype ~= "markdown" then
		return false
	end
	local path = vim.api.nvim_buf_get_name(buf)
	return path ~= "" and uv.fs_stat(path) ~= nil
end

---Derive a title from a note file name
---Use the slug when the name has one, and the whole name otherwise
---@param name string file name, without directory
---@return string title
local function title_from_name(name)
	local slug = name:match("^%a+%-%d+%-%d+%-(.+)%.md$")
	return slug and (slug:gsub("%-", " ")) or (name:gsub("%.md$", ""))
end

---Apply a template to a note
---Replace the frontmatter by the template one and insert the template body below the cursor
---@param buf integer
---@param name string template name, without extension
local function insert_template(buf, name)
	local template, err = read_template(name)
	if not template then
		return notify(err --[[@as string]], ERROR)
	end

	local old = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	local old_end = fm_end(old) -- 0 when the note has no frontmatter

	-- The note keeps its own id, date and title, so applying a template never
	-- changes its identity.
	local rendered = render(template, {
		title = fm_get(old, "title") or title_from_name(vim.fs.basename(vim.api.nvim_buf_get_name(buf))),
		date = fm_get(old, "date") or select(2, now()),
		id = fm_get(old, "id"),
	})
	local new = vim.split(rendered, "\n", { plain = true })
	local new_end = fm_end(new)

	-- A template without frontmatter leaves the note's own untouched.
	local fm = new_end > 0 and vim.list_slice(new, 1, new_end) or vim.list_slice(old, 1, old_end)
	if old_end == 0 and #fm > 0 then
		fm[#fm + 1] = ""
	end
	local body = vim.list_slice(new, new_end + 1)
	if body[#body] == "" then
		body[#body] = nil
	end

	-- Body first, so that the frontmatter replacement does not shift its row.
	-- It goes below the cursor, never inside the old frontmatter.
	if vim.trim(table.concat(body, "\n")) ~= "" then
		local row = math.max(vim.api.nvim_win_get_cursor(0)[1], old_end)
		vim.api.nvim_buf_set_lines(buf, row, row, false, body)
	end
	vim.api.nvim_buf_set_lines(buf, 0, old_end, false, fm)
end

-- Pickers

---Pick an item in fzf-lua, or in `vim.ui.select` when fzf-lua is missing
---Cancelling calls nothing
---@param items string[]
---@param prompt string
---@param on_choice fun(item: string)
---@param header? string text above the list
local function pick(items, prompt, on_choice, header)
	-- The same forced load as `require_fzf`, kept apart so that a missing
	-- fzf-lua falls back to `vim.ui.select` instead of failing.
	local ok, fzf = pcall(function()
		require("lib.lazy").load("fzf-lua")
		return require("fzf-lua")
	end)
	if not ok then
		vim.ui.select(items, { prompt = prompt }, function(item)
			if item then
				on_choice(item)
			end
		end)
		return
	end
	fzf.fzf_exec(items, {
		prompt = prompt .. ": ",
		header = header,
		fzf_opts = {
			["--layout"] = "default",
			["--info"] = "inline-right", -- match counter on the prompt line
			["--cycle"] = true, -- wrap around at the ends of the list
			["--no-scrollbar"] = true,
			["--tiebreak"] = "index", -- ties follow the order of the list
		},
		fzf_colors = { ["header"] = { "fg", "Comment" } },
		winopts = {
			height = 0.20,
			width = 1.0,
			row = 1.0,
			col = 0.0,
			border = { "", "─", "", "", "", "", "", "" },
			backdrop = false,
		},
		actions = {
			["default"] = function(selected)
				if selected and selected[1] then
					on_choice(selected[1])
				end
			end,
		},
	})
end

---Create a classified note, picking its type and asking for an optional title
---Cancelling at any step creates nothing
function M.new_note()
	if not require_vault() then
		return
	end
	local types = M.template_names(true)
	if #types == 0 then
		return notify("No templates found in " .. template_dir(), WARN)
	end
	pick(types, "Type", function(type_)
		-- Let the picker close before the title prompt opens.
		vim.schedule(function()
			vim.ui.input({ prompt = "Title (optional): " }, function(title)
				if title == nil then
					return
				end
				local path, err = M.create(type_, title)
				if not path then
					return notify(err --[[@as string]], ERROR)
				end
				open(path)
			end)
		end)
	end, types_header(types))
end

---Pick a template and insert it into the current Markdown file
function M.template()
	local buf = vim.api.nvim_get_current_buf()
	if not is_markdown_buf(buf) then
		return notify("Not a Markdown file", WARN)
	end
	local names = template_choices()
	if #names == 0 then
		return notify("No templates found in " .. template_dir(), WARN)
	end
	pick(names, "Insert template", function(name)
		vim.schedule(function()
			if vim.api.nvim_buf_is_valid(buf) then
				insert_template(buf, name)
			end
		end)
	end, types_header(names))
end

-- Search

---Load fzf-lua and return it, notifying when it is missing
---@return table? fzf
local function require_fzf()
	-- fzf-lua is lazy-loaded on Markdown buffers; force the load so the
	-- search commands work from any buffer.
	-- See: lua/plugins/markdown.lua
	pcall(function() require("lib.lazy").load("fzf-lua") end)
	local ok, fzf = pcall(require, "fzf-lua")
	if not ok then
		notify("fzf-lua is required for searching", ERROR)
		return nil
	end
	return fzf
end

---Search notes by file name with a preview
---Templates and attachments are not listed
function M.find_files()
	local dir = require_vault()
	local fzf = dir and require_fzf()
	if not (dir and fzf) then
		return
	end
	local names = M.notes()
	if #names == 0 then
		return notify("No notes found", WARN)
	end
	fzf.fzf_exec(names, {
		cwd = dir,
		prompt = "Find notes: ",
		previewer = "builtin",
		actions = fzf.defaults.actions.files,
		fzf_opts = { ["--tiebreak"] = "index" }, -- keep newest first on ties
	})
end

---Search the content of the notes with live ripgrep
---Only the `.md` files in the vault root are searched, `README.md` excluded
function M.grep()
	local dir = require_vault()
	local fzf = dir and require_fzf()
	if not (dir and fzf) then
		return
	end
	fzf.live_grep({
		cwd = dir,
		prompt = "Grep notes: ",
		-- `--max-depth=1` keeps `_templates/` and `attachments/` out of the results.
		rg_opts = "--column --line-number --no-heading --color=always --smart-case"
			.. " --max-columns=4096 --max-depth=1 -g '*.md' -g '!README.md' -e",
	})
end

-- Navigation

---Reopen the most recently used note other than the current one
---Look at the listed buffers first, then at `v:oldfiles`
function M.last()
	if not require_vault() then
		return
	end
	local here = vim.api.nvim_buf_get_name(0)
	local bufs = vim.fn.getbufinfo({ buflisted = 1 })
	table.sort(bufs, function(a, b) return a.lastused > b.lastused end)
	local candidates = vim.tbl_map(function(b) return b.name end, bufs)
	vim.list_extend(candidates, vim.v.oldfiles)
	for _, path in ipairs(candidates) do
		if path ~= here and M.is_note_path(path) and uv.fs_stat(path) then
			return open(path)
		end
	end
	notify("No note history yet", WARN)
end

---Open the vault folder in Neovim
function M.open_vault()
	local dir = require_vault()
	if dir then
		open(dir)
	end
end

-- Commands

---Install the `:Notes*` commands
function M.setup()
	local cmd = vim.api.nvim_create_user_command

	-- TODO: refactor this to use command line, like in lua/config/keymaps/files.lua.
	cmd("NotesNew", function() M.new_note() end, { desc = "Notes: new note, picks the type and asks for a title" })
	cmd("NotesTemplate", function() M.template() end, { desc = "Notes: insert a picked template into the note" })
	cmd("NotesDraft", function() M.new_draft() end, { desc = "Notes: quick draft" })
	cmd("NotesFiles", M.find_files, { desc = "Notes: find notes by name" })
	cmd("NotesGrep", M.grep, { desc = "Notes: search note contents" })
	cmd("NotesLast", M.last, { desc = "Notes: reopen the last note" })
	cmd("NotesOpen", M.open_vault, { desc = "Notes: open the vault folder" })
	cmd("NotesCapture", function(o) M.capture(o.args) end, {
		nargs = "*",
		desc = "Notes: capture a task into TODO.md, asks for the text without one",
	})
	cmd("NotesDaily", function(o) M.daily(tonumber(o.args)) end, {
		nargs = "?",
		desc = "Notes: open a daily note, optional day offset (`:NotesDaily -1`)",
	})
end

return M
