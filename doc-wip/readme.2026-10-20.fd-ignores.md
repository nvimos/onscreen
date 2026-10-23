# fd does not find CLAUDE.md

`fd CLAUDE.md .` and `fd CLAUDE.md . -H` print nothing; `fd CLAUDE.md . -HI` finds all five.

## Cause

`.git/info/exclude` line 7 has the pattern `CLAUDE.md`.

- fd follows git's ignore rules by default: `.gitignore`, the global excludes file, and `.git/info/exclude`. That last file is per-repo, local and not committed, so it doesn't show up in `.gitignore`.
- A pattern with no slash matches at any depth, so it hides every CLAUDE.md in the tree.
- `-H` only shows hidden (dot) files, so it changed nothing. `-I` (`--no-ignore`) turns off all ignore files.
- None of the CLAUDE.md files are tracked by git (`git ls-files` returns nothing for them), so the exclude rule is working as written.

## Commands

```sh
fd CLAUDE.md --no-ignore-vcs        # skips git ignore rules, still uses .ignore/.fdignore
git check-ignore -v <path>          # shows which file and line ignores a path
```

## Fix

To make fd always find them, delete line 7 from `.git/info/exclude`. They would then show up as untracked in `git status`.
