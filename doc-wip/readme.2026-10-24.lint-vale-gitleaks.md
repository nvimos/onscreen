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
   Since 2026-11-02 the first markdown buffer without styles starts it by itself, once per session, and lints again when it's done.

## Test

1. A `.md` file outside any project with a `.vale.ini`: write `This is very very easy.`,
   `:w` -> write-good / Microsoft hints (`:lua =vim.diagnostic.get(0)`, source `vale`).
2. With `stdpath('data')/vale` removed: opening a markdown file starts the sync; vale diagnostics show up after it, no error.
3. Any file with a GitHub token, `ghp_` + 36 letters/digits, e.g.
   `github_token = "ghp_a1B2c3D4e5F6g7H8i9J0k1L2m3N4o5P6q7R8"`, `:w` -> a gitleaks diagnostic (rule `github-pat`).
   (The AWS sample `AKIAIOSFODNN7EXAMPLE1234` does not match gitleaks' AWS rule: checked 2026-10-31.)
4. A project with its own `.vale.ini`: its rules apply, not the shared ones.

Checked by Claude: loadfile of `lint.lua`. vale and gitleaks not installed or run.
