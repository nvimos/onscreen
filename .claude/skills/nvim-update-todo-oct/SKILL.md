---
name: update-todo-oct-nvim
description: Update the nvim config's backlog (Backlog.md tasks in the planning repo nvimos/meta) from the config commits made since the last scanned commit, then record the new last scanned commit. Use when the user types /update-todo-oct-nvim or asks to update the todo/ideas files from recent commits.
---

# update-todo-oct-nvim

Brings the backlog of the nvim config (`%LOCALAPPDATA%/nvim`) up to date with what the commits added, changed or improved. The backlog lives in github.com/nvimos/meta (checkout `~/es/nvimos-meta`, or `vim.g.genja_meta_dir`) since 2026-11-10. Edits only meta's files; commits nothing.

## Files (in meta)

- `backlog/tasks/task-<n> - <Title>.md`: one task per idea (Backlog.md); `backlog/archive/tasks/` for `Done` and `Dropped`.
- `openspec/changes/<id>/` and `index.tsv`: the same backlog in OpenSpec; keep both in step.
- `last-scanned-commit.md`: the config commit the last update stopped at.

## Steps

1. Read the hash in `last-scanned-commit.md`. No such file: the last one in `legacy/doc-wip/squash-ideas-oct-17.details.md` (`## Last scanned commit`); none there either: ask.
2. List the new commits in the config: `git log --reverse --format='=== %h %s%n%b' --stat <hash>..HEAD`. Read a commit's diff (`git show <hash>`) only when the message and stat don't say what the feature is.
3. Per commit, decide: new, updated or improved feature, or housekeeping (lock files, icon paths, CLAUDE.md, renames with no new behaviour). Skip housekeeping.
4. Match each feature to a task (`python tools/scan.py --details`, or grep the titles). Then update:
   - tick the done steps (`## Acceptance Criteria`, OpenSpec `## 1. Build`) and add a step with the short hash for new parts;
   - status: `In Progress` while steps are open, `Needs Test` when built but not tried by hand, `Done` (file to `backlog/archive/tasks/`) only when the user tried it;
   - a feature with no task gets a new one: next free TASK number, status `Needs Test`, the commit hash in its description; and its OpenSpec change and `index.tsv` row.
5. Keep it a summary: what the feature does and its keys or commands, with the commit hash. No user guide, no implementation decisions, no code.
6. Keep the user's uncommitted edits in meta as they are.
7. Write `git rev-parse HEAD` (full hash plus subject) to `last-scanned-commit.md`. Do this last, after the other edits.

## Output

- Per task: what was ticked or added and the new status, one line each.
- Commits skipped as housekeeping, by short hash.
- The new last scanned commit.
