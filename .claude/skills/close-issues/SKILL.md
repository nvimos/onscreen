---
name: close-issues
description: Close issues solved in this session; write one todo-issue/….md per issue as a markdown checklist saying briefly what was done, then commit the issue file with the relevant changes; one commit per issue. Use when the user types /close-issues or asks to close, or commit the issues or clean up after issues.
---

# close-issues

Writes one issue file per solved issue into `todo-issue/` (repo root, git toplevel; create the folder if missing), then commits each issue's changes with its file.
Commit-planning logic is copied from `commit-plan`; unlike it, this skill commits, this skill considers all modified files and recently created files.

## 1. Collect the issues

- An issue is one problem or request from this session (or unstaged or modified changes) that ended in file changes: a bug fixed, a feature added, a doc changed.
- If the args name issues, use only those.

## 2. Plan the commits (commit-plan logic)

1. Read the state: `git status --short`, `git diff`, `git diff --cached`, and `git log --oneline -15` for the repo's message style. Read untracked files that may belong to an issue.
2. Group the changes by issue, one commit per issue. A file with hunks from two issues is split by hunk; note which hunks go where.
3. "Not ours" changes are considered also.
4. Order the groups so each commit stands on its own (a rename before its users, docs after code).
5. Write a message per group:
   - Subject: imperative, no trailing period, about 50 chars, in the style of the recent log (`area: what changed`). 
   - Body only when the why isn't obvious from the subject; wrap at 72.
   - No Claude, Co-Authored-By or other attribution lines.
6. An issue whose changes were already committed earlier gets only its issue file, committed alone as `issue: <topic>`; name the earlier commit hashes in the file.

## 3. Write the issue files

- Name: `todo-issue/solved-<yy.mm.dd>-<HH.MM>-<topic>.md`
    - `<yy.mm.dd>-<HH.MM>` is a timestamp.
    - `<topic>`: one to three lowercase words joined by `-`, e.g. `winbar-names`.
    - Never overwrite an existing file.
- Content: one top-level checklist item, sub-items say briefly what was done, like `todo-ideas.md`:

```markdown
- [x] <area>: <issue in one line> (<yyyy-mm-dd>)
    - [x] <what was done, one line, name the file or command>
    - [x] <...>
    - [ ] test: <what to try by hand to see it work>
    - [ ] <open follow-up, if any>
```

- `[x]` for done work, `[ ]` for open items. Add a `test:` item for each feature that wasn't run or tested in the session.
- Short lines, no conversational text. Four-space indent as in `todo-ideas.md`. LF newlines.

## 4. Commit

1. Show the plan (format below), then commit without waiting, unless something is unclear: a hunk that fits two issues, or a file that may or may not be ours. Then ask first.
2. Set aside what is already staged:
   - this does not apply if the staged change is relevant to the issue. then it's included.
   - If `git diff --cached` is not empty, save it to a patch in the job tmp dir (`$CLAUDE_JOB_DIR/tmp`, else the system temp dir), then `git restore --staged -- <those paths>`.
3. For each group, in order:
   - Whole files: `git add -- <paths> todo-issue/….md`.
   - Split files: write a patch with only this group's hunks to the tmp dir and `git apply --cached <patch>`.
   - Check `git diff --cached --stat` lists only this group, then `git commit -F <msgfile>` (message file in the tmp dir).
   - Never `git add -A`, `git add .`, `git commit -a`, `--amend`, `--no-verify`.
4. Re-stage the saved "not ours" patch with `git apply --cached <patch>`. If it fails, say so and give the patch path; don't retry with other flags.
5. Don't push.

## Output

The plan, for each group in commit order:

 
```
### <issue>
Files: path (all) | path (hunks: <short description>) | todo-issue/….md

<subject>

<body, if any>
```

After committing, end with:

- the commits: `<short hash> <subject>`, one per line;
- the issue files;
- the open `test:` items, if any.
