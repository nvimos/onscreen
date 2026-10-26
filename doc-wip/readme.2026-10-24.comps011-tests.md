# comps011 integration tests: LSP, cmp, linters; groups and slowness

What: `tests/comps011/test_comps011.lua` boots the real config (`init.vim`) in a child nvim,
opens a sample from `tests/comps011/samples/<case>/` (copied to a temp dir) and waits:
LSP cases for the server to attach and report a diagnostic, cmp cases for an `nvim_lsp`
item, lint cases for a diagnostic from that linter. Not enabled / not installed: skipped.

Harness (shared): `tests/helpers/timing.lua`, runner `tests/Makefile`.

## Running

    make test D=comps011           default: every case except those found slow
    make test D=comps011 G=lsp     one group: lsp, cmp, lint
    make test D=comps011 G=fast    only cases not found slow
    make test D=comps011 G=slow    only cases found slow
    make test D=comps011 G=gather  everything, ignoring slow flags: refreshes the timings
    make test D=comps011 G=all     everything
    make timings                   recorded times, slowest first

`G=` works for every test dir; cases not wrapped with `S:case()` always run.

## Timeouts and slowness (four separate settings)

| Setting | Default | Per case |
|---------|---------|----------|
| timeout: how long a case waits | 12 s (`H.TIMEOUT`) | `timeout = 20000` (lua_ls, gopls), `30000` (phpactor, PSES) |
| slow cutoff: what counts as slow | 3 s (`H.SLOW`) | `slow = 8000` (jsonls, gopls), `10000` (lua_ls), below 3 s allowed |

- Each run adds every case's time to `stdpath('state')/genja-tests/timings.json` (a running average,
  run count, last time). A timed-out case counts with its timeout. Skips are not counted.
- A case is slow when its average is above its cutoff; a fast run later pulls the average down
  and unflags it. The file is throw-away: delete it to start over.
- The default run leaves slow cases out; `gather` reruns them to update their times.

## Safety

- `g:genja_lsp_no_install` (new in genja-completion011 `lsp/init.lua`): the children enable the
  installed servers but install nothing. Without it every boot ran mason-lspconfig's
  `ensure_installed`; a child stopped mid-install leaves `mason/staging/` behind.
- mason's bin is put on PATH before the child starts; lazy's `VeryLazy` is fired by hand
  (it waits for `UIEnter`, which a headless child never gets).

## First runs on this machine (2026-10-24)

- lint 10/10 (gitleaks: not installed; vale: needs `:ValeSync`). checkmake only after the
  Windows fix in `lua/genja/lint.lua` (8dd25c3).
- lsp: jsonls, vimls pass. lua_ls: not installed (see below). bashls: attaches, no diagnostic
  in 12 s. gopls: attaches, no diagnostic in 20 s (no `go` on PATH?). autotools_ls: its venv points
  to a Python 3.13 that is gone. phpactor: attach-only now (it reports no syntax errors).
- cmp: vimls passes; lua_ls skipped.

## Found along the way (your setup)

1. lua-language-server is half-installed: `mason/bin/lua-language-server.cmd` is missing,
   `mason/staging/lua-language-server` is left from 21:01. Close every nvim with a Lua file
   open, then `:MasonInstall --force lua-language-server`.
2. autotools-language-server: `:MasonInstall --force autotools-language-server` (venv on a gone Python).
3. vim-language-server crashes scanning `~/Cookies` (EPERM) when its workspace is your home
   (temp dirs sit under `~`, and `~/.git` exists).
4. gitleaks and vale: `:MasonToolsInstall`, then `:ValeSync`.
