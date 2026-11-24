# Documentation

The documentation standard of this Neovim config

## Synopsis

- `doc/documentation.md` — this page
- `doc/reading.md` — how to read the pages
- `doc/structure.md` — where each page belongs

## Description

Documentation in this config is an engineering artifact, not decoration. It exists so a future reader, usually the author six months later, can understand a file's purpose, its decisions and its external requirements without opening every other file.

Three principles govern it:

1. The code is the primary documentation. Comments explain why, not what; the what is the code itself. A header is a short index of the file, never a narration of it.
2. Every file is self-contained. A reader of a file should not need to open others to know what it does; cross-reference with `See:` instead of narrating elsewhere.
3. Detail lives where it is maintained. The code comments index, the `doc/` pages give the overview, and the official documentation of Neovim and each plugin carries reference detail. No layer repeats another.

The repository migrated from Vim help files to Markdown. The pages are now Markdown documents, and the standard below is the Markdown one; the old man-page rules about full-width prose and no formatting no longer apply.

## The layers

Documentation exists in three layers, from nearest to farthest:

Header comments
: Every file under `lua/` and `after/ftplugin/` opens with a short header: what it is, the exception that the code cannot show, its dependencies and its references. It indexes, it does not narrate.

`doc/` pages
: Overviews for a reader new to the config: what exists, where it lives, how the pieces relate. Never a substitute for the headers. Written in Markdown, with headings, tables, fenced code and relative links.

`README.md`
: The repo-level overview: structure, conventions, how to add things and requirements. One dense paragraph per topic, no fluff, with a pointer to the docs.

## File headers

Every file starts with a path comment and a short header block:

```lua
-- lua/modules/compile.lua

-- Native, Emacs-like `:Compile` that runs a build command
-- asynchronously and streams its output into a `*compilation*`
-- buffer. Failing output goes to the quickfix list.
--
-- State is kept per working directory and owned by this module.
--
-- The compilers come from the distribution.
--
-- $ sudo pacman -S gcc clang jdk21-openjdk python
--
-- See: lua/config/autocmds.lua
-- See: :help quickfix
```

The rules of the header:

- Line 1 is the file's own path: `-- lua/<path>.lua`, or `-- after/ftplugin/python.lua` for ftplugins.
- One blank line, then one or two lines saying what the file is and why it exists.
- One or two lines of exception follow, only when the code cannot show them: load order, state that another file reads, a caveat that would otherwise be lost.
- External dependencies take one short sentence for the whole block, a blank line, then the commands, one per line, consecutive, with no indentation and no label such as `Requires:`.
- References come last, one `See:` per line, in the order `doc/`, `lua/`, `:help`, `man:`, URL, with no blank lines between them. Keep only what a reader would not find alone.
- The header does not list API, explain settings, carry dates or versions, or keep a changelog. `doc/lib.md`, `doc/modules.md` and the official documentation already do that.
- Aim for twelve lines without dependencies and twelve plus the number of commands with them. A longer header is a signal that detail belongs in a doc page.

The header is at most an index. If a header needs a paragraph, the paragraph belongs in `doc/`.

## Lua annotations

Every function, exported table, class and constant that LuaLS cannot infer carries an annotation block directly above its definition, with no blank line between them. The annotations are the API documentation, and they are the part of the comments that is never trimmed.

- The summary is one line, at most two, in the imperative for functions, with no final period.
- `---@param name type` for each meaningful parameter, `?` for optional and `|nil` for nullable. Underscore parameters are not annotated.
- `---@return type name` for each returned value. A function without a return takes no `---@return`.
- `---@class` and `---@field` describe module tables, options and contracts. Fields use a noun phrase.
- `---@type` covers constants and variables whose type is not inferable.
- `---@see` points only at a Lua symbol. A file, a help tag or a URL is ordinary text, `--- See: ...`.
- A type outside the workspace is declared as a minimal `---@class` in the file, or written as `table` or `any`. Never a type that LuaLS reports as undefined, and never a suppression without a one-line reason.

Annotations are part of the API. A behavior change that changes a signature or a return value changes its annotation in the same commit.

## Cross-references

In code, a pointer to related material is a `See:` line, grouped at the bottom of the header or after the paragraph that needs it:

```lua
-- See: lua/config/pack.lua     a file, from the repo root
-- See: :help lsp               a help tag
-- See: man:rg                  a man page
-- See: https://github.com/...  an external source
```

Conventions:

- File paths are relative to the repo root and written in full (`lua/lib/buffers.lua`), never as bare file names.
- The line keeps its colon, `See:`, in the header and in the body.
- References are symmetric when it makes sense: if A's header says "See: B", B's header usually says "See: A". A reader should be able to traverse the whole feature from any of its files.
- Inline `See:` comments in the body mark the spot where a dependency matters, for example above a `sessionoptions` line that must match `modules/sessions.lua`.
- Trivial, adjacent references are omitted. Not everything is linked, only what a reader would otherwise miss.
- In doc pages, cross-references are relative Markdown links (`[modules](./modules.md)`), and file paths in prose are backticked (`lua/lib/exports.lua`).

## Markdown page format

Every page is one Markdown file named after its subject, with a first-level heading, a short synopsis and the sections below. The standard shape:

```markdown
# Subject

One sentence saying what the page is about.

## Synopsis

- `file/or/folder` — what it owns
- `doc/page.md` — this page

## Description

What the subject is and why it exists. The mental model goes here.

## ... topic sections

...
```

Rules for the pages:

- One first-level heading per page. The title is the page subject, not the folder name.
- `## Synopsis` lists the files a reader needs and the page itself.
- `## Description` gives the mental model. Topic sections follow in reading order.
- `## Files` closes the page with links to the files that implement the subject, using paths relative to the page (`../lua/...`).
- `## See also` closes with relative links to related pages, then any `:help` tags.
- Fenced code blocks for shell, Lua, YAML and directory trees. Use `console` or `sh` for commands, and include the `$` prompt only where it helps.
- Tables are allowed for commands, options and inventories. Keep them narrow enough to read in a split window.
- Inline code for identifiers, options, commands and paths.
- Relative links for pages and repository files. Do not use absolute URLs to this repository.
- No HTML, no raw CSS, no badge walls, no generated tables of contents.
- No dates or version numbers in the page body unless they are part of the behavior. The git history carries the timeline.
- No keymaps in the pages. They change too often; a stale keymap list is worse than none. Describe the feature, its commands or its files, and point to the keymap module when the reader needs the keys.
- Commands are documented with their arguments, even when a keymap also triggers them, because commands are stable and keys are not.

## Writing style

- Language is English, present tense, direct. Functions and commands use the imperative.
- State behavior, then the reason. "The LSP stack stops clients" is better than "clients are stopped".
- Prefer short paragraphs over inventories. A list is for things that are actually a set, not for sentences that lost their punctuation.
- No em dash. Use a comma, a period or a colon.
- No marketing adjectives and no filler such as "simply", "basically" or "note that".
- Do not claim behavior that is commented out, planned or true only on another branch. The page describes what the code does now.
- When behavior is a deliberate limitation, say so and name the consequence, for example "the search count caps at `>999`".
- Quote option and command names in backticks: `'sessionoptions'`, `:Pandoc`, `M.build`.
- Name the scope when it matters: buffer-local, window-local, global, tabpage-local.

## Keymaps

Keymaps are the deliberate exception to "document everything":

- they are never listed in `doc/` or in the README;
- a code comment describes behavior, not the keys that trigger it;
- the `desc` field of each mapping and the keymap files are the documentation, and they surface in `:map` and the completion of the leader menu;
- a keymap that only makes sense inside one plugin lives in that plugin's adapter; all others live in the matching theme file under `lua/config/keymaps/`;
- when a feature page needs a trigger documented, document the user command instead.

## Keeping docs current

Documentation is part of the change:

- a behavior change updates the header of the file that owns it and the matching `doc/` page in the same commit;
- moving a feature between layers moves its `See:` web with it; dead references are bugs;
- adding a new module kind, a new convention or a new page updates this page and the inventory in [structure](./structure.md);
- changing a threshold, a command signature or a naming rule means grepping the docs for the old value, not just editing the code;
- the README changes only for structural or requirement changes, not for every small edit;
- `nvim-pack-lock.json` is generated; do not document its contents as if they were decisions.

A useful check before committing a doc change:

```sh
rg -n "TODO|TBD|FIXME" doc README.md
rg -n "kickstart|structure|modules|lib|pandoc|snippets" doc/*.md
```

The first finds placeholders left behind. The second finds cross-references; open each one and confirm the target exists.

Review checklist for a doc-affecting patch:

1. Does the file header still index what the file does?
2. Are the exceptions the code cannot show still stated?
3. Are new external tools documented with their install command in the header?
4. Are new functions, tables and classes annotated for LuaLS?
5. Are `See:` references added, and none left dangling?
6. Does the header stay an index, with no list, changelog or narration?
7. Do the `doc/` pages contradict the code anywhere?
8. Is the affected page in the synopsis and the "Files" list of its neighbors?
9. Are commands documented with their arguments?
10. Are keymaps still absent from the pages?

## Files

- [`README.md`](../README.md) — the repo overview
- [`doc/reading.md`](./reading.md) — how to read the pages
- [`doc/structure.md`](./structure.md) — the page inventory and the folder contract
- [`doc/development.md`](./development.md) — how to change the config and its docs
- [`doc/snippets.md`](./snippets.md) — the snippet and header standard
- [`lua/lib/headers.lua`](../lua/lib/headers.lua) — the header machinery the snippets build on

## See also

- [kickstart](./kickstart.md)
- [structure](./structure.md)
- [development](./development.md)
- [snippets](./snippets.md)
