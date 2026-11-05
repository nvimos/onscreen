# Treesitter parsers for PHP-project web files and Go (2026-11-05)

auto-todo D and E. Spec: `lua/lazyp/my/load-treesitter.lua`.

## What it does

- New parsers in the install list: `css`, `scss`, `twig` (Symfony, Drupal templates), `jsdoc`
  (`/** */` in JS/TS), `regex` (regex literals), `gomod`, `gosum`, `gotmpl`.
- Building parsers needs a C compiler. This machine has none right now (no LLVM, gcc, cl):
  - the spec sets `CC=clang-cl.exe` and puts LLVM's bin on PATH only when
    `C:\Program Files\LLVM\bin\clang-cl.exe` exists (the CLI split the old full path at its space);
  - without a compiler the install is skipped, so starts stay quiet; parsers built earlier keep working;
  - zig is installed but doesn't work: the CLI passes `--target=x86_64-pc-windows-msvc`, zig rejects it.
- The tree-sitter CLI from npm: only `.cmd`/`.ps1` shims are on PATH, which libuv can't start;
  the spec puts `%APPDATA%\npm\node_modules\tree-sitter-cli` (with `tree-sitter.exe`) on PATH.

## To get the new parsers

```
winget install LLVM.LLVM
```

Restart nvim: the missing parsers build in the background (`:messages` shows "Compiling parser").

## Test

1. After LLVM is installed, start nvim once and wait until `:messages` shows no more "Compiling".
2. `:lua print(vim.inspect(require('nvim-treesitter').get_installed()))` lists css, scss, twig, jsdoc, regex, gomod, gosum, gotmpl.
3. Open a `.scss`, a `.twig` and a `go.mod` file: `:InspectTree` shows a tree, colours come from treesitter.
4. In a JS file, a `/** @param {string} x */` comment and a `/a+b/g` literal get their own colours.
