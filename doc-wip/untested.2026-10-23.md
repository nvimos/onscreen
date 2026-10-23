# Untested features, 2026-10-23

For a later guided session: one feature per question. Each line: feature,
key or command to try, file, guide.

## Session auto-todo-20261023-2048

- [ ] telescope keymaps: <leader>jM, <M-r>/<M-R> desc groups, <M-f>/<M-x>/<BS> (lua/genja/telescope-keymaps.lua) -> doc-wip/readme.2026-10-23.telescope-keymaps.md
- [ ] claude per project: :ClaudeFterm in two repos, <leader>pt / :ClaudeFterm! picker, <M-d> kill (lua/genja/claude.lua) -> doc-wip/readme.2026-10-23.claude-per-project.md
- [ ] linters: :MasonToolsInstall, then a .md / .yaml / workflow / playbook / Makefile with errors (lua/genja/lint.lua) -> doc-wip/readme.2026-10-23.lint-first-wave.md
- [ ] recent files: <C-F1> project first, <M-a> all, saved file ranks first (plug-wip/genja-recent.nvim, lua/genja/recent.lua) -> doc-wip/readme.2026-10-23.genja-recent.md
- [ ] right-click per filetype: markdown checkbox, oil git add, LSP entries, Morning (lua/genja/popup-menu.lua) -> doc-wip/readme.2026-10-23.mouse-morning.md
- [ ] statusline clicks: file -> oil, branch -> Neogit, E/W -> loclist (genja-statusline clicks) -> doc-wip/readme.2026-10-23.mouse-morning.md
- [ ] :Morning: click a start dir, a recent file, a todo line; R, q (lua/genja/morning.lua) -> doc-wip/readme.2026-10-23.mouse-morning.md
- [ ] ask popup: <M-?>, <C-CR>, y, <CR> follow-up, <M-t>/<M-m>/<M-e>/<M-s>/<M-r>, visual selection (lua/genja/ask.lua) -> doc-wip/readme.2026-10-23.ask-popup.md
- [ ] mini.starter: enabled = true, start nvim without files (lua/lazyp/ui/mini-starter.lua) -> doc-wip/readme.2026-10-23.mouse-morning.md

## Session auto-todo-20261023-1924

- [ ] fold markers with a title: visual `zf`, `<leader>wwf`, `:WrapFold` (lua/genja/wrapfold.lua) -> doc-wip/readme.2026-10-23.wrapfold.md
- [ ] right-click Actions (g.), click/double-click in telescope, new actions source/claude (lua/genja/fn.vim, actions.lua) -> doc-wip/readme.2026-10-23.popup-actions.md
- [ ] ~ swaps true/false, +/-, </> …; <M-~> plain (lua/genja/tilde.lua) -> doc-wip/readme.2026-10-23.tilde-dial.md
- [ ] dial.nvim <C-a>/<C-x>, g<C-a> per filetype groups (lua/lazyp/new/dial.lua) -> doc-wip/readme.2026-10-23.tilde-dial.md
- [ ] F2 markdown checklist: visual <F2> > markdown task (lua/genja/md-checklist.lua) -> doc-wip/readme.2026-10-23.md-checklist.md
- [ ] telescope <M-x> exclude, <BS> undo (genja-finder refine.lua) -> doc-wip/readme.2026-10-23.refine-exclude.md, plugin README
- [ ] window sizes: <M-=> <M--> <M-0>, <leader>wr resize mode (lua/genja/winsize.lua) -> doc-wip/readme.2026-10-23.winsize.md
- [ ] smart-splits.nvim: enable the spec to compare (lua/lazyp/new/smart-splits.lua) -> doc-wip/readme.2026-10-23.winsize.md
- [ ] resize keeps the tab: resize nvim-qt by any edge on tab 1 of 3, tab stays (real cause: VimResized tabdo, lua/genja/auto-alias.vim, PR-fix-32-resize-tab) -> todo-done/ideas-32-resize-last-tab.md
- [ ] tabline: clicks outside the labels do nothing (genja-statusline tabline.lua) -> doc-wip/readme.2026-10-23.tabline-click.md
- [ ] start dirs: <leader>sp/sa/sr/se, <M-1>..<M-4>, oil ,s ,S, ranked mydirs (plug-wip/genja-startdirs.nvim) -> doc-wip/readme.2026-10-23.startdirs.md

## Earlier, still untested

- [ ] voice typing: Win+H in insert mode, in nvim-qt and in a terminal (#20) -> todo-ideas.md #20
- [ ] gitsigns keys: <leader>h… stage/reset/preview, ]c [c, ih (lua/genja/map-plugin/gitsigns.lua) -> readme.cheatsheet.md Git
- [ ] Neogit / diffview / mini.git keys: <leader>mg, <leader>mGl, <leader>mGc, <leader>md/mh/mH, <leader>hc (#37) -> readme.cheatsheet.md Git
- [ ] genja-commit: commit popup, lint while typing, <M-g> message, Conventional Commits mode (#14) -> plug-wip/genja-commit.nvim/README.md
- [ ] <C-F1> oldfiles with refine keys <M-f> <M-n> <BS> (lua/genja/map-telescope.lua) -> plug-wip/genja-finder.nvim/README.md
- [ ] genja-finder scope: from:arg root in oil, prompt title last three parts, unix path labels (#8) -> doc-wip/squash-ideas-oct-17.details.done.md #8
- [ ] F2 git add picker: <C-p> preview, <M-t> tabs, <M-e> edit, :F2Reload (#18) -> lua/genja/f2/readme.testing-manual.md
- [ ] F2 adhoc: go mod init for a .go file without go.mod (#18) -> doc-wip/readme.idea18-f2-context.md
- [ ] claude floaterm: :ClaudeFterm [flags], <leader>pc paste, <leader>pC popup, session marker via /rename (#19) -> doc-wip/squash-ideas-oct-17.details.md #19
- [ ] claude terminal: hourglass cursor while claude starts (4e79669) (#19a) -> todo-ideas.md
- [ ] codecompanion: <leader>ac / <leader>aa (#19a) -> doc-wip/readme.idea19-companion.md
- [ ] focus.nvim: off by default; excluded buftypes when on (lua/lazyp/ui/focus.lua) -> doc-wip/squash-ideas-oct-17.done.md extras

## Run by Claude (fast checks only)

- f2 unit tests: `make test` in lua/genja/f2/: 50 cases, 0 fails (2026-10-23).
- Headless smoke checks per item above; noted in each guide.
