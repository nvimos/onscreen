---
name: commit-close-issues
description: Close issues solved in this session; commit each issue's changes in the config (one commit per issue), and write one Backlog.md task per issue into nvimos-meta saying briefly what was done, committed there. Use when the user types /close-issues or asks to close, or commit the issues or clean up after issues.
---

# close-issues

Commits each solved issue's changes in the config, then writes one Backlog.md task per issue into the planning repo named by `tracking` in the `.nvimos` file at the config root and commits the tasks there. The config gets no issue files.
Commit-planning logic is copied from `commit-plan`; unlike it, this skill commits, this skill considers all modified files and recently created files.

## 1. Collect the issues

- An issue is one problem or request from this session (or unstaged or modified changes) that ended in file changes: a bug fixed, a feature added, a doc changed.
- If the args name issues, use only those.

## 1b. Fix leftovers

- Before planning, look for loose ends in this session's own work (or work related to it) that the user is likely to want fixed, e.g. a command still named `ReloadLua2` after the twin was dropped, a header comment or doc line that no longer matches.
- Fix them now, so they land in the same commit as the issue, not a follow-up. Mention each in the issue's task as a `[x]` step.
- After committing, say one line per fix in the reply.
- Only when the user would plainly want it; anything unsure or unrelated is a suggestion, not a fix.

## 2. Plan the commits (commit-plan logic)

1. Read the state: `git status --short`, `git diff`, `git diff --cached`, and `git log --oneline -15` for the repo's message style. Read untracked files that may belong to an issue.
   - The config repo ignores `plug-wip/*/`; each plugin there is its own git repo. Run the same reads with `git -C plug-wip/<name>` for every plugin folder with changes (`git -C <dir> status --short` not empty).
2. Group the changes by issue, one commit per issue and repo. A file with hunks from two issues is split by hunk; note which hunks go where.
   - An issue across a plugin and the config is two commits: the plugin's in its folder first, then the config's.
   - The issue's task always goes in meta. Name the commits (`config <short hash>`, `<plugin> <short hash>`) in it.
   - Plugin commit messages follow that plugin's `git log` style.
3. "Not ours" changes are considered also.
4. Order the groups so each commit stands on its own (a rename before its users, docs after code).
5. Write a message per group:
   - Subject: imperative, no trailing period, about 50 chars, in the style of the recent log (`area: what changed`). 
   - Body only when the why isn't obvious from the subject; wrap at 72.
   - No Claude, Co-Authored-By or other attribution lines.
6. An issue whose changes were already committed earlier gets only its task in meta; name the earlier commit hashes in it.

## 3. Write the issue tasks (in nvimos-meta)

- One Backlog.md task per issue, numbered after the highest `TASK-<n>` in meta's `backlog/tasks/` and
  `backlog/archive/tasks/`; file `task-<n> - <Title-as-slug>.md`. Never overwrite a file.
- Status: `Needs Test` when a `test:` item is open (in `backlog/tasks/`), else `Done` (in `backlog/archive/tasks/`).
- Front matter as the other tasks (`id`, `title`, `status`, `assignee: []`, `created_date`, `labels`: the area and
  `issue` and the `project` from `.nvimos`, `dependencies: []`, `ordinal: <n>000`).

```markdown
## Description

<area>: <issue in one line>. Commits: config <hash>, <plugin> <hash>.

## Acceptance Criteria

- [x] #1 <what was done, one line, name the file or command>
- [x] #2 <...>

## Verify

- [ ] test: <what to try by hand to see it work>
```

- An open follow-up that is not a hand test is its own `To Do` task, or a step of an existing task.
- Short lines, no conversational text. LF newlines. Add a row to meta's `index.tsv`.
- Commit the tasks in meta after the config commits: `git -C <meta> add -- <task files> index.tsv`, message
  `issue: <topic>` (one commit for all of the session's tasks). Don't push meta.

## 4. Commit

1. Show the plan (format below), then commit without waiting, unless something is unclear: a hunk that fits two issues, or a file that may or may not be ours. Then ask first.
2. Set aside what is already staged:
   - this does not apply if the staged change is relevant to the issue. then it's included.
   - If `git diff --cached` is not empty, save it to a patch in the job tmp dir (`$CLAUDE_JOB_DIR/tmp`, else the system temp dir), then `git restore --staged -- <those paths>`.
3. For each group, in order (for a plugin group, every git command runs with `-C plug-wip/<name>` and paths are relative to it; set aside its staged changes as in step 2):
   - Whole files: `git add -- <paths>`.
   - Split files: write a patch with only this group's hunks to the tmp dir and `git apply --cached <patch>`.
   - Check `git diff --cached --stat` lists only this group, then `git commit -F <msgfile>` (message file in the tmp dir).
   - Never `git add -A`, `git add .`, `git commit -a`, `--amend`, `--no-verify`.
4. Re-stage the saved "not ours" patch with `git apply --cached <patch>`. If it fails, say so and give the patch path; don't retry with other flags.
5. Push, without asking, once all commits are done: every repo that got commits (config and `plug-wip/<name>`), once each, as the `git-push` skill does: `git -C <repo> push --no-progress --porcelain 2>&1; echo "exit $?"`.
   - Not in a Claude worktree (`.claude/worktrees/<name>`); its branch is merged later.
   - Rejected or no remote: report the line; don't pull, rebase or force.

## Output

The plan, for each group in commit order:

 
```
### <issue>
Repo: config | plug-wip/<name>
Files: path (all) | path (hunks: <short description>)
Task: meta TASK-<n> <title>

<subject>

<body, if any>
```

After committing, end with:

- the commits: `<repo> <short hash> <subject>`, one per line;
- the pushes: `<repo> <branch> <old>..<new>` or "up to date", one per repo;
- the meta tasks and the meta commit;
- the open `test:` items, if any.
