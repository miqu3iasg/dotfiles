# Lib

The lua/lib/ layer: shared utilities and domain logic

## Synopsis

- `doc/lib.md` — this page
- `doc/reading.md` — how to read the pages

## Description

`lua/lib/` holds everything that exists to be required by other modules: reusable helpers, shared state and domain logic that more than one feature needs. It is the bottom of the layer stack (`init.lua` > `config` > `plugins` > `modules` > `lib`) and nothing in it requires upwards, ever.

The criterion is binary: a file that exposes commands, autocmds or keymaps is a module (`lua/modules/`), anything else is a lib. Two consequences shape the layer:

- lib files register nothing global by default. The one exception is `lib/lazy.lua`, which registers a single `FileType` autocmd as its whole job and owns it completely - the documented exception, not a loophole.
- Shared state lives here when several features must agree on it, with one file as its single source of truth (`lib/autoformat.lua` and `lib/exports.lua` are the examples).

## The libraries

### `lua/lib/buffers.lua`

Helpers to inspect, save and delete buffers without breaking the window layout. A buffer is saved only when it has unsaved changes and a real file name; deleting a buffer keeps every window that showed it, each switching to the most recently used buffer or a fresh empty one; bulk deletes save first and keep anything whose save failed, reporting the count. API: `M.is_terminal`, `M.is_normal_window`, `M.save_if_modified`, `M.delete`, `M.pick_replacement`, `M.delete_keep_layout`, `M.delete_where`.

### `lua/lib/bigfile.lua`

Decides whether a buffer is big (1.5 MiB file size or 1000-character lines, sampled over 200 lines) and caches the verdict in `vim.b.bigfile`. Every feature that needs to switch off on big buffers asks this module, so the thresholds are defined once. API: `M.is_big`.

### `lua/lib/colors.lua`

Color and highlight helpers for the colorschemes in `colors/`: hex parsing, blending a color over a background, HSL desaturation and the xterm-256 conversion with its cache. A string spec links to the named group; a table spec derives `ctermfg`/`ctermbg` from its hex colors and mirrors every GUI attribute into `cterm`, so a scheme renders the same on any terminal. Also applies whole group tables, writes the `:terminal` palette and owns the markdown-frontmatter namespace, kept active only in markdown windows. The only state is the conversion cache, which memoizes pure results. API: `M.rgb`, `M.blend`, `M.desaturate`, `M.to256`, `M.normalize`, `M.apply`, `M.terminal_colors`, `M.frontmatter`.

### `lua/lib/headers.lua`

Comment and file-header machinery owned by the snippets: per-filetype comment styles (line, block and docstring), shebangs, filename and date helpers, the declarative header field constructors (`H.*`) and the four header specs. A header is a list of field constructors applied in order, so every header keeps the same field order and usage format; the standard the specs implement is `doc/snippets.md`. The file registers nothing global. API: `M.render`, `M.build_header`, `M.H`, `M.headers` and the style and filename helpers.

### `lua/lib/keys.lua`

Shared keymap setters: `M.map`, `M.bmap` and `M.toggle_wo`. Every mapping gets a `desc` and is silent by default; extra options merge over these defaults, so a caller can turn `silent` off explicitly. The keymap files and the plugin adapters build on them instead of rolling their own wrappers.

### `lua/lib/lazy.lua`

The filetype-based lazy loader for `vim.pack` plugins, the only indirection in the config. Plugins declare themselves through `M.setup{ src, filetypes, version, configure, after }`; the plugin is installed at startup, but its `plugin/` scripts only run when the first buffer of a declared filetype appears. Loading runs `configure`, then `:packadd`, then `after`, then fires the `FileType` event again for the triggering buffer. Inspect every lazy plugin with `:autocmd LazyPack`. API: `M.setup`, `M.load`.

### `lua/lib/autoformat.lua`

Single source of truth of the autoformat-on-save state, with two scopes: global (`vim.g.disable_autoformat`) and buffer-local (`vim.b.disable_autoformat`); formatting runs only when neither disables it. The buffer-local scope is the buffer override, set by per-filetype opt-outs; `:FormatEnable` and `:FormatDisable` act on the global scope. API: `M.enabled`, `M.enable`, `M.disable`, `M.toggle`.

### `lua/lib/substitute.lua`

Builds `:substitute` command lines: escapes patterns, reads the visual selection and pre-fills the command line with either a buffer substitution or a project-wide one (the latter needs ripgrep as `'grepprg'`). The editing keymaps call this from `config/keymaps/`. API: `M.escape_pattern`, `M.prompt`, `M.project`, `M.selection`, `M.get_visual`.

### `lua/lib/search.lua`

Runs the built-in project searches: `:grep` into the quickfix (`M.grep` takes a shell-escaped pattern, `M.run` a full command line shared with `:Grep`), `:vimgrep` with the Vim regex engine (`M.vimgrep`) and `:lvimgrep` on the current buffer (`M.buffer_grep`). The quickfix window is opened by the `QuickFixCmdPost` autocmd in `config/autocmds.lua`, never from here. `M.setup` only sets the GNU grep fallback for when ripgrep is missing, and `M.flash` temporarily highlights positions without touching the search register. It also acts on every match of the last search pattern in the current buffer: `M.yank_matches` copies each match, one per line, into a register (the unnamed one by default) and `M.delete_matches` removes them from the buffer, leaving the cursor, the jumplist and the last search pattern as they were. Both follow `'ignorecase'` and `'smartcase'` as a search does, and `M.yank_matches` handles only matches inside a single line. The keymaps call this from `config/keymaps/search.lua`. API: `M.setup`, `M.run`, `M.grep`, `M.vimgrep`, `M.buffer_grep`, `M.get_selection`, `M.flash`, `M.yank_matches`, `M.delete_matches`.

### `lua/lib/exports.lua`

Single source of truth for where exported documents go, used by the pandoc setup, so every feature writes to the same layout. Documents go to `<root>/exports/<reldir>/<name>.<ext>`; `<root>` is found through the project markers in `M.markers`, falling back to the file's own folder, or forced globally with `vim.g.exports_root`. An unnamed buffer is treated as a file called `scratch`. API: `M.root`, `M.basename`, `M.exports_dir`, `M.reldir`, `M.output_path`, `M.output_pattern`.

### `lua/lib/system.lua`

Host system detection: `M.get_os` returns `"windows"`, `"mac"` or `"linux"` (everything that is neither, including the BSDs), so OS-specific behavior is asked, not guessed per file.

## Using lib well

- Before writing a helper, look here first; a duplicated helper is a layer violation waiting to happen.
- When two features disagree about a piece of state, the fix is not a flag: move the state into a lib file as its single source of truth and let both ask it (the autoformat module exists for exactly this reason).
- When a lib helper starts wanting a command or an autocmd of its own, that is the signal it became a feature: move it to `modules/`.
- Keep the header standard (see `doc/documentation.md`): a lib file is read by strangers more often than any other file.

## Files

- `doc/reading.md` — how to read the pages
- `lua/lib/` — the libraries
- `doc/structure.md` — the folder structure
- `doc/modules.md` — the feature layer
- `doc/lib.md` — this page
- `doc/development.md` — how to extend the config

## See also

- [structure](./structure.md)
- [modules](./modules.md)
- [development](./development.md)
