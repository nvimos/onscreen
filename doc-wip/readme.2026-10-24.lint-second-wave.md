# nvim-lint second wave (idea 14e)

`lua/genja/lint.lua` gained four linters; mason-tool-installer installs them with the others.

| Linter | Filetype | Runs on | Note |
|---|---|---|---|
| hadolint | dockerfile | read, save, InsertLeave (stdin) | |
| ruff | python | read, save, InsertLeave (stdin) | skipped while the ruff language server is attached (lang python in genja-completion011, off by default) |
| editorconfig-checker | every filetype (`M.any`) | read, save (file-based) | only below a `.editorconfig`, run in that dir |
| vint | vim | read, save (file-based) | `--enable-neovim` |

Still later: vale (needs `.vale.ini` + `vale sync`), gitleaks.

## Test

1. `:MasonToolsInstall`, wait, restart nvim.
2. Dockerfile: `FROM ubuntu` (no tag) -> hadolint DL3006.
3. `x.py` with `import os` unused -> ruff F401. With python enabled in `lua/genja/lsp/local.lua`,
   only the LSP's copy shows (`:lua =vim.diagnostic.get(0)`, check `source`).
4. In this repo (has `.editorconfig`): a `.lua` line indented with spaces, `:w` -> editorconfig-checker.
   Outside a dir with `.editorconfig`: nothing.
5. `x.vim` with `let x = 1` at script level, `:w` -> vint scope hint.

Known gap: when the ruff server attaches after the first lint, ruff's nvim-lint diagnostics from
that first run stay until the next lint of the buffer replaces them.
