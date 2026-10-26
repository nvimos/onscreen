# Claude floaterm per project (#19)

What: one claude floaterm per project root instead of one global `claude`
terminal, plus a picker of the running ones.

Files: `lua/genja/claude.lua` (target, terminal and picker), command in
`lua/genja/auto-alias.vim`, keys in `plugin/claude-fterm.lua`.

## Which project

The current buffer decides, first match wins:

1. a claude terminal itself: that terminal
2. a session marker in the file: the session's cwd (resumes it)
3. the git root of the file's dir (oil: the shown dir)
4. `:pwd`

Terminal name: `claude-<root basename>` (e.g. `claude-nvim`). Two roots with
the same basename: the second gets a short hash (`claude-nvim-1a2b3c`).
Claude now starts in the root (floaterm `--cwd`), not in `:pwd`.
The buffer name stays `claude-ft «title»`.

## Keys and commands

| Key / command | Does |
|---------------|------|
| `:ClaudeFterm [flags]`, `<leader>mc` | toggle this project's claude (start it in the root) |
| `:ClaudeFterm!`, `<leader>pt` | dropdown of running claude terminals |
| in the dropdown: `<CR>` | show that terminal and jump in |
| in the dropdown: `<M-d>` | kill it; the list reopens |
| `<leader>pc`, `<leader>pC` | paste / prompt into this project's claude; paths relative to its root |

`<leader>pl` from the spec was taken (Perplexity: line), so the picker is on
`<leader>pt`.

## Try it

1. Open a file in this nvim repo, `:ClaudeFterm`: a terminal opens; `:ls!`
   shows `claude-ft «nvim»`; `:FloatermList` shows `claude-nvim`.
2. `<C-q>` back, open a file in another git repo (e.g. a plug-wip fork with
   its own `.git`, or `~/source/...`), `:ClaudeFterm`: a second claude starts
   in that repo.
3. `<leader>pt`: both are listed; pick the first, `<CR>`: it shows.
4. In the dropdown, `<M-d>` on one: it's killed, the list reopens with one.
5. `<leader>pc` in a file of repo A while B's claude is shown: the paste goes
   to A's claude (it starts if needed), path relative to A's root.
6. Session marker: `/rename` in a claude, the marker lands in its origin
   file; `:ClaudeFterm` from that file shows (or resumes) that session.
7. `:s:` / quitting: all claude terminals are killed.

Checked by Claude: headless `loadfile`, `require('genja.claude')`, the
`:ClaudeFterm` command defines with `-bang`. No claude was started.

Limits: `:DevReloadClaude` forgets the running terminals (they keep running,
but the picker no longer lists them).

Unit tests (2026-10-24): `make test D=claudefterm` in `tests/`, `tests/claudefterm/test_per_project.lua`
(15 cases): real vim-floaterm, claude replaced by `fake_claude.cmd` / `.sh`, which logs its cwd and
args to `$FAKE_LOG`; pastes recorded by stubbing `nvim_chan_send`. Covers steps 1-7: two repos, same
basename (hash), no repo, toggle hide/show, `:ClaudeFterm` inside the terminal, `show()`, paste to the
right project (normal and visual), `send()`, picker `<CR>` / `<M-d>`, `kill()`, session marker resume
and `/rename` marker. "Paste starts claude, pastes once it is up" skips on Windows: in headless nvim
the terminal's output goes to the outer console, so claude never looks ready.
Keys moved since: `<leader>mC` lists the terminals (was `<leader>pt`), `<leader>pc` ask popup,
`<leader>pC` paste; files now in `plug-wip/genja-claudefterm.nvim`.
