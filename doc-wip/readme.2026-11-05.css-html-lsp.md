# CSS and HTML language servers (2026-11-05)

auto-todo L. Lang modules `css` (cssls) and `html` (html) in `plug-wip/genja-completion011.nvim/lua/genja/lang/`,
off by default; on for this machine in `lua/genja/lsp/local.lua` (gitignored).

## Install

Next start (or `:MasonToolsInstall`) installs css-lsp and html-lsp (npm, needs node).

## Test

1. Open a `.css` / `.scss` file: `:checkhealth vim.lsp` shows cssls attached; typing `col` offers `color`.
2. Open a `.html` file: html attached; `<di` completes `<div>`; `K` on a tag shows its docs.
3. `:EnableLang css` / `html` toggle them for the session; `make status` in tests/ lists them.
