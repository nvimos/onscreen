# Mouse: right-click per filetype, clickable statusline, :Morning (#30/31)

What: more to click for lazy mornings and planning sessions.

Files:
- `lua/genja/ext/popup-menu.lua` (+ `plugin/popup-menu.lua`): right-click entries
  rebuilt on every `MenuPopup` for the buffer under the click.
- genja-statusline `clicks` option (`plug-wip/genja-statusline.nvim`), handlers
  in `lua/lazyp/new/genja-statusline.lua`; the statusline now shows the git
  branch (gitsigns) and `E2 W1` counts.
- `lua/genja/ext/morning.lua` (+ `plugin/morning.lua`): `:Morning`.
- `lua/lazyp/ui/mini-starter.lua`: mini.starter with the same sections,
  `enabled = false`.

## Right-click menu (added at the bottom)

| Buffer | Entries |
|--------|---------|
| markdown | toggle checkbox (`- [ ]` <-> `- [x]`, plain item gets `[ ]`), open link (`gx`), F2 menu |
| oil | git add (entry under the cursor), open in tab |
| any buffer with an LSP client | code action, rename, references |
| everywhere | Morning |

`ToggleWrap` and `Actions (g.)` stay as before (`lua/genja/fn.vim`).

## Statusline clicks (left button)

| Part | Click |
|------|-------|
| file name | oil at the file's dir |
| ` main` branch | `:Neogit` |
| `E2 W1` | the buffer's diagnostics in the location list |

## :Morning

Sections: Start dirs (most used first), Recent (genja-recent, else
oldfiles; 12), Todo (top-level items of `todo-ideas.md`), Untested (open
lines of the newest `doc-wip/untested.*.md`). A click or `<CR>` opens: a dir
is `:cd` + oil, a todo/untested line opens the file at that line. `q` closes,
`R` rebuilds.

## Try it

1. Right-click in a markdown file on `- [ ] x`: "Markdown: toggle checkbox".
2. Right-click in oil on a changed file: "Oil: git add", then check
   `git status`.
3. Right-click in a Lua file (lua_ls attached): the LSP entries.
4. Click the file name in the statusline: oil opens. Click the branch:
   Neogit. Make an error, click `E1`: location list.
5. `:Morning`, click a start dir, a recent file, a todo line.
6. Right-click anywhere: "Morning".
7. mini.starter: set `enabled = true` in `lua/lazyp/ui/mini-starter.lua`,
   start `nvim` with no file: the start screen.

Checked by Claude: headless tests: markdown entries show and leave again on
another filetype, the checkbox toggle works both ways, `:Morning` builds its
four sections (44 lines), statusline: the branch is a click region that
calls its handler with `l`, E1 shows, no handler = no region. Not tried in a
real UI: the menu (nvim's own MenuPopup handler can't run headless), the
clicks, oil git add, mini.starter.
