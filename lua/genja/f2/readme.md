# f2: `<F2>` context picker

Sources, task fields and the add_tasks API: header of `init.lua`. Tests: `readme.testing.md`.

## Conventions

- Group names are at most 14 characters: `adhoc`, `this file (%)`, `diag`, `git`, `make`, `oil`, `claude`, `AI`, `gui`, `view`, `msgs`, `markdown`.
  `registry.lua` warns when an added task's group is longer.
- The main list right-aligns the group to 14 columns, then two spaces, then the label
  (`picker.display()`), so the labels start in one column:

  ```
             adhoc  go mod init foo
              diag  show all (2 hidden)
            claude  fix the tabline
          markdown  glow preview
     this file (%)  run with pwsh
  ```

- No `:` between group and label. Labels are shown lower case, without `« » ' " ! ` [ ]`
  (`picker.clean()`); the registry still matches on the label as written.
- The prompt filters on the line without the left padding.

## Implementation details (v2026)

Found while adding the PowerShell item (2026-11-09); read this to get up to speed.

### Layout

- `init.lua`: `M.open()` asks every source in the hardcoded `sources` list, merges the result with the registry, sorts, opens the picker.
  Also exports `add_task`, `add_tasks`, `remove_tasks`, `groups`, `group_order`.
- `registry.lua`: tasks added by callers; global or scoped to one buffer (dropped when it is wiped); same group + label replaces the earlier one.
- `builder.lua`: `f2.add_task(group, label):fn(...)|:cmd(...)|:keys(...):buffer(0):add()`.
- `run.lua`: runs a task; `cmd` goes to overseer unless `:floaterm()`; `run.overseer(name, cmd, cwd)` can be called directly.
- `picker.lua`: `display()` right-aligns the group, `clean()` strips `« » ' " ! ` [ ]` from labels.
- `groups.lua`: group names as symbols; see below.
- `collect/*.lua`: one source per file, each with `collect(ctx, done)`.

### Two ways to add items

- A source in `collect/`: asked on every `<F2>`, for items that depend on the project (make targets, composer/npm scripts, git status).
- `add_task(...):buffer(0):add()` from a filetype plugin: for items on the buffer's own file.
  `after/ftplugin/markdown.vim` (glow preview, checklist toggle) and `after/ftplugin/ps1.lua` (run with PowerShell) do this.
  An ftplugin runs on every FileType event; re-adding the same group + label just replaces the task.
- Overseer templates (`lua/overseer/template/user/`) do not show up in F2, only in overseer's own menu.

### Groups

- Use the symbols, not strings: `local f2 = require('genja.f2')`, then `f2.groups.this_file`.
- Collectors require `genja.f2.groups` directly: `genja.f2` loads the collectors, so requiring it from them is circular.
- `this_file` is `this file (%)`: actions on the current buffer's file, whatever the filetype; type `this file` in the prompt to list them.
  `adhoc` is for one-off fixes to the surrounding project (Go's `go mod init` lives there, since it fires from a directory or oil too).
- Go has no per-file item yet; markdown uses `markdown`; other filetypes add nothing.
- The width limit is 14, in `picker.GROUP_WIDTH`; the warning in `registry.lua` reads it from there.
  `tests/f2/test_picker.lua` checks the alignment and that a longer group is not cut.
- Groups missing from `M.group_order` (`markdown`, `lookup`, ...) sort after it, A-Z.

### PowerShell item

- `after/ftplugin/ps1.lua`: `this file (%)  run with PowerShell (pwsh)`, runs `pwsh -NoProfile -File <file>` in the file's folder as an overseer task.
- It uses `:fn()` rather than `:cmd()` so the path is read at pick time; a renamed buffer still runs the right file.
- It warns on a nameless buffer, a missing `pwsh` and unsaved changes (pwsh runs the file on disk).

### Open

- Not run or tested: the picker tests (`make` in this folder), the `<F2>` item itself.
- `groups.lua` has a todo: let callers add their own groups through an api function.
- Extracting F2 into its own plugin: the `f2 plugin` task in github.com/nvimos/meta.
