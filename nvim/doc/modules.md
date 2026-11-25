# Modules

The `lua/modules/` layer: whole features built for this config

## Synopsis

- `doc/modules.md` — this page
- `lua/modules/` — the modules
- `doc/development.md` — how to add a module

## Description

`lua/modules/` holds the features this config writes for itself instead of delegating to a plugin: the statusline, per-directory sessions, the compile runner, the Pandoc export, the notes workflow and a handful of editor conveniences. They are the most opinionated part of the config and the part most adapted to the author's workflow.

A module is a whole feature, not a utility. The contract:

- one file per feature, opened with the standard header;
- `setup()` when the module must register commands, autocmds or keymaps;
- state owned by the module, reached only through its API, never written by another file;
- `lib/` helpers instead of duplicated logic, and no reaching into a plugin's internals when a public API exists;
- no module duplicates what `config/` already provides.

The binary criterion still applies: a file that registers a command, an autocmd or a keymap is a module, anything else is a lib.

## How modules are wired

| Module           | `setup()` called by           | Reason                                                                                     |
| ---------------- | ----------------------------- | ------------------------------------------------------------------------------------------ |
| `statusline`     | `init.lua`                    | It must exist before the plugins and the colorscheme.                                      |

| `compile`        | `init.lua`                    | Its commands and keymaps are global.                                                       |
| `sessions`       | `init.lua`                    | Its manual commands are global; the automatic save/load is wired by `config/autocmds.lua`. |
| `notes`          | `lua/plugins/markdown.lua`    | The note workflow belongs with the Markdown stack.                                         |
| `pandoc`         | `after/ftplugin/markdown.lua` | Its commands are buffer-local to Markdown.                                                 |
| `close_view`     | `lua/plugins/git.lua`         | It exists for Fugitive views.                                                              |
| `markdown_lists` | no setup                      | Pure operations consumed by the Markdown ftplugin.                                         |
| `window_zoom`    | no setup                      | A single API function called from `config/keymaps/windows.lua`.                            |

The split matters when removing a feature: a module with a `setup()` needs its call site removed too; the stateless ones vanish when their last caller does.

## The modules

### `statusline.lua`

A native statusline built on the `'statusline'` option, with no plugin. Segment functions are exposed as the global `StlLine` because the statusline string calls them through `v:lua`.

The rendered active line shows the encoding, end-of-line format and buffer state (`--`, `**` for modified, `%%` for read-only), the file name, the position percentage, the modified flag, line and column, the visual selection size, the search count, the filetype, the git branch, the recording register, the zoom marker and the file size for files of 1 MiB or more. Inactive windows get a reduced line with the same leading indicator, position and path.

Two segments exist but are not currently rendered: the mode label (stored in `vim.g.sl_mode`) and the diagnostic counts (`M.diag`). Both are kept because the statusline string can opt into them; do not document them as visible behavior.

Costly pieces are cached: the git branch in `vim.b.git_branch`, looked up asynchronously per directory with a 30-second TTL; the file size in `vim.b.sl_file_size`, read from disk, so it is stale until a save or a shell change; the search count caps at `>999`.

API: `M.lead`, `M.major`, `M.diag`, `M.selection`, `M.search`, `M.setup`.

### `sessions.lua`

Minimal, fully automatic, per-directory session management on `:mksession` and `:source`, active only inside tmux. The session file for a directory lives in `stdpath("state")/sessions/`, with the path flattened into a single file name.

`config/autocmds.lua` restores the session on `VimEnter` when Neovim starts with no file argument or only a directory argument, and saves it on `VimLeavePre`. The restore is scheduled and nested, so the session's own autocmds run and the startup has finished; the save is wrapped in `pcall`, so a failure never blocks quitting.

A save happens only when at least one real file buffer is open. Special buffers, unnamed buffers, `gitcommit` and `gitrebase` buffers do not count, so using Neovim as the commit editor in a project with a session does not overwrite that session. Explorer buffers (`b:explorer`, the oil/canola marker) are deleted before saving because they are virtual.

API: `M.enabled`, `M.path`, `M.load`, `M.save`, `M.force_load`, `M.force_save`, `M.setup`.
Commands: `:SessionSave` and `:SessionLoad` force the operation regardless of tmux.

`'sessionoptions'` in `config/options.lua` must match what the module saves and restores.

### `compile.lua`

An Emacs-like compile runner. It runs a command asynchronously through `sh -c` and streams stdout and stderr into a `*compilation*` buffer in a bottom 25-line split. The buffer has the `qf` filetype, which puts it under the utility-buffer close behavior. On a nonzero exit, the output is parsed into the quickfix list; gcc/clang, javac and Python tracebacks are parsed, and anything else still shows in the buffer.

State is per working directory: starting a new compile in the same directory kills the previous process, `:Recompile` reruns the last command of that directory, and `:CompileInterrupt` kills it. Only the newest process of a directory owns the state, so an older process still reports its output but does not clobber the new one.

The default command by filetype is `make -k` for the fallback, `python %` for Python, `lua %` for Lua, `cc -o %:r.out % && ./%:r.out` for C, `c++ -std=c++23 -o %:r.out % && ./%:r.out` for C++, and `javac -d out % && java -cp out %:t:r` for Java. `%`, `%:r` and `%:t:r` are expanded word by word.

API: `M.command`, `M.prompt`, `M.recompile`, `M.interrupt`, `M.setup`.
Commands: `:Compile [cmd]`, `:Recompile`, `:CompileInterrupt`.

### `pandoc.lua`

Exports the current Markdown buffer to PDF, EPUB, DOCX or HTML by running Pandoc asynchronously, so the editor never blocks. The buffer is piped through stdin, which means unsaved changes are exported too. Success is silent; only errors and warnings are shown.

The module preprocesses Obsidian image embeds (`![[img.png|caption]]`, `![[img.png|300]]`) into ordinary Markdown images before Pandoc sees the text, because Pandoc does not parse them reliably. Images are looked up in the note's folder and every `attachments/` folder above it, up to `$HOME`.

Preview mode builds and opens the document once, then rebuilds it on every save; Zathura reloads the file itself. Each export loads the pipeline, an optional project `defaults.yaml`, the metadata file, an optional profile and the note's frontmatter, in that order. The full behavior is in [pandoc](./pandoc.md).

API: `M.formats`, `M.viewers`, `M.config_dir`, `M.last`, `M.build`, `M.open`, `M.preview`, `M.setup`.
Buffer-local commands: `:Pandoc [fmt] [profile]`, `:PandocPreview [fmt] [profile]`.

### `notes.lua`

A flat vault of Markdown notes managed from Neovim: quick drafts, typed notes from user-maintained templates, template insertion, task capture, daily notes, search by name and content, and reopening the last note. The vault is `$ARCANUM_DIR`, or `~/dev/arcanum` when unset, and must already exist.

Names follow `TYPE-YYYYMMDD-HHmmss[-SLUG].md`; daily notes are `daily-YYYYMMDD.md`. Templates live in `_templates/`, pasted images in `attachments/`. The module owns the template list, the name parser, the slug rules, the ADR numbering and the two-note history in `stdpath("state")/notes-last`. The full contract is in [notes](./notes.md).

API: `M.vault`, `M.is_note_path`, `M.slugify`, `M.parse_name`, `M.build_name`, `M.notes`, `M.templates`, `M.all_templates`, `M.create`, `M.daily`, `M.capture`, `M.new_draft`, `M.new_note`, `M.template`, `M.find_files`, `M.grep`, `M.last`, `M.open_vault`, `M.setup`.

Commands: `:NotesDraft`, `:NotesCapture`, `:NotesNew`, `:NotesDaily`, `:NotesTemplate`, `:NotesFiles`, `:NotesGrep`, `:NotesLast`, `:NotesOpen`.

### `window_zoom.lua`

Zooms the focused window by showing it as the only window of a new tab, with the original layout intact in its own tab. Toggling again closes the zoom tab. The state is the tabpage-local `t:zoomed`, which the statusline reads. Closing the zoom tab by any other means also ends the zoom.

A single window in a single tab is already full screen, so the toggle does nothing there. The mapping is in `config/keymaps/windows.lua`; the module is stateless apart from `t:zoomed`.

API: `M.is_zoomed`, `M.toggle`.

### `close_view.lua`

Closes Fugitive views (index, status, blame and commit buffers) without ever quitting Neovim. Closing a `gitcommit` buffer discards it and aborts the commit. The mappings are buffer-local and installed by autocmds, scheduled so they override the mappings Fugitive installs after setting the filetype.

In diff mode, `M.close_diff` keeps the working-copy window, closes the other diff windows and turns diff off. `M.close_view` dispatches to it, feeds Fugitive's own `gq` when the buffer is a Fugitive view with that mapping, and otherwise closes the window or replaces the buffer with the alternate one. A `gitcommit` buffer uses the bang form, which aborts the commit.

API: `M.close_diff`, `M.close_view`, `M.map_close`, `M.setup`.

### `markdown_lists.lua`

Native list editing for Markdown buffers: toggling bullets, numbered lists and checklists; cycling the list type; cycling the marker; renumbering; promoting and demoting; clearing list formatting. Operations act on the current line with a count or on the selection, and keep the cursor in the text when they can.

The formatter helpers keep markers and indentation as written and are safe to call from conform formatters, which may run outside the main loop:

- `M.bullet_markers(lines)` records the marker of each bullet;
- `M.restore_bullets(lines, markers)` restores them after formatting;
- `M.tabify(lines, ts)` converts leading indentation to tabs at a given width.

The defaults come from `vim.g.markdown_list_bullets` (the marker cycle, default `-`, `*`, `+`), `vim.g.markdown_list_cycle` (the type cycle, default bullet, check, number, none), `vim.g.markdown_list_bullet` (the bullet of new items) and `vim.g.markdown_list_delimiter` (the numbered delimiter). Buffer-local `vim.b` values take precedence.

API: `M.toggle`, `M.toggle_checklist`, `M.cycle`, `M.clear`, `M.cycle_marker`, `M.renumber`, `M.action`, `M.bullet_markers`, `M.restore_bullets`, `M.tabify`.

The Markdown ftplugin wires the operations to buffer-local keymaps and adds `:ToggleCheckbox`; the module itself registers nothing.

## Writing a new module

Read [development](./development.md). The short version: if it registers a command, an autocmd or a keymap, it is a module; give it the standard header, make `setup()` register what it owns, keep state private behind the API, require `lib/` for anything another file also needs, and wire `setup()` from the file that owns the context.

## Files

- [`lua/modules/`](../lua/modules/) — the modules
- [`doc/notes.md`](./notes.md) — the vault workflow in depth
- [`doc/pandoc.md`](./pandoc.md) — the export pipeline in depth
- [`doc/lib.md`](./lib.md) — the helpers under the modules

## See also

- [structure](./structure.md)
- [lib](./lib.md)
- [development](./development.md)
- [kickstart](./kickstart.md)
