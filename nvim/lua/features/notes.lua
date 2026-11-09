-- lua/features/notes.lua

-- Arcanum notes workflow: a flat vault of software-development notes managed
-- from Neovim. It creates quick drafts and typed notes from user-maintained
-- templates, inserts a template into an existing note, searches by name and by
-- content, and reopens the last note.
--
-- Note types, the file name `TYPE-YYYYMMDD-HHmmss[-SLUG].md`, and the slug and
-- collision rules follow the vault's `README.md`. The only frontmatter field
-- written here is `date` (creation time), and the only template placeholders
-- are `{{title}}`, `{{date}}` and `{{adr_number}}`. Renaming a note is left to
-- obsidian.nvim (`:Obsidian rename`), which also fixes the backlinks.
--
-- The vault is `$ARCANUM_DIR`, or `~/dev/arcanum` when unset. Notes live
-- directly in its root. `_templates/` holds the templates and `attachments/`
-- the pasted images. The pickers use `fzf-lua` when it is installed and fall
-- back to `vim.ui.select`.
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

---Accent folding for slugs: single characters map one to one (`tr`), the
---ligatures are handled apart.
---@type table<string, string>
local ACCENTS = {
	["á"] = "a",
	["à"] = "a",
	["â"] = "a",
	["ã"] = "a",
	["ä"] = "a",
	["å"] = "a",
	["é"] = "e",
	["è"] = "e",
	["ê"] = "e",
	["ë"] = "e",
	["í"] = "i",
	["ì"] = "i",
	["î"] = "i",
	["ï"] = "i",
	["ó"] = "o",
	["ò"] = "o",
	["ô"] = "o",
	["õ"] = "o",
	["ö"] = "o",
	["ú"] = "u",
	["ù"] = "u",
	["û"] = "u",
	["ü"] = "u",
	["ç"] = "c",
	["ñ"] = "n",
	["ý"] = "y",
	["ÿ"] = "y",
	["æ"] = "ae",
	["œ"] = "oe",
	["ß"] = "ss",
}

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

---Resolve the vault directory. It does not check that the directory exists.
---@return string
local function vault_dir()
	local dir = vim.env.ARCANUM_DIR
	if dir == nil or dir == "" then
		dir = DEFAULT_VAULT
	end
	dir = vim.fs.normalize(dir)
	return uv.fs_realpath(dir) or dir
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
	local dir = uv.fs_realpath(vim.fs.dirname(path))
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
	local s = vim.fn.tolower(title)
	s = s:gsub("[%z\1-\127\194-\244][\128-\191]*", function(ch)
		return ACCENTS[ch]
	end)
	s = s:gsub("%s+", "-"):gsub("[^a-z0-9%-]", ""):gsub("%-+", "-"):gsub("^%-", ""):gsub("%-$", "")
	if #s > SLUG_MAX then
		s = s:sub(1, SLUG_MAX):gsub("%-+$", "")
	end
	return s
end

---Parse a note file name. Returns nil when it does not follow the convention.
---@param name string
---@return { type: string, ts: string, slug: string }?
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
	return { type = type_, ts = date .. "-" .. time, slug = slug }
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
	local names = {}
	for _, name in ipairs(list_md(vault_dir())) do
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
-- not a YAML parser: top-level `key: value` lines are located by prefix and
-- everything else is left byte for byte as it was.

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

---@param fm? string
---@param key string
---@return string? value unquoted
local function fm_get(fm, key)
	for _, line in ipairs(vim.split(fm or "", "\n", { plain = true })) do
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

---Zero-padded sequence number for the next note of a type (`007`).
---@param type_ string
---@return string
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

---Substitute `{{title}}`, `{{date}}` and `{{adr_number}}`, literally, and leave
---any other double braces alone. The ADR number is only computed when the
---template actually uses it.
---@param content string
---@param title string
---@param date string
---@return string
local function render(content, title, date)
	content = content:gsub("(\ndate:[ \t]*)[\"']({{date}})[\"']", "%1%2")

	local vars = {
		title = title,
		date = date,
		adr_number = function()
			return next_number("adr")
		end,
	}
	for name, value in pairs(vars) do
		local token = "{{" .. name .. "}}"
		if content:find(token, 1, true) then
			local text = type(value) == "function" and value() or value
			content = content:gsub(vim.pesc(token), function()
				return text
			end)
		end
	end
	return content
end

---Guarantee that the frontmatter of `content` has a `date` field. An existing
---one is left alone, a missing one is appended at the end of the frontmatter,
---and a note without frontmatter gets one.
---@param content string
---@param date string
---@return string
local function ensure_date(content, date)
	local fm, body = fm_split(content)
	local fresh = fm == nil
	fm = fm or ""
	if fm_get(fm, "date") == nil then
		fm = fm .. "date: " .. date .. "\n"
	end
	return "---\n" .. fm .. "---\n" .. (fresh and "\n" or "") .. body
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
	local template, err = read_template(type_)
	if not template then
		return nil, err
	end
	local ts, iso = now()
	title = clean_title(title)
	local content = ensure_date(render(template, title, iso), iso)
	return create_file(vault_dir(), type_, ts, M.slugify(title), content)
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
		winopts = {
			height = 0.15,
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

---Quick capture: create a draft with the minimal frontmatter and open it,
---ready to type. There are no prompts.
function M.new_draft()
	local dir = require_vault()
	if not dir then
		return
	end
	local ts, iso = now()
	local path, err = create_file(dir, "draft", ts, "", ("---\ndate: %s\n---\n\n"):format(iso))
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

-- Templates in existing notes

---Apply a template to the current note. The frontmatter of the note, if any, is
---replaced by the one from the template, and the body of the template is
---inserted below the cursor. The existing body is never replaced. The note's
---own `title` and `date` feed the placeholders, so its creation date is kept.
---@param buf integer
---@param type_ string
local function insert_template(buf, type_)
	local template, err = read_template(type_)
	if not template then
		notify(err --[[@as string]], vim.log.levels.ERROR)
		return
	end

	-- Existing frontmatter: values for the placeholders and the lines to replace.
	local text = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n") .. "\n"
	local old_fm = fm_split(text)
	local old_len = 0
	if old_fm then
		local _, newlines = old_fm:gsub("\n", "")
		old_len = newlines + 2 -- the two `---` delimiters
	end

	local _, iso = now()
	local date = fm_get(old_fm, "date") or iso
	local rendered = ensure_date(render(template, fm_get(old_fm, "title") or "", date), date)
	local new_fm, tbody = fm_split(rendered)

	-- Frontmatter lines to write, with a blank line after it when the note had none.
	local fm_lines = { "---" }
	if new_fm and new_fm ~= "" then
		vim.list_extend(fm_lines, vim.split((new_fm:gsub("\n$", "")), "\n", { plain = true }))
	end
	table.insert(fm_lines, "---")
	if not old_fm then
		table.insert(fm_lines, "")
	end

	-- Body below the cursor (never inside the old frontmatter).
	if not tbody:match("^%s*$") then
		local row = math.max(vim.api.nvim_win_get_cursor(0)[1], old_len)
		local body_lines = vim.split((tbody:gsub("\n$", "")), "\n", { plain = true })
		vim.api.nvim_buf_set_lines(buf, row, row, false, body_lines)
	end

	-- Frontmatter: replace the old block (or insert at the top if none).
	vim.api.nvim_buf_set_lines(buf, 0, old_len, false, fm_lines)
end

---Pick a template and insert its body into the current note.
function M.template()
	local buf = vim.api.nvim_get_current_buf()
	if not M.is_note_path(vim.api.nvim_buf_get_name(buf)) then
		notify("Not an Arcanum note", vim.log.levels.WARN)
		return
	end
	local types = M.templates()
	if #types == 0 then
		notify("No templates found in " .. template_dir(), vim.log.levels.WARN)
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

---Fuzzy search by file name, with preview. Templates and
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

---Live ripgrep over the content of the notes, showing file, line
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

---Reopen the last note. When that note is the one already open,
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

---Open the vault folder in Neovim.
function M.open_vault()
	local dir = require_vault()
	if dir then
		open(dir)
	end
end

function M.setup()
	local cmd = vim.api.nvim_create_user_command
	cmd("ArcanumDraft", M.new_draft, { desc = "Arcanum: quick draft" })
	cmd("ArcanumNew", M.new_note, { desc = "Arcanum: new note (pick type and title)" })
	cmd("ArcanumTemplate", M.template, { desc = "Arcanum: insert template into the current note" })
	cmd("ArcanumFiles", M.find_files, { desc = "Arcanum: find notes by name" })
	cmd("ArcanumGrep", M.grep, { desc = "Arcanum: search note contents" })
	cmd("ArcanumLast", M.last, { desc = "Arcanum: reopen the last note" })
	cmd("ArcanumOpen", M.open_vault, { desc = "Arcanum: open the vault folder" })

	vim.api.nvim_create_autocmd("BufEnter", {
		group = vim.api.nvim_create_augroup("arcanum_notes", { clear = true }),
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
