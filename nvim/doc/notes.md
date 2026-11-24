# Notes

The flat Markdown note vault: naming, templates, daily notes, capture and search

## Synopsis

- `lua/modules/notes.lua` — the notes module
- `lua/plugins/markdown.lua` — the Markdown and Obsidian integration
- `$ARCANUM_DIR` — the vault, or `~/dev/arcanum` when unset
- `doc/notes.md` — this page

## Description

The notes workflow is a flat vault of Markdown files managed from Neovim. It is deliberately not a database and not a hierarchy: notes live in the vault root, templates in `_templates/`, and pasted images in `attachments/`. The vault is a normal folder that any editor or script can read; `modules/notes.lua` only owns creation, naming, templates, search and the last-note history.

The vault is resolved once per call from `$ARCANUM_DIR`, falling back to `~/dev/arcanum`. It must already exist; a missing vault produces an error notification and leaves a nil result. `M.vault()` returns the resolved path whether or not it exists.

The vault's own `README.md` is the contract for daily notes and the `nt` command-line companion. It is not a note: `M.is_note_path` excludes it, and search excludes it as well.

## File names

A note is `TYPE-YYYYMMDD-HHmmss[-SLUG].md` in the vault root. The timestamp is local time.

- `TYPE` is one of `script`, `snippet`, `doc`, `bug`, `adr`, `idea` and `content`. The picker shows a short description of each.
- `draft` is a provisional state, written by the quick draft command, and is not offered in the type picker. It is still a valid type when parsing names.
- `SLUG` is lowercase ASCII, derived from the title. Accents are folded, non-alphanumeric characters are dropped, runs of spaces become hyphens, and the result is trimmed and capped at 80 characters. An empty title means no slug.
- If the name is taken, a counter is appended to the slug, `-2` through `-99`. Creation uses an exclusive create (`wx`), so an existing note is never overwritten, even by a race between two Neovim sessions.

Daily notes are different: `daily-YYYYMMDD.md`, one per day. A daily note parses to type `daily` with the timestamp `YYYYMMDD-000000`, which sorts after the typed notes of the same day. The date must be a real calendar date, leap years included.

`M.parse_name(name)` returns `{ type, ts, slug }` or nil. `M.build_name(type, ts, slug, n)` builds the n-th collision name.

### ADR numbering

`{{adr_number}}` is the next ADR number, formatted as three digits. It is not the count of ADR files: the module reads every ADR note and takes the highest `ADR-NNN` found in its body, then adds one. Deleting the newest ADR therefore does not make the next one reuse its number.

### History

The last two notes opened are kept in `stdpath("state")/notes-last`, one path per line. `:NotesLast` reopens the current one, or the previous one when the current note is already open. The history is only updated for files that are notes by `M.is_note_path`, not for README, templates or attachments.

## Templates

Templates live in `_templates/` inside the vault, as Markdown files named after the type: `script.md`, `snippet.md`, `doc.md`, `bug.md`, `adr.md`, `idea.md`, `content.md` and `daily.md`. A template is read on demand; the config does not create them.

Placeholders are substituted literally, and an unknown placeholder is left as written:

| Placeholder         | Value                                                                                                                                |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| `{{title}}`         | The title, as typed.                                                                                                                 |
| `{{date}}`          | Local ISO timestamp, `YYYY-MM-DDTHH:MM:SS`.                                                                                          |
| `{{date:FMT}}`      | The same date with a moment-like pattern. Tokens are `YYYY`, `YY`, `MM`, `DD`, `HH`, `mm` and `ss`; every other character is copied. |
| `{{id}}`            | A random version 4 UUID. Reusing a template in an existing note keeps the existing `id` when the frontmatter has one.                |
| `{{adr_number}}`    | The next ADR number, three digits.                                                                                                   |
| `{{previous_note}}` | `[[daily-YYYYMMDD]]` of the previous day. Only the daily template receives it.                                                       |
| `{{next_note}}`     | `[[daily-YYYYMMDD]]` of the next day. Only the daily template receives it.                                                           |

In the frontmatter, a quoted value such as `title: "{{title}}"` becomes an unquoted YAML scalar when it is safe, and stays quoted when YAML would read it as another type. The module then guarantees a `date` field, adding the frontmatter block when the template has none.

Templates are user-maintained. The notes module does not ship defaults, so a fresh vault must provide them; a missing template produces an error and creates nothing.

Template insertion (`:NotesTemplate`) works on any Markdown file on disk, not only on vault notes. For a vault note it offers only the typed templates; for another Markdown file it offers every template. The template's frontmatter replaces the existing one, and its body is inserted below the cursor.

## Daily notes

`:NotesDaily` opens today's `daily-YYYYMMDD.md`, creating it from `_templates/daily.md` when it does not exist. This is open-or-create: an existing day is never overwritten. The module passes the previous and next day links to the template, which is how the daily chain is maintained without a plugin.

`M.daily(offset)` accepts an integer offset in days, so tomorrow is `M.daily(1)` and yesterday is `M.daily(-1)`. The arithmetic goes through noon to survive daylight-saving shifts. If two sessions race to create the same day, the exclusive create fails with `EEXIST`, and the module opens the file the other session created.

The command-line companion is `nt daily [OFFSET|DATE]`, documented by the vault's README. The Neovim side and the CLI side share the same naming rule, not the same implementation.

## Capture

`:NotesCapture` appends `- [ ] <title>` to `TODO.md` in the vault root, creating the file with the first task when missing. If the file is already loaded in a buffer, the line is appended to the buffer and written, so no second copy is produced. The prompt is skipped when a title is passed to `M.capture(title)`.

## Commands

| Command          | Behavior                                                                                            |
| ---------------- | --------------------------------------------------------------------------------------------------- |
| `:NotesDraft`    | Create a draft with a fresh UUID and open it at the end, ready to type.                             |
| `:NotesNew`      | Pick a type, ask for an optional title and create the note. Cancelling at any step creates nothing. |
| `:NotesCapture`  | Append a task to `TODO.md`.                                                                         |
| `:NotesDaily`    | Open today's daily note, creating it when missing.                                                  |
| `:NotesTemplate` | Insert a template into the current Markdown file.                                                   |
| `:NotesFiles`    | Fuzzy search notes by name, with preview.                                                           |
| `:NotesGrep`     | Live ripgrep over note contents in the vault root.                                                  |
| `:NotesLast`     | Reopen the last note, or the one before it.                                                         |
| `:NotesOpen`     | Open the vault folder in the editor.                                                                |

Search requires fzf-lua. The module loads it on demand; when that fails, type and template pickers fall back to `vim.ui.select`, while file and grep search report that fzf-lua is required.

## Obsidian integration

obsidian.nvim is configured in `plugins/markdown.lua` with wiki links, the shortest link format, `attachments/` as the attachment folder and the vault as its only workspace. Its UI, footer and frontmatter handling are disabled, because this module owns names, templates and dates. The Obsidian picker uses fzf-lua. Link completion comes from Obsidian's LSP; Markdown is intentionally outside the automatic completion filetypes.

img-clip pastes clipboard images into `attachments/` for vault notes, using the Obsidian embed template, and into the project's `attachments/` for other Markdown files, using a relative Markdown image. A clipboard utility such as `wl-clipboard` or `xclip` is required.

## Adding a note type

A new type is a change in four places:

1. add it to `TYPES` in `modules/notes.lua`;
2. add a short description to `TYPE_HELP`, or leave it out of the picker header;
3. add `_templates/<type>.md` to the vault;
4. document the type in the vault README, since the CLI companion must agree.

The file name parser only accepts the listed types, so an unlisted type would create a file that `M.notes()` sorts last and that `M.is_note_path` still accepts as a note.

## Files

- [`lua/modules/notes.lua`](../lua/modules/notes.lua) — the module
- [`lua/plugins/markdown.lua`](../lua/plugins/markdown.lua) — Obsidian and img-clip
- [`after/ftplugin/markdown.lua`](../after/ftplugin/markdown.lua) — Markdown options and list keymaps
- [`doc/modules.md`](./modules.md) — the module API summary
- [`doc/pandoc.md`](./pandoc.md) — exporting notes

## See also

- [modules](./modules.md)
- [plugins](./plugins.md)
- [pandoc](./pandoc.md)
- [kickstart](./kickstart.md)
