# genja-recent: recent files by frecency (#35)

What: your own recent-files list. Every file you show counts as a view and
every `:w` as an edit; the list is sorted by frecency (edits x2, recent use
weighs more). `<C-F1>` shows the current project's files first.

Files: `plug-wip/genja-recent.nvim/` (recording, data file, score), spec
`lua/lazyp/new/genja-recent.lua` (VeryLazy), picker `lua/genja/ext/recent.lua`,
key in `lua/genja/map-telescope.lua`.

## Keys

| Key | Does |
|-----|------|
| `<C-F1>` | recent files of this project (git root of the buffer, else `:pwd`) |
| `<M-a>` (picker) | switch between this project and all files |
| `<M-f>` `<M-x>` `<M-n>` `<BS>` (picker) | genja-finder refine keys |
| `<leader>jo` | telescope oldfiles (unchanged) |

## Rules

- Recorded: real files (`buftype == ''`). Not recorded: oil, help, terminals,
  anything under `.git/` (COMMIT_EDITMSG), the temp dir, `nvim-data`.
- Data: `nvim-data/genja-recent.txt`, one line per file
  (`path<TAB>views<TAB>edits<TAB>last`). Written on quit and every 5 minutes.
- Two nvims at once: each adds its own uses to the file, counts aren't lost.
- A project with no recent files yet: the picker says so and shows all.

## Try it

1. Restart nvim (the list starts empty; oldfiles isn't imported).
2. Open three files in this repo, `:w` one of them.
3. `<C-F1>`: the saved one is on top; title `Recent: nvim  <M-a> all`.
4. `<M-a>`: all files; `<M-a>` again: back to the project.
5. Open a file in another repo, `<C-F1>`: only that repo's files.
6. `:qa`, check `nvim-data/genja-recent.txt` has the lines.
7. `<leader>mGc` commit popup: COMMIT_EDITMSG must not show up in `<C-F1>`.

Checked by Claude: headless test of record / list / flush with a temp data
file: `.git/COMMIT_EDITMSG` skipped, the written file ranked first, the
project filter kept 2 of 3, a flush merged with a file another session wrote,
recency weights 4/2/0.5/0.25. The picker itself was not opened.

Not done: genja-startdirs still ranks by plain use counts; using
`genja-recent.frecency` there needs a last-used time in `startdirs.usage`.
