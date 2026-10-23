from: todo-ideas.md

- [x] 18. context-sensitive telescope dropdown on <F2> (closed 2026-10-23: all sub-items done, tests green)
    -make: list targets to execute
    -oil: git worktree: files to add with preview
    - sources (2026-10-19): lua/genja/f2/ (adhoc, git, make); items prefixed `group: `
    - notes and user guide: doc-wip/readme.idea18-f2-context.md
        - adhoc: `go mod init <dirname>` when no go.mod/go.work, then gopls restarts
        - [x] git source (oil only): `git: add (N files)` sub-picker with status codes, diff preview, <Tab> marks
        - [x] f2.add_tasks(tasks, { buffer? }) / f2.add_task(group, label):…:add() builder / f2.remove_tasks({ group, label?, buffer? }), f2.group_order
            - task: label, group, action (keys|function) or cmd (+ runner overseer|floaterm, cwd), order, cond, autoremove
            - [x] first caller: md-checklist (#34)
        - [x] git add picker: preview hidden at start, <C-p> toggles it, <M-t> tabs (picker stays), <M-e> edit; :F2Reload (6fdd7e3)
    - unit tests: tests/f2/ (mini.test), `make test` in lua/genja/f2/ (96c9375); ran 2026-10-23: 50 cases, 0 fails
    - manual checks still untested: doc-wip/untested.2026-10-23.md
