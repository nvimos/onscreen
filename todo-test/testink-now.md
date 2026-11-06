# Open tests (from todo-issue/)

Passed ones: todo-done/tested-2026-10-29.md, todo-done/tested-2026-10-31.md.

## Session 2026-10-31 (one feature per question)

1. Terminal paste
2. Markdown links
3. Colours (ccc)
4. Paste search on a selection
5. Terminal keys
6. Sessions keep idle shells
7. md-fix on save
8. Markdown list wrap
9. Diagnostics (diag-align, colours)
10. Telescope key help
11. netrw.nvim icons (doc-wip/readme.2026-10-31.netrw-nvim.md)
12. Lint setup, first run (needs :MasonToolsInstall, :ValeSync)
13. Ghost text: minuet, llm.nvim (needs ollama serve; doc-wip/readme.2026-10-31.ghost-text-minuet-llm.md)
    - 2026-11-05: llm.nvim already failed, parked in lua/lazyp/unused-failed/llm.lua; minuet <M-y> auto-tested
      (tests/llm). Left: minuet ghost text by hand (model now qwen2.5-coder:0.5b), compare with copilot.
    - result 2026-11-05: ghost text appears, <M-A> takes it, <M-e> drops it. But the provider is Codestral
      (minuet.lua, since 2026-10-31), not ollama: `ollama ps` empty. The guide's ollama setup is out of date.
    - result 2026-11-05, ollama: `:Minuet change_provider openai_fim_compatible`, ghost text appears
      (qwen2.5-coder:0.5b). First request failed: model load ran past request_timeout 6 s; then 0.9 s.
      Noted in README.md "Ghost text provider". Copilot comparison not done.


## Follow up

- Lint: gitleaks fails
  - result 2026-10-29: `lua/genja/lint.lua: linter gitleaks exited with code: 1`
  - nvim-lint already passes `--exit-code=0`, so 1 is a gitleaks error, not a leak found.
      Hint: run the linter's command by hand on that buffer
      (`gitleaks stdin --report-format=json --report-path=- --exit-code=0 <file>` with the file on stdin).
  - merged: "Lint: find which file makes the named linter fail".
  - auto 2026-10-30: `lint gitleaks` passes on the sample secret.txt; the file that failed is still unknown
  - 2026-10-31: cause found. gitleaks itself exits 0 (8.30.1, also with leaks). Linting a buffer again
    cancels the run still going; nvim-lint kills it and the killed cmd.exe exits 1. At startup the
    first buffer is linted twice (BufReadPost and setup()), and gitleaks is the slowest linter.
    lua/genja/ext/lint.lua no longer reports cancelled runs. Headless: 5 double lints, 10 warnings
    before, 0 after. Test: `make test D=comps011 G=relint` in tests/ passes (2026-10-31).
    1. open ws/foo.sh: no exit-code warning
    - result: 2026-10-31 opens properly, no warning
- Zen in nvim-qt: z0 doesn't restore the window size
    1. z1: zen opens, diagnostics limit drops to 2 (seven-errors.lua)
       - result: yes
    2. z2: zen closes and reopens maximized.
    3. z1 again: reopens, not maximized.
    4. z0: the window size and the limit of 3 come back.
       - result: window size remained maxed
  - merged decisions: should z0 stay closed instead of reopening at width 80?
      does setting &columns/&lines resize the nvim-qt window?
  - result 2026-10-31: steps 2 and 3 pass; step 4 still fails: the window stays maximized-sized.
  - guess (not checked): after z2 the window keeps its large size once unmaximized, and z0's
      &columns/&lines may be ignored by nvim-qt (lua/genja/map-plugin/zenmode.lua zen_off).
  - open questions, zen off, normal-sized window:
    1. `:set columns=80 lines=25`: does the window shrink?
       - result 2026-11-05: no. nvim-qt ignores &columns/&lines, so zen_off's restore of them does nothing.
    2. `:call GuiWindowMaximized(1)`, then `:call GuiWindowMaximized(0)`: back to the earlier size?
       - result 2026-11-05: yes, back to the previous size (without frameless).
    3. same with `:call GuiWindowFrameless(1)` first: back to the earlier size? (z1/z2 are frameless)
       - result 2026-11-05: yes, frameless doesn't matter.
    4. `<leader>z2`, then `<leader>z0` (no z1 between): back to the earlier size?
       - result 2026-11-05: no. gui-func-state set() always calls GuiWindowMaximized(0), so not a cache.
         Guess: zen calls Frameless and Maximized back to back; the frameless change recreates the
         Qt window and the restore size gets lost.
    5. both on one line: `:call GuiWindowFrameless(1) | call GuiWindowMaximized(1)`, then
       `:call GuiWindowFrameless(0) | call GuiWindowMaximized(0)`: back to the earlier size?
       - result 2026-11-05: no, stays maximized. Cause found: back-to-back frameless + maximize.
  - fix 2026-11-05 (lua/genja/map-plugin/zenmode.lua): the maximize call waits GUI_SETTLE_MS (150)
    after frameless on (z1, z2); z0 un-maximizes first, frameless off 150 ms later. Not tested.
    Retest: z2, z0: earlier size back; z1, z2, z1, z0: same.
  - result 2026-11-05: z2, z0 passes, window back to its previous size. (z1, z2, z1, z0 not run)
  - result 2026-11-06: z1, z2, z1, z0 passes, window back to its earlier size. Zen restore done.
    2. `:call GuiWindowMaximized(1)`, then `:call GuiWindowMaximized(0)`: back to the earlier size,
       or still full-screen-sized?
- Claude window: /exit brings forward some old buffer
    1. :ClaudeFterm as the only window, /exit: no E444 (works)
    2. in a split, /exit closes it (works)
  - follow-up: the window left behind shows an old buffer, not the one before claude.
  - result 2026-10-31: /exit leaves the window on the file that was open before claude: passes

## Not tested yet

- Terminal paste
    1. in pwsh, `<S-Insert>` with two lines
    2. pastes them without running each line.
  - result 2026-10-31: nvim_paste's bracketed paste ran each line in pwsh. Fixed: pwsh/powershell
    terminals get <C-v> (PSReadLine's paste), others nvim_paste (lua/genja/map-zero.lua). Passes in pwsh and bash.
- Lint setup (doc-wip/readme.2026-10-24.lint-vale-gitleaks.md, first run)
    1. :MasonToolsInstall
    2. :ValeSync
    3. open the guide's sample files, each shows its linter's warnings.
  - result 2026-10-31: vale (write-good, Microsoft) after :ValeSync, nothing before; gitleaks github-pat on a ghp_ token
    (the guide's AWS sample doesn't match gitleaks' rule; guide fixed). Other linters of the first waves not checked.
  - same as the open lint items in doc-wip/untested.2026-10-23.md and untested.2026-10-24.md.
- Telescope key help (lua/genja/ext/telescope-virthelp.lua)
  - the "footer" prototype was dropped 2026-10-25; its successor shows
      `key | m | description` in the empty results area.
    1. `<leader>jM`, `<F1>`, `<C-F1>`: each picker opens with the key help
    2. typing a query replaces it with results.
  - result 2026-10-31: passes (all three pickers)
- Markdown links (lua/genja/hilite.vim)
    1. open a markdown file with links: the underline is faint grey
    2. `:Inspect` on a link names `@markup.link` / `@markup.link.url`; the label keeps its colour.
  - result 2026-10-31: passes (faint underline, colours good)

- Colours (ccc.nvim, lua/lazyp/new/ccc.lua)
    1. `<leader>ic` on a hex colour: picker edits it; elsewhere it inserts one
    2. `<leader>tc` in a markdown file paints colours; again turns it off.
  - result 2026-10-31: passes (picker edits, toggle off and on)

- Paste search on a selection (lua/genja/ext/popup-menu.lua, plug-wip/genja-paste-ai.nvim)
    1. select text, right-click, "Lookup: paste search selection"
    2. the browser opens the search; the entry isn't in the normal-mode menu.
  - result 2026-10-31: passes; also "Lookup: paste search with provider" (visual only): picker, then search

- Terminal keys (lua/genja/map-zero.lua, lua/genja/ext/term.lua)
    1. `<C-`>` opens the generic floaterm, again hides it
    2. `<M-`>` in a terminal goes to the previous window, else the next tab, else a new tab
    3. entering a terminal window starts terminal mode.
  - result 2026-10-31: passes

- Sessions keep idle shells (`save:` / `s:`, lua/genja/abbreviations.vim)
    1. open an idle shell terminal and a running claude, `save:`
    2. `:source ~/tmp/viss`: the shell comes back in its dir, the claude window doesn't.
  - result 2026-10-31: shell wasn't saved: `:terminal pwsh` runs through 'shell', so the job is the
    wrapper and pwsh its child; every shell looked busy. Fixed (shell_pid in lua/genja/ext/term.lua).
    Retest: shell comes back in its start dir, claude not saved. `:terminal ssh a22` not saved (not a shell).

- md-fix on save (lua/genja/ext/md-fix.lua)
  - auto: md/keys cases pass (backticks); tabs and <leader>tm are only by hand
    1. `:w` on a file with tab-indented lists and `<C-x>` in prose: tabs become spaces, the key gets backticks
    2. `<leader>tm` turns it off, `:w` leaves the file alone.
  - result 2026-10-31: passes

- Markdown list wrap (after/ftplugin/markdown.vim formatlistpat)
    1. `gq` on a long `- [ ] item` line: wrapped lines start after the checkbox.
  - result 2026-10-31: wrapped under the checkbox: the runtime's 'comments' fb:- made `- ` a leader, so gq
    matched formatlistpat after it. Fixed: comments-=fb:* fb:- fb:+ (after/ftplugin/markdown.vim); headless
    gq: `- [ ]` and `1. [x]` items line up under their text. Retest by hand: passes, `> ` quotes repeat.

- Diagnostics
    1. `make test D=ui` in tests/
       - result 2026-10-31: passes (auto run 2026-10-30), but it covers the limit, not diag-align
    2. a paragraph with several diagnostics shows them in one column (lua/genja/ext/diag-align.lua)
    3. `:let g:diag_align = v:false`, refresh: back to line end
    4. errors, warnings and hints read well with the new colours (lua/genja/hilite.vim).
  - result 2026-10-31: 2 one column, 3 colours fine. Added <leader>tta and an <F2> diag item to switch it
    (M.toggle in lua/genja/ext/diag-align.lua); auto: tests/ui/test_diag_align.lua (`make test D=ui`) passes.
    <leader>tta and the <F2> item are auto-tested too (key typed, marks move both ways).
- md-fix and editorconfig (2026-10-31): auto only, tests/md/test_md_fix.lua (`make test D=md`):
  [*.md] sections decide tabs/spaces, [*] doesn't; a real :w with indent_style = tab gives tabs.


## Auto tests to write

- From "Older items" (passed by hand 2026-10-29):
  - glow command for a path with spaces or `'` (quoting only)
  - oil `<M-a>` git add: index has the file after the key
  - `<leader>w` / wsp / wsT window commands: window count and layout
  - g? in oil: help float opens

- From doc-wip/untested.2026-10-23.md, pure-logic items first:
  - tilde.lua: `~` swaps true/false, +/-, </>
  - md-checklist: visual `<F2>` makes a task list
  - wrapfold: `:WrapFold` puts fold markers with a title
  - genja-startdirs add/remove (text file round trip)

- Not worth automating: voice typing, nvim-qt resize, mouse clicks, colours.

## Other open items

### Fixes and checks

- Ask-popup guide: paths fixed 2026-11-05 (plug-wip/genja-ask.nvim).

- close-issues skill
  - use `git commit -- <paths>` when no file is split by hunk
  - background sessions can't write the issue files in the main checkout
    - just commit them
    - also or specifically in the main checkout

### Decisions

- Markdown: filetype settings (linebreak, spell, list continuation).

- #48
  - hollow box cursor
  - the blink that the program in the terminal sets

### Later or upstream

- nvim-lint
  - report the exit-code message and the checkmake quoting upstream.

- glow on Linux: pick a terminal.
