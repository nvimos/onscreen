# C projects without a build (2026-11-05)

auto-todo P. Code: `plug-wip/genja-completion011.nvim/lua/genja/lang/c_cpp.lua` (language `c_cpp`, off by default).

## What it does

- Without `compile_commands.json`, `compile_flags.txt` or `build/compile_commands.json` in clangd's root:
  clangd guesses with `-I. -Iinclude -Isrc`, and its diagnostics are dropped (false errors on headers
  it can't find). Go-to-definition, references, hover, outline still work.
- `:CCompileDb` writes a database: `cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON` in a CMake
  project, else `bear -- make`; then restarts clangd, and diagnostics come back.

## Turn on

`:EnableLang c_cpp` (`-save` keeps it in `lua/genja/lsp/local.lua`). clangd comes from Mason.

## Test

1. Clone a small C project (e.g. `git clone https://github.com/antirez/kilo`), open `kilo.c`.
2. No red diagnostics; `gd` on a function jumps to it; `K` shows its signature.
3. `:CCompileDb` (needs bear or cmake on PATH): a notification, clangd restarts, real diagnostics appear.
