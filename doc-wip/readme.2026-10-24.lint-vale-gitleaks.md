# nvim-lint: gitleaks and vale (idea 14e, third wave)

| Linter | Filetype | Runs on | Note |
|---|---|---|---|
| gitleaks | every filetype (`M.any`) | read, save, InsertLeave (stdin) | reports secrets (API keys, tokens) |
| vale | markdown | read, save, InsertLeave (stdin) | prose style; project `.vale.ini` / `_vale.ini`, else the shared `lint/.vale.ini` |

Files: `lua/genja/ext/lint.lua` (`prepare_vale`, `:ValeSync`), `lint/.vale.ini`.
mason-tool-installer installs both (`M.mason`).

## vale config

- A project with `.vale.ini` (or `_vale.ini`) up the tree: vale runs in that dir and uses it.
- Otherwise the shared `lint/.vale.ini`: styles Vale, Microsoft, write-good, alerts down to
  suggestions. Its styles live in `stdpath('data')/vale/styles` (`VALE_STYLES_PATH`), not in the repo.
- Until the styles are there, vale is skipped (it would print an error instead of results).

## Setup

1. `:MasonToolsInstall`, wait, restart nvim.
2. `:ValeSync`: downloads Microsoft and write-good (a notification says when it's done).

## Test

1. A `.md` file outside any project with a `.vale.ini`: write `This is very very easy.`,
   `:w` -> write-good / Microsoft hints (`:lua =vim.diagnostic.get(0)`, source `vale`).
2. Before `:ValeSync` (or with `stdpath('data')/vale` removed): no vale diagnostics, no error.
3. Any file with `aws_secret_access_key = "AKIAIOSFODNN7EXAMPLE1234"` (or a GitHub token
   `ghp_` + 36 letters/digits) -> a gitleaks diagnostic.
4. A project with its own `.vale.ini`: its rules apply, not the shared ones.

Checked by Claude: loadfile of `lint.lua`. vale and gitleaks not installed or run.
