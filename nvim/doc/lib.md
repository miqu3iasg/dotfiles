# Lib

The `lua/lib/` layer: shared utilities and domain logic

## Synopsis

- `doc/lib.md` — this page
- `lua/lib/` — the libraries
- `doc/development.md` — how to add a helper

## Description

`lua/lib/` holds everything that exists to be required by another file: reusable helpers, shared state and domain logic that more than one feature needs. It is the bottom of the layer stack (`init.lua` > `config` > `plugins` > `modules` > `lib`), and nothing in it requires upwards, ever.

The criterion is binary: a file that exposes commands, autocmds or keymaps is a module (`lua/modules/`); anything else is a lib. Two consequences shape the layer:

- lib files register nothing global by default. The one exception is `lib/lazy.lua`, which registers a single `FileType`/`BufEnter` gate as its whole job and owns it completely. It is the documented exception, not a loophole.
- shared state lives here when several features must agree on it, with one file as its single source of truth (`lib/autoformat.lua` and `lib/exports.lua` are the examples).

A lib is read by strangers more often than a module. It keeps the standard header and annotates its API.

## The libraries

### `lua/lib/buffers.lua`

Helpers to inspect, save and delete buffers without breaking the window layout. A buffer is saved only when it has unsaved changes and a real file name; deleting a buffer keeps every window that showed it, each switching to the most recently used buffer or a fresh empty one; bulk deletes save first and keep anything whose save failed, reporting the count.

API: `M.is_terminal`, `M.is_normal_window`, `M.save_if_modified`, `M.delete`, `M.pick_replacement`, `M.delete_keep_layout`, `M.delete_where`.

### `lua/lib/bigfile.lua`

Decides whether a buffer is big and caches the verdict in `vim.b.bigfile`. The thresholds are 5 MiB of file size, a line longer than 2000 characters, sampled over the first 500 lines. Every feature that switches off on big buffers asks this module, so the numbers are defined once. The verdict is never recomputed for the same buffer, even after the content changes.

API: `M.is_big`.

Consumers: the `cg/bigfile` autocmd, which turns off Tree-sitter, completion, diagnostics, folds, spell, cursorline and relative numbers; native completion, which skips the buffer.

### `lua/lib/colors.lua`

Color and highlight helpers for the colorschemes in `colors/`: hex parsing, blending a color over a background, HSL desaturation and the xterm-256 conversion with its cache. A string spec links to the named group; a table spec derives `ctermfg`/`ctermbg` from its hex colors and mirrors every GUI attribute into `cterm`, so a scheme renders the same on any terminal. It also applies whole group tables, writes the `:terminal` palette and owns the Markdown-frontmatter namespace, kept active only in Markdown windows.

The only state is the conversion cache, which memoizes pure results.

API: `M.rgb`, `M.blend`, `M.desaturate`, `M.to256`, `M.normalize`, `M.apply`, `M.terminal_colors`, `M.frontmatter`.

The full contract is in [colorschemes](./colorschemes.md).

### `lua/lib/headers.lua`

Comment and file-header machinery owned by the snippets: per-filetype comment styles (line, block and docstring), shebangs, filename and date helpers, the declarative header field constructors (`H.*`) and the four header specs. A header is a list of field constructors applied in order, so every header keeps the same field order and usage format; the standard the specs implement is [snippets](./snippets.md).

The comment style table covers Lua, shell, YAML, TOML, Vim, Zig, Scheme, Lisp, C-family, SQL, Haskell, HTML/XML/Markdown, Ruby and more. Unknown filetypes fall back to a `#` line comment. The Lua long-bracket opener is built by concatenation so the file does not contain a literal long-bracket delimiter.

API: `M.render`, `M.build_header`, `M.H`, `M.headers`, plus the style and filename helpers: `M.get_date`, `M.get_year`, `M.get_filename`, `M.get_relpath`, `M.get_basename`, `M.get_clipboard`, `M.comment_styles`, `M.line_comment_sym`, `M.shebang_by_ft`, `M.label`, `M.wrap`, `M.line_prefix`, `M.open_and_first_line`, `M.close_header`, `M.append_to`, `M.inline_style`, `M.open_inline`, `M.close_inline`, `M.oneline_delims`.

The file registers nothing global. It requires LuaSnip because the header constructors produce snippet nodes.

### `lua/lib/keys.lua`

Shared keymap setters. Every mapping gets a `desc` and is silent by default; extra options merge over these defaults, so a caller can turn `silent` off explicitly. The keymap files and the plugin adapters build on them instead of rolling their own wrappers.

API: `M.map`, `M.bmap`, `M.toggle_wo`.

`M.toggle_wo` maps a key that toggles a boolean window option, which is the common shape of the view toggles.

### `lua/lib/lazy.lua`

The filetype-based lazy loader for `vim.pack` plugins, the only indirection in the config. Plugins declare themselves through `M.setup{ src, filetypes, version, configure, after }`; the plugin is installed at startup, but its `plugin/` scripts only run when the first buffer of a declared filetype appears.

Loading runs `configure`, then `:packadd`, then `after`, then fires `FileType` again for the triggering buffer, because the plugin was not on the runtimepath when the original event ran. The gate listens to `BufEnter` as well as `FileType`, which catches buffers opened before the adapter and plugins that register filetypes after load. `M.load(name)` is idempotent and is a no-op before `setup` for that name.

API: `M.setup`, `M.load`. Inspect every lazy plugin with `:autocmd LazyPack`.

The loader is the only lib that registers an autocmd. That is its entire job, not an excuse for other libs to do the same.

### `lua/lib/autoformat.lua`

Single source of truth of the autoformat-on-save state, with two scopes: global (`vim.g.disable_autoformat`) and buffer-local (`vim.b.disable_autoformat`). Formatting runs only when neither disables it. The buffer-local scope is the buffer override; the global commands act on the global scope.

API: `M.enabled`, `M.enable`, `M.disable`, `M.toggle`, `M.toggle_buffer`.

`M.enable` also clears the current buffer override, so a global enable is not silently defeated by a previous buffer toggle.

### `lua/lib/substitute.lua`

Builds substitute command lines without executing them:

- `M.prompt(scope, text, whole_word)` pre-fills a buffer (`%`) or line (`s`) substitution with `gc` flags, cursor between the pattern and the replacement;
- `M.project(text, whole_word)` greps the project with ripgrep using fixed strings and case sensitivity, then substitutes across the files in the quickfix with `cfdo`; it rejects multi-line text and `|`, and requires ripgrep as `'grepprg'`;
- `M.selection(text)` substitutes a literal visual selection, which may span lines, leaving the replacement empty;
- `M.get_visual()` reads the selection and leaves visual mode without touching a register;
- `M.escape_pattern(text, whole_word)` escapes a literal for a magic search pattern and optionally wraps it in `\<...\>`.

The editing keymaps call this from `config/keymaps/editing.lua` and `config/keymaps/search.lua`.

### `lua/lib/search.lua`

Runs the built-in project and buffer searches and acts on the last search pattern:

- `M.grep(pattern, flags)` runs the grep program with a shell-escaped pattern and optional flags;
- `M.run(command, label)` empties the quickfix first, so a failed command cannot leave the previous list behind, closes the window and notifies when there are no matches;
- `M.vimgrep(pattern)` uses the Vim regex engine over `**/*`;
- `M.buffer_grep(pattern)` is `:lvimgrep` on the current buffer and opens the location list when there are results;
- `M.yank_matches(reg)` copies every match of the last search pattern into a register, one per line, following `'ignorecase'` and `'smartcase'` as a search does; multi-line matches are not supported;
- `M.delete_matches()` removes every match of the last search pattern from the buffer, preserving the cursor, the jumplist and the pattern;
- `M.get_selection()` reads the visual selection;
- `M.flash()` temporarily highlights positions without touching the search register;
- `M.setup()` only installs the GNU grep fallback for when ripgrep is missing.

The quickfix window is opened by the `QuickFixCmdPost` autocmd in `config/autocmds.lua`, never from here. The keymaps call this from `config/keymaps/search.lua`.

API: `M.setup`, `M.run`, `M.grep`, `M.vimgrep`, `M.buffer_grep`, `M.get_selection`, `M.flash`, `M.yank_matches`, `M.delete_matches`.

### `lua/lib/exports.lua`

Single source of truth for where exported documents go, used by the pandoc setup, so every feature writes to the same layout. Documents go to `<root>/exports/<reldir>/<name>.<ext>`.

`<root>` is found through the markers in `M.markers`, highest priority first, and the closest parent that has any of them wins:

1. `.exports-root`;
2. a version-control root: `.git`, `.jj`, `.hg`, `.svn`;
3. a project marker: `.obsidian`, `README.md`, `README.markdown`, `README`, `LICENSE`, `LICENSE.md`, `LICENSE.txt`, `Makefile`, `.editorconfig`.

Without a marker, the file's own folder is the root. `vim.g.exports_root` forces the root globally. An unnamed buffer is treated as a file called `scratch`.

API: `M.root`, `M.basename`, `M.exports_dir`, `M.reldir`, `M.output_path`, `M.output_pattern`.

`M.output_pattern()` is the `$root/exports/$dir/$name` form for tools that expand file-name variables themselves, mirroring `M.output_path` so both layouts stay in sync.

### `lua/lib/system.lua`

Host system detection: `M.get_os()` returns `"windows"`, `"mac"` or `"linux"` (everything that is neither, including the BSDs), so OS-specific behavior is asked, not guessed per file.

## Using lib well

- Before writing a helper, look here first; a duplicated helper is a layer violation waiting to happen.
- When two features disagree about a piece of state, the fix is not a flag: move the state into a lib file as its single source of truth and let both ask it. The autoformat module exists for exactly this reason.
- When a lib helper starts wanting a command, an autocmd or a keymap of its own, that is the signal it became a feature: move it to `modules/`.
- A lib should be pure unless its state is the point. Pure functions are easier to test and impossible to desynchronize.
- A lib that reads a global configuration variable should document the variable in the header and expose the lookup, so callers do not read the raw variable.
- Keep the header standard (see [documentation](./documentation.md)); a lib file is read by strangers more often than any other file.

## Adding a lib

1. Decide the layer by the binary criterion. No commands, autocmds or keymaps means lib.
2. Give it the standard header with its `See:` references.
3. Annotate every exported function, table and class.
4. Add it to this page and, if another page depends on it, add a `See:` there.
5. Require it explicitly; there is no auto-discovery.

## Files

- [`lua/lib/`](../lua/lib/) — the libraries
- [`doc/structure.md`](./structure.md) — the layer contract
- [`doc/modules.md`](./modules.md) — the feature layer
- [`doc/colorschemes.md`](./colorschemes.md) — the color library contract

## See also

- [structure](./structure.md)
- [modules](./modules.md)
- [development](./development.md)
- [documentation](./documentation.md)
