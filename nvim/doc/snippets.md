# Snippets

The LuaSnip snippets and the documentation snippet standard of this configuration

## Synopsis

- `lua/snippets/common.lua` — file headers and shared triggers
- `lua/snippets/<filetype>.lua` — one module per filetype
- `lua/lib/headers.lua` — comment styles and header field machinery
- `lua/plugins/completions.lua` — the lazy loader for the modules
- `doc/snippets.md` — this page

## Description

The `lua/snippets/` folder holds LuaSnip snippets, one file per filetype. Two families follow a standard shared across languages: the file headers in `common.lua` and the documentation triggers (`doc*`) in each language file. Other files, Markdown and Scheme, hold writing snippets of their own kind and do not implement the documentation standard.

A documentation trigger names a concept, not a syntax, so muscle memory carries from one language to the next. What changes per language is how the concept renders in that language's official style: Javadoc in Java, the Google style in Python, kernel-doc in C, LuaLS annotations in Lua. The comment styles, filename helpers and header field constructors the snippets build on live in `lua/lib/headers.lua`.

Modules load lazily. `plugins/completions.lua` registers a `FileType` autocmd and requires the matching module on the first buffer of that filetype. `common` is added to `python`, `c`, `scheme`, `lua`, `java`, `javascript`, `javascriptreact`, `typescript`, `typescriptreact`, `sh`, `markdown`, `sql`, `mysql`, `plsql`, `html` and `css`. The aliases are `scheme` to `lisp`, and `mysql` and `plsql` to `sql`.

## The documentation standard

Every `doc*` block follows the same rules:

- The first line is a summary in the style the language prescribes: a summary fragment ending with a period in Javadoc, a short description in Python and LuaLS. C follows kernel-doc, where the brief description follows the name.
- Tags and sections appear in the order the official style lists them. The block carries only the tags that apply; the rest are deleted after expansion.
- Types appear where the style requires them: `{type}` in Javadoc inline tags, `type` in LuaLS annotations, no type in the Google Python docstring.
- The block ends with a line break, so the declaration it documents sits right below it.
- The final cursor, node `i(0)`, lands on the declaration.
- Placeholders are English. The author appears only in file headers, with one exception: Java type documentation keeps `@author` because Javadoc convention expects it there.

## Common triggers

`common.lua` adapts every trigger to the current filetype's comment syntax.

| Trigger  | Expansion                                                                       |
| -------- | ------------------------------------------------------------------------------- |
| `head`   | Personal file header: File, Author, Created, Description, SPDX.                 |
| `shead`  | Study header: identification, source fields, usage, description, license block. |
| `ehead`  | Exercise header: study fields plus a problem statement and a reference list.    |
| `ahead`  | Proprietary header: Google-style copyright line, description, proprietary SPDX. |
| `shb`    | Shebang for the current filetype. Python additionally offers the coding line.   |
| `see`    | One-line `See:` comment using the filetype's line comment symbol.               |
| `seec`   | Like `see`, with the clipboard's first line already pasted.                     |
| `path`   | Comment with the buffer path relative to the working directory.                 |
| `refs`   | `References:` block with one bullet.                                            |
| `drefs`  | Description plus a `References:` block.                                         |
| `spdx`   | Standalone `SPDX-License-Identifier:` line.                                     |
| `mail`   | Personal e-mail address.                                                        |
| `gh`     | GitHub profile URL.                                                             |
| `author` | Author line with name and profile URL.                                          |

The four headers use the filetype's comment style: line comments for shell and YAML, block comments for C and Java, long-bracket comments for Lua, a docstring for Python, and HTML comments for Markdown. They differ in which fields they carry:

| Header  | Fields in order                                                                                       |
| ------- | ----------------------------------------------------------------------------------------------------- |
| `head`  | File, Author, Created, Description, SPDX. No usage block.                                             |
| `shead` | File, Author, Created, Source, By, Location, Usage, Description, SPDX, Copyright.                     |
| `ehead` | `shead` fields, with Problem Statement after Usage, then Description, References, SPDX and Copyright. |
| `ahead` | Copyright line, Description, SPDX. No identification, usage or author fields.                         |

The usage block is a `Usage:` title followed by `Compile:` and `Run:` labels aligned in a column, each command prefixed with `$ `. Java is the exception: it uses `Compilation:` and `Execution:` without the title. A filetype without commands gets the title and an editable placeholder. `shb` exists because a Python header is a docstring only, so the interpreter line cannot come from the header.

`head`, `shead` and `ehead` default the SPDX identifier to `AGPL-3.0-only`; `ahead` defaults to `LicenseRef-Proprietary`. The SPDX line is the last editable identification field. The copyright holder in the study and exercise headers mirrors the Author node, so it is typed once.

An abridged C `shead`, with the source fields left out for space:

```c
/*
 * File:        main.c
 * Author:      Miquéias Alves Medeiros <https://github.com/miqu3iasg>
 * Created:     2026-11-14
 *
 * Usage:
 *   Compile:  $ gcc -Wall -Wextra -Wpedantic -std=c23 main.c -o main
 *   Run:      $ ./main
 *
 * Description: what the file does and why it exists
 *
 * SPDX-License-Identifier: AGPL-3.0-only
 * Copyright:   Copyright (c) 2026 Miquéias Alves Medeiros.
 */
```

There is no Modified field: modification dates belong to version control. The header machinery knows the usage commands for C, C++, Java, Python, Zig, Scheme, JavaScript, TypeScript, Rust, PHP, C#, Haskell, shell, Ruby, Kotlin, Perl and PowerShell.

## Java

Javadoc blocks, in the order the declaration appears:

| Trigger   | Expansion                                                                                                |
| --------- | -------------------------------------------------------------------------------------------------------- |
| `doc`     | Method with `@param`, `@return` and `@throws`.                                                           |
| `docv`    | Void method or constructor: `@param` and `@throws`, no `@return`.                                        |
| `docg`    | Generic class or interface, with `@param <T>`, plus author, version, see and since.                      |
| `docgm`   | Generic method: the type parameter's `@param` comes before the value parameters, then return and throws. |
| `docr`    | Record, with `@param` for each component, plus author, version, see and since.                           |
| `docp`    | A bare `@param` line to add inside an existing block.                                                    |
| `docf`    | One-line `/** ... */` documentation for a field or constant.                                             |
| `docpkg`  | Package documentation for `package-info.java`, ending with the inferred package declaration.             |
| `docd`    | Deprecation text followed by `@Deprecated`, with `since` and an optional `forRemoval`.                   |
| `docsnip` | `{@snippet file="..."}` external example, Java 18 and newer.                                             |
| `doce`    | `<pre>{@code ...}</pre>` example inside a Javadoc block.                                                 |

The standalone Javadoc tags have their own triggers: `link`, `linkp`, `code`, `lit`, `val`, `inh`, `seeref`, `seel` (clipboard URL), `hidden`, `serial`, `summary`, `index` and `systemprop`.

The rest of `java.lua` is scaffolding, not part of the documentation standard: `sol`, `run`, `runsc`, `main` and `pkg` for practice programs; `class`, `aclass`, `sclass`, `iclass`, `iface`, `enum`, `rec` and `constr` for types; `fun`, `pubfun`, `privfun`, `protfun`, `sfun`, `field`, `const`, `getset` and `tostring` for members; `sout`, `souf` and `serr` for output; and `cm`, `cmm` and `nb` for comments and annotation blocks.

## Python

Python uses Google-style docstrings.

| Trigger | Expansion                                                                                                    |
| ------- | ------------------------------------------------------------------------------------------------------------ |
| `doc`   | Function or method with `Args`, `Returns` and `Raises`.                                                      |
| `docv`  | Function or method without a return value: `Args` only.                                                      |
| `docy`  | Generator: `Yields` replaces `Returns`, with `Raises`.                                                       |
| `docr`  | Function or method without parameters, so only `Returns`.                                                    |
| `docc`  | Class docstring with an `Attributes` section.                                                                |
| `docm`  | Module docstring with short and long description and a typical usage example, placed at the top of the file. |

`sol` scaffolds a practice solution class and its main block.

## C

C follows kernel-doc, where `doc` is the struct block and `docfn` the function block.

| Trigger | Expansion                                                                           |
| ------- | ----------------------------------------------------------------------------------- |
| `doc`   | Struct documentation with a brief description and `@member:` lines.                 |
| `docfn` | Function documentation with the signature, `@arg:` lines, `Context:` and `Return:`. |
| `docm`  | `DOC:` file overview with a title and the theory of operation.                      |
| `docf`  | One-line `/* ... */` comment for a field or constant.                               |

`ivm` creates a minimal `int main(void)` program and `sol` a practice solution with its driver. C has no `docv`, `docc` or `docd`: the struct form is `doc`, and there is no annotation language behind the comments.

## Lua

Lua uses LuaLS annotations.

| Trigger  | Expansion                                                                                   |
| -------- | ------------------------------------------------------------------------------------------- |
| `doc`    | Function with `---@param` and `---@return`.                                                 |
| `docv`   | Function without `---@return`.                                                              |
| `docg`   | Generic function with `---@generic` and a related parameter and return type.                |
| `docc`   | Class with `---@class` and one `---@field`.                                                 |
| `docx`   | Choice of `---@alias`, `---@enum` or an exact `---@class`.                                  |
| `docm`   | Module header as plain `--` comments, above the first statement.                            |
| `docp`   | One more `---@param` line.                                                                  |
| `docret` | One more `---@return` value.                                                                |
| `docf`   | One more `---@field`, with an optional `private`, `protected`, `public` or `package` scope. |
| `docs`   | `---@see` reference.                                                                        |
| `doca`   | `---@async`.                                                                                |
| `docd`   | `---@deprecated`.                                                                           |
| `docn`   | `---@nodiscard`.                                                                            |

LuaLS has no `@usage` tag, so references go in `@see`. The field concept lives on annotations, not on one-line comments, which is why `docf` adds a field line instead of documenting one.

## SQL

SQL has one documentation trigger and ordinary comments. There is no per-function doc block:

| Trigger | Expansion                                                                |
| ------- | ------------------------------------------------------------------------ |
| `docm`  | Migration or schema block with `-- Purpose:`, `-- Notes:` and `-- See:`. |
| `cm`    | Single-line `--` comment.                                                |
| `cmm`   | Multi-line `/* ... */` block.                                            |

The rest of `sql.lua` is query and schema scaffolding: `sel`, `selw`, `selc`, `selg`, `selj`, `ij`, `lj`, `ob`, `gb`, `ins`, `insm`, `upd`, `del`, `ct`, `at`, `ci`, `cte` and `case`. The join and CTE snippets mirror their aliases so the two sides cannot drift.

## Markdown

Markdown snippets support writing notes and are not part of the documentation standard:

| Family        | Triggers                                                                                                                               |
| ------------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| Headings      | `h1` through `h6`.                                                                                                                     |
| Tables        | `tbl`, and `tbl<cols>x<rows>` for a custom size, for example `tbl4x5`.                                                                 |
| Code          | `cb`, `ic`, and `cbbash`, `cbsh`, `cblua`, `cbc`, `cbjava`, `cbpy`, `cbscm`, `cbjson`, `cbyaml`, `cbsql`, `cbhtml`, `cbcss`, `cbdiff`. |
| Comments      | `cm`, `cmm`, `cmr`, `todoc`.                                                                                                           |
| Formatting    | `bd`, `it`, `bi`, `st`, `kbd`.                                                                                                         |
| Links         | `link`, `img`, `ref`, `refdef`, `fn`.                                                                                                  |
| Blocks        | `qt`, `hr`, `callout`.                                                                                                                 |
| Note metadata | `front`, with file name, title, description, authors, source, location, links, related notes and timestamps.                           |
| Math          | `math`, `mathb`.                                                                                                                       |
| Date          | `date`.                                                                                                                                |

`front` matches the metadata fields the Pandoc export reads, and `date` inserts the current date in ISO format.

## Scheme

Scheme has comment and REPL snippets, not the documentation standard: `sec` for a `;;;` section header, `cm` for a `;;` block explanation, `cmm` for a `#| ... |#` block, `dat` and `wdat` for datum comments, and `eval` for the `; => result` convention.

## Files

- [`lua/snippets/common.lua`](../lua/snippets/common.lua) — headers and shared triggers
- [`lua/snippets/java.lua`](../lua/snippets/java.lua) — Javadoc and Java scaffolding
- [`lua/snippets/python.lua`](../lua/snippets/python.lua) — Google-style docstrings
- [`lua/snippets/c.lua`](../lua/snippets/c.lua) — kernel-doc
- [`lua/snippets/lua.lua`](../lua/snippets/lua.lua) — LuaLS annotations
- [`lua/snippets/sql.lua`](../lua/snippets/sql.lua) — SQL statements and migrations
- [`lua/snippets/markdown.lua`](../lua/snippets/markdown.lua) — writing snippets
- [`lua/snippets/lisp.lua`](../lua/snippets/lisp.lua) — Scheme comments
- [`lua/lib/headers.lua`](../lua/lib/headers.lua) — the header machinery
- [`lua/plugins/completions.lua`](../lua/plugins/completions.lua) — the lazy loader

## See also

- [documentation](./documentation.md) — the documentation standard
- [development](./development.md) — how to add a snippet
- [language](./language.md) — the LSP stack the annotations target
- [modules](./modules.md)
- [kickstart](./kickstart.md)
