# Troubleshooting

How to find out why the editor, a plugin, a server or an export is not working

## Synopsis

- `lua/config/health.lua` — the executable report
- `doc/troubleshooting.md` — this page

## Description

This page is a diagnosis order, not a list of fixes. Most failures in this config come from a missing executable, a plugin that never loaded, a language server that was never installed or a feature that is intentionally off. Check those four before editing code.

## The first five checks

Run these before changing anything:

1. `:checkhealth config` — missing executables by feature. A missing core tool is an error; a missing per-language tool is a warning.
2. `:messages` — errors raised during startup and by `pcall`-wrapped plugin adapters. A failed adapter reports its module name here.
3. `:autocmd LazyPack` — every lazy plugin and the filetypes that trigger it.
4. `:scriptnames` — what actually loaded. A lazy plugin absent from this list has not loaded yet, which is normal.
5. `:verbose set <option>?` — the last file that changed an option. This is the fastest way to find an override from a plugin, an ftplugin or `after/`.

Useful complements: `:map <leader>` for the live mappings, `:lua =vim.version()` for the version, `:checkhealth lsp` for the client state, and `nvim --startuptime /tmp/start.log` for a slow startup.

## Startup failures

`lua/plugins/init.lua` loads each adapter inside `pcall` and notifies with the module name. Read the notification, then reproduce:

```sh
nvim --headless -u init.lua -c 'qa' 2>&1
```

A failure inside `init.lua` itself (options, keymaps, autocmds, filetypes, commands, statusline, pack) is not caught and aborts startup. Run Neovim with `-u init.lua` from the config root to get the traceback. A malformed language server module is a deliberate startup error from `lua/language/types.lua`; the message names the server.

If startup is slow, compare with `--startuptime`. The eager set is intentional; the usual culprit is a plugin build hook (Tree-sitter `TSUpdate`, LuaSnip `jsregexp`) running again after an update.

## A plugin did not load

- For an eager plugin, check `:scriptnames` and the adapter notification.
- For a lazy plugin, check `:autocmd LazyPack`. The plugin loads on the declared filetype or on an explicit `require("lib.lazy").load(name)`.
- A plugin whose filetype detection needs a plugin-owned global must set that global in the adapter before load. This is the documented cue for Conjure and similar plugins.
- A buffer opened before the adapter ran is caught by the loader's `BufEnter` event, but a plugin that only registers a `FileType` autocmd after load still needs a reload of the buffer to see the event.
- For a plugin installed but not active, `:PackUpdate` or a restart fixes the runtimepath. The revision lock is generated; do not hand-edit it.

## Language servers

Diagnostics are off at startup by design. If there are no underlines or signs:

1. check that diagnostics were not toggled off;
2. check that the server attached, with `:checkhealth lsp` or the LSP info view;
3. check that the server is installed, with `:Mason` or `:MasonInstall <server>`;
4. check the filetype. A server started per buffer (jdtls) does not exist until a Java buffer opens;
5. check the LSP stack toggle. Turning it off stops clients; turning it back on restarts them and starts jdtls for open Java buffers.

A server installed but failing to start usually means a missing runtime:

- `pyright` and the JavaScript servers need Node.js and npm;
- `jdtls` needs a JDK 21 or newer under `/usr/lib/jvm` and Python 3 for its Mason install;
- `clangd` needs a compilation database for cross-file accuracy, but works without one for syntax;
- `marksman` treats the nearest `.git`, `README.md`, `README.markdown` or `.marksman.toml` as the workspace root; a note outside such a root uses its own folder.

Formatting never comes from a server in this config. If format-on-save does nothing, the problem is conform or the autoformat state, not the LSP.

## Linting

Python is linted by `ruff` through `nvim-lint`, outside the LSP stack. If lint diagnostics are missing, check that linting is toggled on, that `ruff` is installed (`:MasonInstall ruff` or the system package) and that the buffer is Python. Toggling diagnostics back on re-applies the lint state; if lint was off, it stays off.

## Tree-sitter

Highlighting needs both the parser and the tree-sitter CLI. Install a parser with `:TSInstall <lang>`; the startup list is in `lua/plugins/treesitter.lua`. Tree-sitter indentation exists only for Lua, Python, JavaScript and TypeScript by design.

A big buffer intentionally loses Tree-sitter, completion, diagnostics, folds, spell, cursorline and relative numbers. The thresholds are in `lua/lib/bigfile.lua`: 5 MiB of file size, a line longer than 2000 characters, sampled over the first 500 lines. The verdict is cached in `b:bigfile` and never recomputed for that buffer.

## Formatting and autoformat

- `:checkhealth config` lists the formatters; a missing one disables only its filetype.
- `conform` reports a formatter error on save. Read the notification and run the formatter by hand to see its own message.
- `:FormatEnable` and `:FormatDisable` control the global state; `:FormatToggleBuffer` controls only the current buffer. The precedence is in `lua/lib/autoformat.lua`: formatting runs only when neither the global nor the buffer flag disables it.
- `trim_whitespace` and `trim_newlines` are the fallback for filetypes with no formatter. They do not reformat code.
- ESLint fixes run before conform on save, and only while autoformat is enabled.

## Pandoc export

Pandoc failures are reported with the stderr of the process. The common causes:

- `pandoc` is not installed; the Arch package is `pandoc-cli`;
- PDF export needs XeLaTeX and the TeX Live packages listed in the module header; `zathura` is only the viewer;
- the profile name does not exist in `lua/pandoc/profiles/`;
- the note's YAML frontmatter is invalid or more than 300 lines into the file (the frontmatter check samples the first 300 lines);
- an image path is wrong; images are looked up in the note's folder and every `attachments/` folder above it, up to `$HOME`;
- the output directory is not writable.

Open the export folder through the path printed by the module, or inspect `M.last[buf]` with `:lua =require("modules.pandoc").last[vim.api.nvim_get_current_buf()]`.

## Notes

- A missing vault: set `$ARCANUM_DIR` or create `~/dev/arcanum`. The module never creates the vault itself.
- A missing template: add `_templates/<type>.md` to the vault. `:NotesNew` and `:NotesDaily` create nothing without it.
- File and content search require fzf-lua; type and template pickers fall back to `vim.ui.select`.
- An existing note is never overwritten. A name collision gets a `-2`, `-3`, and so on. If the counter reaches 99, creation stops with an error.
- Daily notes are open-or-create; an existing day is never overwritten, even when its frontmatter is stale.

## Sessions

Sessions are active only inside tmux (`$TMUX` set). A session is saved on exit only when at least one real file buffer is open, so closing Neovim on the explorer alone does not overwrite a saved session. Use `:SessionSave` and `:SessionLoad` to force either direction.

If a session restores the wrong windows, check `'sessionoptions'` in `lua/config/options.lua` against the list the module expects. `buffers`, `curdir`, `tabpages`, `winsize`, `help`, `globals`, `skiprtp`, `folds` and `terminal` are all required for the behavior described in `doc/modules.md`. Explorer buffers are deleted before saving because they are virtual.

## Explorer and viewers

The explorer is canola.nvim, which exposes the oil API. Deletions go to the trash. Viewer mappings by extension need the external application:

- `zathura` for PDF, DjVu, EPUB, CBZ, CBR and XPS;
- `imv` for images;
- `mpv` for audio and video;
- `xdg-utils` for the `xdg-open` fallback.

Missing viewers fall back to `xdg-open`; a missing `xdg-open` produces a job-start error in `:messages`.

## Clipboard and images

Yanks go to the system clipboard through `unnamedplus`, which needs a clipboard provider. img-clip also needs one, such as `wl-clipboard` on Wayland or `xclip` on X11. A headless or SSH session without a clipboard provider cannot paste images, even though the command exists.

## Health matrix

The check is grouped by what breaks, not by package:

- base: `git`, `tmux`, `rg`, `fzf`, `fd`, `node`, `npm`, `make`, `cc`;
- formatters: `stylua`, `clang-format`, `astyle`, `ruff`, `shfmt`, `yamlfmt`, `taplo`, `asmfmt`, `sql-formatter`, `prettierd`, `prettier`, `shellcheck`, `hadolint`, `markdownlint`;
- documents: `pandoc`, `zathura`;
- Java: `java`, `python3`.

A warning for a per-language tool is not an emergency. An error for `rg`, `git` or `node` usually is.

## Files

- [`lua/config/health.lua`](../lua/config/health.lua) — the executable checks
- [`lua/lib/bigfile.lua`](../lua/lib/bigfile.lua) — the big-buffer thresholds
- [`lua/lib/autoformat.lua`](../lua/lib/autoformat.lua) — the autoformat state
- [`lua/modules/sessions.lua`](../lua/modules/sessions.lua) — the session behavior
- [`doc/kickstart.md`](./kickstart.md) — requirements

## See also

- [config](./config.md)
- [language](./language.md)
- [plugins](./plugins.md)
- [pandoc](./pandoc.md)
- [notes](./notes.md)
