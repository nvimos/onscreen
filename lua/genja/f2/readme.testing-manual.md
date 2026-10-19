# f2 manual tests: not done yet

Things in the `<F2>` picker not yet checked by hand (2026-10-19). Unit tests
cover some of the logic (`readme.testing.md`); these are the user-side checks.
Tick (`[x]`) or delete when done.

Already checked: make items listed in order (before the sub-picker); git `add (N files)` sub-picker
(list, status codes, `<Tab>` marks and moves down, multi-add); marked
`git: add` items merged into one task (before the sub-picker change); adhoc
`go mod init` shown, run, gopls restarted; `add_tasks` and `add_task` with
keys; `buffer(0)` scope; `autoremove()` on keys; `cmd` item in overseer.

## make

- [ ] Sub-picker: `<F2>` in `lua/genja/opt.lua` shows one `make: targets (N)  (nvim)`
  item; picking it opens `make targets: ~/AppData/Local/nvim` with the
  targets (main Makefile first, then `gitea: …`, `lazy: …`).
- [ ] Run a target from it: a harmless one (e.g. `refresh-spell`). Expect an
  overseer task `make refresh-spell` that ends in SUCCESS.
- [ ] `<Tab>` two targets, `<CR>`: two overseer tasks, in mark order.
- [ ] f2's own Makefile: `<F2>` in a file in `lua/genja/f2/` shows
  `make: targets (2)  (f2)` with `test` and `test-file`. Running `test` needs
  mini.test installed (`:Lazy install`) and runs the unit tests.

## git (oil)

- [ ] Diff preview: in the `git: add` sub-picker, a modified file shows its
  `git diff`; an untracked file shows its first lines with syntax colours.
- [ ] Not shown outside oil: `<F2>` in a normal file lists no `git:` item.
- [ ] Clean tree: in oil with no changes, no `git:` item at all.

## adhoc

- [ ] The gopls warning in a Go file without go.mod ends in
  `Fix: <F2> (adhoc: go mod init), or cd … && go mod init …`.
- [ ] In oil, a folder with `.go` files and no go.mod shows the adhoc item.

## Added tasks

- [ ] Function action:
  `:lua require('genja.f2').add_task('demo', 'hello'):fn(function(ctx) print(ctx.dir) end):buffer(0):add()`
  prints the folder `<F2>` looked in.
- [ ] Function + autoremove: `:fn(function() return true end):autoremove()`
  disappears after a run; with `return false` it stays.
- [ ] `cond`: `:cond(function(ctx) return ctx.filetype == 'lua' end)` (no
  `buffer`) shows in Lua files only.
- [ ] Broken `cond` (`function() error('boom') end`): item hidden, one
  message naming `registry.lua` and `boom`.
- [ ] Invalid task (no label, or both `action` and `cmd`): skipped with a
  message, the valid ones in the same call still added.
- [ ] `remove_tasks({ group = 'demo', buffer = 0 })` removes the demo items;
  without `buffer` only global ones go.
- [ ] Wiping the buffer (`:bwipeout`) drops its tasks: reopen the file,
  `<F2>`, no `demo:` items.
- [ ] `order`: two items in one group with `:order(2)` / `:order(1)` show
  in that order, not A-Z.
- [ ] `group_order`: `:lua require('genja.f2').group_order = { 'demo', 'make' }`
  puts `demo:` first, `make:` next, the rest after.

## Commands

- [ ] Floaterm: `:cmd({ 'git', 'status' }):floaterm()` opens a floaterm in
  the file's folder.
- [ ] Floaterm + autoremove: `:cmd('git status'):floaterm():autoremove()`
  removed after the terminal exits with 0.
- [ ] Cmd autoremove in overseer: `:cmd({ 'git', 'status' }):autoremove()`
  removed after SUCCESS; `:cmd({ 'git', 'nosuchcmd' }):autoremove()` stays
  (FAILURE).
- [ ] Custom exit code: `:autoremove(1)` on a failing command removes it;
  on a succeeding one it stays.
- [ ] `:cwd('C:/')`: the task runs there (`git status` fails: not a repo).

## Picker

- [ ] Marked items from different groups run in mark order (e.g. mark
  `demo: go to bottom`, then `demo: go to top`: cursor ends at the top).
- [ ] `no context here (<dir>)` in a folder with no Makefile, not Go, not
  oil, and no added tasks (e.g. `:e C:/Windows/win.ini`).
- [ ] `g.` / `,/` menu lists `context picker (<F2>: adhoc, git, make)` and
  it opens the picker.
