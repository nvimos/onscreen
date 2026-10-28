# nvim-lint first wave (#14e)

What: linters for filetypes without a language server for that job. They
show as normal diagnostics (`]d`, `[d`, the diagnostic float and lists).

Files: `lua/genja/ext/lint.lua` (lists, conditions, WSL ansible-lint, autocmds),
spec `lua/lazyp/new/nvim-lint.lua` (now loads on `VeryLazy`), installer list
in `lua/lazyp/langs-comps/mason-tool-installer.lua`, configs
`lint/.markdownlint.jsonc`, `selene.toml` + `vim.yml` (repo root).

## Linters

| Filetype | Linter | Runs when |
|----------|--------|-----------|
| markdown | markdownlint-cli2 | always; shared config: line length off |
| markdown, gitcommit | typos | after `:w` (reads the file) |
| yaml | yamllint | always |
| yaml in `.github/workflows/` | actionlint | workflow files only |
| yaml.ansible (`.yml` here) | ansible-lint in WSL | not workflows; after `:w`; distro from `phpactor_wsl.distro` in `lsp/local.lua` |
| lua | selene | a `selene.toml` up the tree (this repo has one) |
| make | checkmake | after `:w` |
| php | phpcs | a `phpcs.xml` / `.phpcs.xml(.dist)` up the tree |

- Runs on `BufReadPost`, `BufWritePost`, `InsertLeave` (stdin linters only).
- A linter whose command isn't on PATH is skipped quietly.
- selene and phpcs only with a config, like phpstan / php-cs-fixer in
  genja-completion (inferred from that rule; say if you want them always on).

## Install

```
:MasonToolsInstall
```

installs the 7 mason packages (plus the LSP list). markdownlint-cli2 needs
node, yamllint needs python. ansible-lint goes into the WSL distro:
`wsl -d <distro> -- pipx install ansible-lint` (or the distro's package).

## Try it

1. `:MasonToolsInstall`, wait, restart nvim.
2. Markdown: open a `.md` with `#heading` (no space): markdownlint warns
   (MD018). Write `teh`, `:w`: typos warns.
3. YAML: a `.yaml` with a tab or a duplicate key: yamllint.
4. Workflow: `.github/workflows/x.yml` with `needs: nope`: actionlint.
5. Ansible: a playbook `.yml`, `:w`: ansible-lint in WSL (first run is slow).
6. Lua in this repo: an unused local: selene warns. `vim` is not flagged
   (vim.yml).
7. Makefile without `.PHONY`, `:w`: checkmake.
8. PHP in a project with `phpcs.xml`: phpcs.
9. Commit popup: typos runs next to gitlint.

Checked by Claude: headless `loadfile`, `require('genja.ext.lint')`, `setup()`
with nvim-lint on a markdown buffer (no tools installed: no errors). No
linter was installed or run. checkmake's upstream args quote the format with
single quotes, which cmd.exe passes on as-is; if checkmake shows nothing,
that's the first suspect.
