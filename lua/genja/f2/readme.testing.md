# f2 tests

Unit tests for the `<F2>` context picker, with mini.test. Written 2026-10-19;
not run yet.

## Run

- Once: `:Lazy install` (installs mini.test, spec `lua/lazyp/new/mini-test.lua`).
- From `lua/genja/f2/`: `make test`, or one file: `make test-file F=registry`.
  In nvim: `<F2>` in a file here shows `make: test`.
- By hand, from the config root:
  `nvim --headless --noplugin -u tests/minimal_init.lua -c "lua MiniTest.run()"`

## Files

`tests/minimal_init.lua` plus `tests/f2/`:

| file                | covers |
|---------------------|--------|
| `test_registry.lua` | global vs buffer scope, BufWipeout cleanup, same group+label updates, `remove_tasks`, `cond` (true / false / error), invalid tasks skipped, every builder method, nothing registered before `:add()` |
| `test_run.lua`      | keys fed with mappings, function gets `ctx`, every autoremove rule (keys, function true, exit code 0 / custom), plain task names, `cwd`, floaterm, marked order, `merge` |
| `test_sort.lua`     | `group_order`, unknown groups A-Z, `order`, label ties, replacing `group_order` |
| `test_make.lua`     | parsing `make -rRpq` (CRLF too), makefile prefixes, label order and task fields |
| `test_git.lua`      | porcelain parsing: unstaged/untracked kept, staged-only dropped, renames, spaces |
| `test_adhoc.lua`    | when `go mod init` is offered (go file, oil dir, go.mod/go.work, `GO111MODULE=off`); skips without `go` |

- Stateful tests run in a fresh child nvim per case. overseer, floaterm and
  `nvim_feedkeys` are stubbed, so nothing really runs.
- Not covered: the telescope pickers, `M.open()`, the gopls restart.

## Other changes made for the tests

- `lua/lazyp/new/mini-test.lua`: installs mini.test only, never loaded in
  the editor. Upstream name `nvim-mini/mini.test` (was
  `echasnovski/mini.test`), written from memory: if `:Lazy install` can't
  find it, switch back.
- `make.lua`, `git.lua`, `init.lua` expose private parse/sort functions as
  `M._…` for the tests.
- `.luarc.json`: `MiniTest` added to globals.
- `doc-wip/readme.idea18-f2-context.md` Notes mention the tests.

## Manual tests

- What is still to check by hand: `readme.testing-manual.md`.
