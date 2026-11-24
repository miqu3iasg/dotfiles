# Development

How to extend this Neovim configuration without breaking its structure

## Synopsis

- `doc/development.md` — this page
- `doc/structure.md` — the layer contract
- `doc/documentation.md` — the docs standard

## Description

This is a recipe book for changing the config. The design goal is that adding or removing a feature is a local operation: one file, plus at most one entry elsewhere. Anything that breaks that rule should be fixed before it grows.

Read [kickstart](./kickstart.md) for the vocabulary and [structure](./structure.md) for the layers. The one rule to keep in mind:

```
init.lua > config > plugins > modules > lib
```

A layer may only require the layers below it. Nothing in `lib/` requires upwards. When a change wants to violate the rule, the shape to prefer is: move the domain logic into `lib/`, let the caller pass the state in, or merge the two layers into one. A new flag is not a fix.

## Before changing anything

1. Read the file that owns the behavior and the page that documents it.
2. Grep for the function, option or command you are about to touch. The callers are part of the change.
3. Decide the layer by the binary criterion: commands, autocmds or keymaps mean `modules/`; otherwise `lib/`.
4. Check the blast radius: a shared helper used by two features is a different change from a helper used by one.
5. Plan the verification before writing. The section below lists the checks.

## Verification

There is no test suite for the editor. The checks are:

```sh
# Load the config headlessly and report errors.
nvim --headless --cmd 'set rtp+=.' -u init.lua -c 'qa' 2>&1

# The external-tool report.
nvim --headless -c 'checkhealth config' -c 'qa' 2>&1

# The formatting rules of the config itself.
stylua --check lua
```

Interactive checks depend on the change:

- a plugin adapter: start Neovim and inspect `:scriptnames`, `:messages` and the plugin's own info command;
- a lazy plugin: inspect `:autocmd LazyPack` and open a triggering buffer;
- an LSP server: open a buffer of the language and inspect `:checkhealth lsp` and the attach state;
- a module command: run it on a real buffer, including the cancel path and the failure path;
- a session or notes change: use a throwaway directory or vault, never the real one;
- a doc change: confirm every relative link and every `See:` target exists.

A change that only touches documentation still deserves a headless load, because a broken `init.lua` is not a documentation problem.

## Adding an eager plugin

Eager plugins load at startup. Three steps:

1. Declare it in `lua/config/pack.lua` with a `src` URL and a short comment explaining what it is. If it needs a build step, handle `PackChanged` in the same file. Existing examples: `TSUpdate` for Tree-sitter and `make install_jsregexp` for LuaSnip.
2. Create `lua/plugins/<name>.lua`, the adapter, starting with the standard header.
3. Register the module in the load list of `lua/plugins/init.lua`, in dependency order. Each module loads inside `pcall`, so a broken one notifies instead of aborting startup.

Removing an eager plugin is the same list backwards: delete the adapter, its `pack.lua` entry, its `init.lua` entry, and any keymaps that lived in the adapter.

Do not add an eager plugin for something heavy and filetype-bound. That is the lazy case below.

## Adding a lazy plugin

Use lazy loading when the plugin is only useful for specific filetypes and its `plugin/` scripts are heavy on startup, or when it has no natural filetype trigger and should load on first use.

The adapter shape is the one in `lua/plugins/lisp.lua` (filetype trigger) and `lua/plugins/fzf.lua` (on-demand):

1. Create `lua/plugins/<name>.lua` with the standard header, `local M = {}`, and the hooks as module functions.
    - `M.configure()` holds the globals the plugin reads while loading and runs before `:packadd`.
    - `M.after()` holds anything that needs the plugin already loaded and runs after `:packadd`.
    - Omit a hook the plugin does not need.
2. At the bottom of the file, before `return M`, declare it:

```lua
require("lib.lazy").setup({
  src = "https://github.com/...",
  filetypes = { "tex" }, -- load triggers; omit for on-demand
  configure = M.configure,
  after = M.after,
})
```

3. Nothing else. No `pack.lua` entry and no `init.lua` entry: the lazy plugin is fully self-declared and disappears with its file.

The plugin name is derived from `src` and must match the directory `vim.pack` installs.

For an on-demand plugin, declare no `filetypes`. Its keymaps are stubs that call `require("lib.lazy").load(name)` and then the plugin function, so the first press pays the load and every later press is instant.

Caveats, also documented in `lua/lib/lazy.lua`:

- a filetype whose detection depends on a global owned by the plugin must set that global at the top level of the adapter, because the plugin is not on the runtimepath at detection time;
- buffers already open when the adapter runs are caught by the loader's `BufEnter` gate;
- the loader fires `FileType` again after `:packadd`, because the original event ran without the plugin.

Inspect every lazy plugin with `:autocmd LazyPack`.

## Adding a language server

One module per server under `lua/language/servers/<name>.lua`, following the `UserLspServerModule` contract in `lua/language/types.lua`:

- a `config` table passed to `vim.lsp.config(name, config)`;
- an optional `on_attach(client, bufnr)` hook, run by the shared `LspAttach` autocmd.

Then:

1. Add the server name to the `modules` list in `lua/language/init.lua`. The order is meaningless.
2. Mason installs it at startup after the schedule. To install manually: `:MasonInstall <server>`.
3. If the server is only ever started elsewhere, like jdtls, put it in `install_only`; the stack ignores it, and its own wrapper must handle enabling, disabling and diagnostics.
4. Keep the contract exact: a malformed module fails startup with the server's name.

Server-specific behavior goes in `config` when the server accepts it, and in `on_attach` when it is a client-side autocmd or keymap. Examples: `eslint` registers the fix-all autocmd, `lua_ls` sets up lazydev, `marksman` overrides `root_dir`.

Formatting stays out of the servers; conform owns it. Diagnostics display is global and starts off. Do not add a server formatter "just in case" unless the server is the only source of a language feature; the current CSS, HTML and jdtls modules explicitly turn theirs off.

## Adding a formatter or linter

Formatters:

1. Add an entry to `formatters_by_ft` in `lua/plugins/formatting.lua`, ordered as the chain should run.
2. Put formatter flags in the per-formatter config below the table.
3. Document any executable Mason cannot install in the file header, with the distribution or language-package line, like the existing entries.
4. Add the tool to `lua/config/health.lua` if it is a base tool or a commonly missing per-language one.
5. Check that the matching `after/ftplugin/<ft>.lua` indentation agrees with the formatter. Mismatched indent options cause a format round-trip on save.

Linters: `nvim-lint` in `lua/language/lint.lua` runs command-line tools and attaches plain diagnostics. The Python/ruff entry is the template: a `linters_by_ft` entry, an autocmd, and its own toggle. Keep linting in its own namespace so it can be toggled independently of server diagnostics.

## Adding snippets

One file per filetype in `lua/snippets/<ft>.lua`, returning the snippets. Filetype-adaptive snippets live in `lua/snippets/common.lua`, and the comment and header machinery they build on lives in `lua/lib/headers.lua`.

Register a new filetype, and its inheritance aliases, in `lua/plugins/completions.lua`, which loads snippet modules lazily by filetype. Documentation snippets and file headers follow [snippets](./snippets.md); read it before adding a doc trigger to a new language.

Snippets are data. A snippet that needs logic belongs in `lib/headers.lua` or a small helper the snippet calls, not in a copy of the logic inside the node list.

## Adding filetype options

Buffer-local options for one filetype go in `after/ftplugin/<ft>.lua`, applied after the runtime ftplugins, so overrides stick.

- Keep it options-first.
- If a mapping is needed and shared, prefer a small `lib/` helper; a feature that needs commands or autocmds belongs in `lua/modules/`.
- Logic needed by two or more filetypes goes in `lib/`, never copy-pasted between ftplugins.
- Document style decisions by name ("PEP 8 style", "gofmt style") with a `See:` to the formatter and the server involved.
- Verify the option against the formatter's own defaults. The asm, C, JavaScript, JSON, Lua, Python, sh, SQL, TOML and TypeScript ftplugins each encode a style; changing one without the other produces churn.

`after/queries/` follows the same rule for Tree-sitter queries: an override lives in the filetype folder, not in a global query file.

## Adding keymaps

New keymaps go in the matching theme file under `lua/config/keymaps/`, following its existing `<leader>` groups. A keymap that only makes sense for one plugin lives in that plugin's adapter.

Every mapping gets a `desc` through `lib/keys` or the equivalent `vim.keymap.set` option. The `desc` is the documentation; keymaps are deliberately not listed in `doc/`.

When two mappings collide, the later load wins. Keymap files load in the order in `lua/config/keymaps/init.lua`, and plugin adapters load after them, which is why the tmux navigation can replace the plain split navigation.

## Adding a module

Decide the layer first. Something that exposes a command, an autocmd or a keymap is a module; anything else is a lib.

A module:

- opens with the standard header;
- exposes `setup()` when it must register commands, autocmds or keymaps;
- owns its state and exposes it only through its API, never written from another file;
- is called from `init.lua` for a startup feature, or from the file that owns the context (`plugins/markdown.lua`, `after/ftplugin/markdown.lua`, `plugins/git.lua`);
- has a single reason to fail, and reports it instead of aborting startup when the caller wraps it in `pcall`.

The state rule is what keeps a module replaceable without a project-wide search. If another file needs the state, it asks the module; it does not read the locals.

## Adding a lib

A lib is the right answer when the logic has no commands, autocmds or keymaps. Give it the header, annotate the API, keep it pure unless shared state is the point, and require it explicitly.

If the helper starts wanting a command or an autocmd, it has become a feature: move it to `modules/` and keep only the pure part in `lib/`.

## Adding a colorscheme

Put the scheme in `colors/<name>.lua` (or `.vim`) and activate it with `vim.cmd.colorscheme("<name>")`. A Lua scheme should use `lua/lib/colors.lua` for blending, desaturation, the cterm conversion and highlight application. The checklist is in [colorschemes](./colorschemes.md).

Change the default in `init.lua` only when the default actually changes; the scheme name is not repeated anywhere else.

## Adding or changing a doc page

1. Create `doc/<subject>.md` with the shape described in [documentation](./documentation.md).
2. Add it to the page inventory in [structure](./structure.md) and to the map in [kickstart](./kickstart.md).
3. Link it from the "See also" of its neighbors, and add it to their "Files" lists when it is a primary reference.
4. If the page documents a file that has a header, add the reverse `See:` in the header.
5. Run the link check from [documentation](./documentation.md) and verify every relative path.

A page that is not reachable from [kickstart](./kickstart.md) or [structure](./structure.md) is effectively invisible.

## Changing behavior

A behavior change is not done when the code works. It is done when:

- the header of the owning file still indexes the behavior;
- the matching doc page describes the new behavior, not the old one;
- every threshold, command signature, option name and naming rule mentioned in the docs was grepped and updated;
- dead `See:` references and dead relative links are removed;
- the health check still reflects the external tools the feature needs;
- the verification above passes.

## Removing a feature

Remove in this order:

1. the call site (`init.lua`, a plugin adapter, an ftplugin, a keymap);
2. the module or lib file;
3. its plugin declaration, if it had one;
4. its keymaps, if they live elsewhere;
5. its doc page, or the section that described it;
6. every `See:` and relative link to it.

Leaving the doc behind is the most common mistake. Grep the docs for the feature name before deleting the page.

## Versioning and the lock file

Plugin revisions are pinned by `nvim-pack-lock.json`, written by `vim.pack`. Treat it as generated: update plugins through `:PackUpdate`, not by hand, and do not review it as if it were source.

Neovim 0.12 is the floor. `:PackDel` and `:PackUpdate` become built-ins in 0.13, and the user commands exist to keep the same names working across both. A migration removes the wrappers when the floor moves.

## Files

- [`init.lua`](../init.lua) — the load order
- [`lua/config/pack.lua`](../lua/config/pack.lua) — plugin declarations
- [`lua/plugins/init.lua`](../lua/plugins/init.lua) — adapter order
- [`lua/language/types.lua`](../lua/language/types.lua) — the server contract
- [`lua/plugins/formatting.lua`](../lua/plugins/formatting.lua) — formatter chains
- [`lua/lib/`](../lua/lib/) — the helper layer
- [`doc/documentation.md`](./documentation.md) — the docs standard

## See also

- [kickstart](./kickstart.md)
- [structure](./structure.md)
- [config](./config.md)
- [plugins](./plugins.md)
- [language](./language.md)
- [modules](./modules.md)
- [lib](./lib.md)
- [documentation](./documentation.md)
- [snippets](./snippets.md)
