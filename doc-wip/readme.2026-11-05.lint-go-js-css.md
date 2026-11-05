# golangci-lint, eslint, stylelint (2026-11-05)

auto-todo G and H. Code: `lua/genja/ext/lint.lua` (`M.by_ft`, `M.mason`, `ROOT_MARKERS`, `prepare_node`).

## What it does

- **golangci-lint** on Go files, only in projects with `.golangci.{yml,yaml,toml,json}`; runs in that dir.
  Sample: `plug-wip/genja-completion011.nvim/examples/go/.golangci.toml` (v2).
- **eslint** on js, jsx, ts, tsx, vue files, only with an `eslint.config.*` or `.eslintrc*` up the tree.
- **stylelint** on css, scss, less files, only with a `.stylelintrc*` or `stylelint.config.*`.
- eslint and stylelint prefer the project's `node_modules/.bin/<name>` (next to the config), so the
  version matches the project's config; else the one on PATH. Mason installs golangci-lint and
  stylelint; eslint has no Mason package, so it runs only where the project has it.

## Install

`:MasonToolsInstall` (or the next start) installs golangci-lint and stylelint.

## Test

1. Go: copy `examples/go/.golangci.toml` into the examples workspace root (or use it as is in
   `examples/go/`), open `greet/greet.go`, add an unused variable, save: a `golangcilint` diagnostic.
2. Same file without the config (rename it): no golangcilint diagnostics, gopls still reports.
3. JS: a project with `eslint.config.js` and `npm i -D eslint`: open a `.js` file, save: eslint diagnostics;
   `:lua print(require('lint').linters.eslint.cmd)` shows the project's node_modules/.bin path.
4. CSS: a project with `.stylelintrc.json` (`{ "extends": "stylelint-config-standard" }` and the npm package):
   a `.css` file with `color: #FFF` gets a stylelint warning.
