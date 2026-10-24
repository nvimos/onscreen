---
name: update-todo-oct-nvim
description: Update the nvim config's todo-ideas.md and its squash-ideas files from the commits made since the last scanned commit, then record the new last scanned commit. Use when the user types /update-todo-oct-nvim or asks to update the todo/ideas files from recent commits.
---

# update-todo-oct-nvim

Brings the idea lists in the nvim config (`%LOCALAPPDATA%/nvim`) up to date with what the commits added, changed or improved. Edits only the files below; commits nothing.

## Files

- `todo-ideas.md`: the backlog. Its "related files" section names the others.
- `doc-wip/squash-ideas-oct-17.md`: summary table per idea, plus "Extras done along the way".
- `doc-wip/squash-ideas-oct-17.details.md`: per idea an "Outcome" list, plus "Extras done along the way" and the "Last scanned commit" section at the end.

## Steps

1. Read the hash under `## Last scanned commit` in the details file. No such section: ask which commit to start from.
2. List the new commits: `git log --reverse --format='=== %h %s%n%b' --stat <hash>..HEAD`. Read a commit's diff (`git show <hash>`) only when the message and stat don't say what the feature is.
3. Per commit, decide: new, updated or improved feature, or housekeeping (lock files, icon paths, CLAUDE.md, renames with no new behaviour). Skip housekeeping.
4. Match each feature to an idea number in the files (#1–#20 and later). Then update:
   - `todo-ideas.md`: tick `[x]` items that are done, add a sub-item with the short hash for new parts of an idea, `[~]` for tried but unconfirmed. A feature with no idea gets a new `[x]` entry near related ones.
   - squash table: change the "Done" column only when an idea's state changed.
   - squash "Extras": one line per feature not in the list.
   - details: a "Later (<hash>):" bullet under the idea's Outcome, or an entry in its "Extras done along the way".
5. Keep it a summary: what the feature does and its keys or commands, with the commit hash. No user guide, no implementation decisions, no code.
6. Keep jaro's uncommitted edits in these files as they are.
7. Set the hash under `## Last scanned commit` to `git rev-parse HEAD` (full hash plus subject). Do this last, after the other edits.

## Output

- Per file: which ideas or extras were added or changed, one line each.
- Commits skipped as housekeeping, by short hash.
- The new last scanned commit.
