# «idea 18 f2 context»: `<F2>` context picker

One telescope dropdown with actions for where you are: make targets, git
adds in oil, one-off fixes, and tasks other scripts register.
Code: `lua/genja/f2/`. Written 2026-10-19; not run or tested yet.

## User guide

### Keys

- `<F2>` (normal mode, `map-telescope.lua`) opens the picker; also in the
  `g.` / `,/` menu as "context picker".
- In the picker: type to filter, `<CR>` runs the item. `<Tab>` marks
  several; `<CR>` then runs all marked, in mark order.
- In the `git: add (N files)` sub-picker: `<Tab>` marks files (moving
  down), `<CR>` adds the marked ones (or the one under the cursor).
- LSP rename's `<F2>` is commented out in `map-lsp.lua`; rename lives in `g.`.

### What shows up

Items read `group: label`. Groups in this order: `adhoc`, `git`, `make`,
`oil`, then any other group A-Z.

- `adhoc: go mod init <dirname>  (<dir>)`
  - a .go buffer, or an oil dir with .go files, with no go.mod/go.work above
  - runs in overseer; on success gopls restarts and leaves single-file mode
  - the gopls "missing metadata" warning points here
- `git: …`, only in oil buffers inside a git repo:
  - `add (N files)` opens a sub-picker: one line per file, `XY path` as in
    `git status --short` (repo-relative; X staged in green, Y unstaged and
    `??` untracked in red); diff preview
    (untracked: first 500 lines)
  - only files with unstaged changes or untracked; staged-only ones are left out
  - one overseer task per `<CR>`: `git add <first> (+N)`
- `make: targets (N)  (<folder>)` opens a sub-picker of targets: `<target>` /
  `<file>: <target>`
  - the Makefile in or above the buffer's dir (oil: oil's dir)
  - `<folder>` is the name of the Makefile's folder: from oil at `~` the
    nearest one is `~/makefile` (`(jazzo)`), not the nvim config's
  - `lazy: sync` is `sync` from `Makefile.lazy.mk`
  - main Makefile's targets first; `<Tab>` marks several; each runs as an
    overseer task
- Tasks added by other scripts (below), in their own group.

Where it looks: oil's dir in oil, the file's dir for a file, else `:pwd`.
Nothing found: `no context here (<dir>)`.

### Adding tasks from a script

```lua
local f2 = require('genja.f2')

-- this buffer only (0 = current); dropped when the buffer is wiped
f2.add_tasks({
  { group = 'adhoc', label = 'go mod tidy', cmd = { 'go', 'mod', 'tidy' }, autoremove = true },
  { group = 'oil', label = 'toggle hidden', action = 'g.', order = 1 },
  { group = 'test', label = 'run tests', cmd = 'go test ./...', runner = 'floaterm' },
}, { buffer = 0 })

-- everywhere, only when cond says so
f2.add_tasks({
  { group = 'lua', label = 'source file', action = '<Cmd>source %<CR>',
    cond = function(ctx) return ctx.filetype == 'lua' end },
})

f2.remove_tasks({ group = 'adhoc', label = 'go mod tidy', buffer = 0 }) -- one task
f2.remove_tasks({ group = 'lua' })                                      -- whole global group

f2.group_order = { 'adhoc', 'git', 'make', 'oil', 'test' } -- replace the order
```

One task with the builder; nothing is registered until `:add()`:

```lua
f2.add_task('demo', 'go to top'):keys('gg'):buffer(0):add()
f2.add_task('go', 'tidy'):cmd({ 'go', 'mod', 'tidy' }):autoremove():buffer(0):add()
f2.add_task('test', 'run tests'):cmd('go test ./...'):floaterm():order(1):add()
f2.add_task('lua', 'source file'):fn(function() vim.cmd.source('%') end)
	:cond(function(ctx) return ctx.filetype == 'lua' end):add()
```

Builder methods: `:keys(s)`, `:fn(f)`, `:cmd(c)`, `:floaterm()`, `:cwd(d)`,
`:order(n)`, `:cond(f)`, `:autoremove(code?)`, `:merge(key)`, `:buffer(n)`,
`:add()`.

Task fields:

| field        | meaning                                                                  |
|--------------|--------------------------------------------------------------------------|
| `label`      | text after `group: `                                                     |
| `group`      | prefix and sort group                                                    |
| `action`     | string: normal-mode keys, with mappings (`<CR>` notation works); or `fun(ctx)` |
| `cmd`        | instead of `action`: `string` or `string[]`                              |
| `runner`     | for `cmd`: `'overseer'` (default) or `'floaterm'`                        |
| `cwd`        | for `cmd`; default: the dir `<F2>` looked in                             |
| `order`      | within the group, lower first, default 0; ties sorted by label           |
| `cond`       | `fun(ctx): boolean`, checked on every `<F2>`; errors hide the task       |
| `autoremove` | remove the task after running: function returned `true` / keys ran / cmd exit code equals it (`true` = 0) |
| `merge`      | key; marked tasks with the same key and cwd run as one cmd: the first `cmd` (a table) plus the last argument of each other |

`ctx` = `{ dir, bufnr, filetype }`.

Adding a task with the same group and label again updates it; other tasks
join the group.

## Decisions

- Per-call picker, no state per buffer. Relevance comes from:
  - sources (make, adhoc, git) checking the current buffer on every `<F2>`
  - added tasks being global (+ `cond`) or scoped to one buffer
  - so `go mod init` from main.go never shows in a split with init.lua.
- One file per source; `init.lua` lists the sources explicitly (no folder
  scan), in picker order. A new source = a file + one line there.
- Source contract: `collect(ctx, done)`, `done(tasks)` with tasks in the
  `add_tasks` shape. Async allowed (make runs `make -rRpq`, git runs
  `git status`). The picker opens once all sources answered; results keep
  source order, not answer order. A source that throws counts as empty.
- One item shape for everything (`genja.f2.Task`), so sources and added
  tasks sort, display and run the same way.
- Sorting: group by `f2.group_order` (set by the caller; groups not listed
  come after it, A-Z), then `order` per group, then label.
- Prefix is the group name + `: `; make targets keep their file prefix
  (`lazy: sync`) in the sub-picker.
- Sources with many items (make, git) give one main-list item that opens a
  sub-picker, so the main list stays short. Make targets and the main list
  share `picker.lua` (dropdown, `<Tab>` marks, `<CR>` runs marked in order);
  git keeps its own picker for the diff preview and status colours.
- `f2.add_task(group, label)` builder next to `add_tasks()`
  (`builder.lua`). Ends in an explicit `:add()` rather than registering on
  creation, so a half-built task never shows; `:add()` goes through the same
  `registry.add`, so validation and merge-by-key are shared.
- Running: overseer by default, floaterm on request, never fugitive.
- Marking works in the main picker too (found in testing: `<Tab>` marked,
  but `<CR>` ran only the cursor item). Marked items run in mark order;
  `merge` joins same-key cmds into one task (built for per-file git adds,
  tested working; no user since git moved to a sub-picker, kept for added
  tasks). Overseer names are the plain cmd (`git add -- x`), not the
  shellescaped one.
- String actions are typed with mappings (`feedkeys 'm'`), like a keymap
  with `remap = true`, so macros can call your own maps.
- `autoremove` acts only on added tasks; source items are rebuilt each time
  (after `go mod init`, go.mod exists, so the item is gone anyway).
- Floaterm exit codes come from `TermClose` (`v:event.status`).
- Git source: oil only, whole repo, repo-relative paths. One `git: add
  (N files)` item opening a sub-picker, instead of the first try (a status
  picker plus one `git: add <path>` item per file, capped at 20 with a
  `(+N modified)` hint): tidier main list, status codes visible.
- Sub-pickers set `sorting_strategy = 'ascending'`: the global config has
  the prompt on top but sorts descending, so `<Tab>` moved up. The global
  `mirror = true` is unrelated (it only swaps preview and list).
- adhoc's rootless check copies the one in genja-completion011's
  `lang/go.lua` instead of requiring plugin internals.
- gopls restart: stop the clients attached under the dir, re-fire
  `FileType` in group `nvim.lsp.enable` (same as `lang/Php.lua`).

### Possible next steps

- First real `add_tasks` caller (e.g. from an ftplugin or `LspAttach`).
- More adhoc fixes: `go mod tidy` after import errors, `npm install` when
  node_modules is missing, `git init` in an untracked dir.
- oil source: oil-specific actions (the `oil` group has a slot already).
- Mouse selection in the picker (todo-ideas: telescope mousability).
- Show a count, or hide groups, when the list is long.

## Git

- Sub-picker lines: `XY path` with git's standard status markers, coloured
  like `git status` (X green, Y and `??` red; groups `Added` / `Removed`).
- To explore later, as an option: match oil-git.nvim (`malewicz1337/oil-git.nvim`, spec
  `lua/lazyp/explorer/oil-git.lua`), which already marks files in oil:
  - reuse its highlight groups: `OilGitAdded`, `OilGitModifiedStaged`,
    `OilGitModifiedUnstaged`, `OilGitUntracked`, `OilGitDeleted`,
    `OilGitRenamed`, `OilGitConflict`, `OilGitCopied`, `OilGitIgnored`
  - reuse its file symbols (`+` added, `~` modified, `->` renamed, `D`
    deleted, `C` copied, `!` conflict, `?` untracked, `o` ignored), read from
    its config rather than copied
  - its `status_mapper.map(status_code, symbols)` maps porcelain XY to
    symbol + group; check whether it is usable from outside
  - maybe a setting to choose: plain XY / oil-git look

## Notes

- Files: `init.lua` (picker, API, sorting), `registry.lua` (added tasks,
  BufWipeout cleanup), `run.lua` (keys / function / overseer / floaterm,
  autoremove), `builder.lua` (`add_task` builder), sources `adhoc.lua`,
  `git.lua`, `make.lua`.
- History: 6e169f6 make-only `lua/genja/f2.lua`; split into the folder on
  2026-10-19 (`git mv` to `make.lua`).
- make targets come from `make -rRpq` (regex parsing missed includes);
  `LANG=C`; exit 1 from `-q` is not an error.
- git status: `--porcelain=v1 -z --untracked-files=all`; renames carry an
  extra NUL-separated original path.
- An entry's `remove` closure deletes by key; re-adding the same group+label
  before the run finishes means the new task gets removed.
- floaterm `--cwd` escapes spaces with `\ `; `cmd` tables are joined with
  `shellescape`.
- Tests: mini.test (`nvim-mini/mini.test`, spec `lua/lazyp/new/mini-test.lua`,
  installed only), `tests/minimal_init.lua`, `tests/f2/test_*.lua`:
  registry + builder, run (stubbed overseer/floaterm/feedkeys), sort, make
  and git parsing, adhoc (temp dirs, skips without `go`). Stateful ones run
  in a fresh child nvim per case. Private functions are exposed as
  `M._name` for this. Not covered: the telescope pickers, `M.open()`,
  gopls restart. From the config root:
  `nvim --headless --noplugin -u tests/minimal_init.lua -c "lua MiniTest.run()"`;
  or `make test` in `lua/genja/f2/` (`readme.testing.md` there)
- Related notes: `squash-ideas-oct-17.md` / `.details.md` #18,
  `readme.overseer.md`, `todo-ideas.md` #18.
