# Colorschemes

The custom themes in `colors/` and the shared color machinery

## Synopsis

- `colors/<name>.lua` or `colors/<name>.vim` — one scheme per file
- `lua/lib/colors.lua` — blending, conversion, highlight application and the terminal palette
- `doc/colorschemes.md` — this page

## Description

Themes live in `colors/`, the conventional runtimepath folder, outside `lua/`. Neovim loads them by name through `vim.cmd.colorscheme`, so the file name is the scheme name. `init.lua` selects `plain` last in the startup order.

Most schemes are Lua and build on `lua/lib/colors.lua`; three are Vimscript ports kept as they came. A scheme owns its highlight reset, its `g:colors_name` and its augroups. The shared library owns only pure color operations, highlight application and the terminal palette.

## Available schemes

| Scheme        | File                     | Character                                                                                                                                             |
| ------------- | ------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------- |
| `alabaster`   | `colors/alabaster.lua`   | A port of the Alabaster scheme by mcncl: light background, dark text. Requires `'termguicolors'`.                                                     |
| `brightburn`  | `colors/brightburn.vim`  | The original Vimscript scheme by Erik Bäckman. It finishes early when the terminal has no 256-color support.                                          |
| `classic`     | `colors/classic.lua`     | Traditional Vim colors, for those who preserve tradition.                                                                                             |
| `dosx`        | `colors/dosx.lua`        | Dosbox inspired: bright ANSI colors on a blue background.                                                                                             |
| `elrond`      | `colors/elrond.vim`      | A dark Vimscript port based on `elflord`, maintained by Adrian Perez.                                                                                 |
| `hollow`      | `colors/hollow.lua`      | A hollowed-out port of the `quiet` scheme: pale gray text on pure black, one blue accent for status signals. Requires `'termguicolors'`.              |
| `insanity`    | `colors/insanity.lua`    | For those who are insane.                                                                                                                             |
| `kurokai`     | `colors/kurokai.lua`     | Where darkness meets the colors of Unokai: black background, pink keywords, green functions.                                                          |
| `parchment`   | `colors/parchment.lua`   | A tribute to the classic Vim schemes (desert, zenburn, elflord): warm parchment text on black, khaki statements, salmon strings.                       |
| `pixel`       | `colors/pixel.lua`       | A dark scheme with cyan, yellow and violet accents on black.                                                                                          |
| `plain`       | `colors/plain.vim`       | The default. The Vim default scheme, as Vim ships it.                                                                                                 |
| `solarized`   | `colors/solarized.lua`   | Solarized light for Neovim, based on Ethan Schoonover's palette.                                                                                      |

Activate one for the session with `:colorscheme <name>`. To make it the default, change the final `vim.cmd.colorscheme("plain")` in `init.lua`; that is the only place the default is named.

## The shared library

`lua/lib/colors.lua` is required by the Lua schemes. It has one piece of state, the xterm-256 conversion cache, and every other function is pure.

| Function                    | Behavior                                                                                                                                                                                        |
| --------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `M.rgb(hex)`                | Splits `#rrggbb` into red, green and blue numbers.                                                                                                                                              |
| `M.blend(fg, bg, alpha)`    | Mixes `fg` over `bg`, where 0 returns the background and 1 the foreground.                                                                                                                      |
| `M.desaturate(hex, factor)` | Scales HSL saturation, keeping hue and lightness; 1 keeps the color and 0 makes it gray.                                                                                                        |
| `M.to256(hex)`              | Converts to the nearest xterm-256 color, memoized.                                                                                                                                              |
| `M.normalize(spec)`         | Normalizes one highlight spec: a string becomes a `link`, a table derives `ctermfg`/`ctermbg` from its hex colors and mirrors every GUI attribute into `cterm`. An explicit `cterm` field wins. |
| `M.apply(groups, ns)`       | Applies a whole group table through `vim.api.nvim_set_hl`, in the given namespace.                                                                                                              |
| `M.terminal_colors(colors)` | Writes the `:terminal` palette.                                                                                                                                                                 |
| `M.frontmatter(name, spec)` | Defines the Markdown frontmatter group, kept active only in Markdown windows.                                                                                                                   |

The `cterm` mirroring is what makes a scheme render the same in true-color and 256-color terminals. A scheme that sets only hex colors still gets a usable `cterm` fallback; a scheme with an explicit `cterm` table of attributes skips the derivation.

The markdown-frontmatter namespace is a deliberate exception to "set highlights globally": the frontmatter block is dimmed in Markdown windows, and the namespace is activated per window when a Markdown buffer enters it. A scheme that does not want this behavior simply does not call `M.frontmatter`.

## Writing a scheme

A Lua scheme follows this shape:

```lua
vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then
  vim.cmd("syntax reset")
end
vim.g.colors_name = "name"

local c = require("lib.colors")

local groups = {
  Normal = { fg = "#c0c0c0", bg = "#000000" },
  Comment = { fg = "#5f5f5f", italic = true },
  -- ...
}

c.apply(groups)
c.terminal_colors({ ... })
```

Rules:

- clear and reset highlights first, then set `g:colors_name`;
- define the UI groups a scheme must always cover: `Normal`, `NormalFloat`, `Cursor`, `CursorLine`, `Visual`, `Search`, `IncSearch`, `Pmenu`, `PmenuSel`, `StatusLine`, `StatusLineNC`, `VertSplit`/`WinSeparator`, `LineNr`, `SignColumn`, `Diagnostic*`, `Diff*`, `Directory`, `Title`, `MatchParen` and the `@` Tree-sitter captures;
- prefer semantic groups over hard-coded plugin groups; plugin-specific groups belong in the plugin adapter;
- use `M.blend` and `M.desaturate` instead of hand-computing hex values, so the scheme stays coherent when one color changes;
- keep the terminal palette in the scheme, not in `init.lua`.

A Vimscript scheme keeps its original `hi clear` and `g:colors_name` and can stay a port. It does not get the `cterm` normalization from the library unless it calls it, so verify it in a 256-color terminal.

## Verifying a scheme

A scheme is done when:

- `:colorscheme <name>` runs without error and `:hi Normal` shows the expected values;
- `:checkhealth` reports no errors related to the theme;
- a Markdown buffer renders frontmatter dimmed (or not, by decision);
- the terminal palette is correct in `:terminal`;
- switching away and back does not leave stale highlights;
- the scheme works with `'termguicolors'` off when it claims 256-color support;
- the statusline, diagnostics, diff mode, the explorer, fzf-lua and the completion popup are legible.

## Files

- [`colors/`](../colors/) — one scheme per file
- [`lua/lib/colors.lua`](../lua/lib/colors.lua) — shared color machinery
- [`init.lua`](../init.lua) — the default scheme

## See also

- [lib](./lib.md)
- [config](./config.md)
- [plugins](./plugins.md)
