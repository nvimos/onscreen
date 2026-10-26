# F2 in oil: staged files, with their hunks in the preview

## What it does

`<F2>` in an oil buffer inside a git repo shows group `git`. Next to `add (N files)` (unstaged and
untracked files) there is now `staged (N files)`: every file with a staged change.

- Preview (`<C-p>`, hidden at start): `git diff --cached` for the file, i.e. what the next commit
  takes, hunk by hunk.
- `<CR>`: unstage the marked files, else the one under the cursor (`git restore --staged`); the
  worktree keeps the changes. The picker closes; oil's git column refreshes.
- `<Tab>` marks, `<M-t>` tabedit (stays), `<M-e>` edit, `<M-f>`/`<M-x>` refine, as in the add picker.
  No `<M-a>`.
- Hunks are not rows of their own; stage or unstage single hunks with gitsigns in the buffer
  (`<leader>h…`).

## Try it

1. In a repo: change two files, `git add` one of them (or `<M-a>` in the add picker).
2. Oil in the repo, `<F2>`: `git  staged (1 files)` and `git  add (…)`.
3. `staged`, `<C-p>`: the preview shows the staged diff.
4. `<CR>`: "unstaged 1 file(s)"; `<F2>` again: no `staged` entry; the file is back under `add`.

Test: `make test D=f2` (parsing only, `tests/f2/test_git.lua`).
