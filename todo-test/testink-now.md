# Open tests (from todo-issue/)

Passed ones: todo-done/tested-2026-10-29.md.

## Follow up

- Lint: gitleaks fails
    - result 2026-10-29: `lua/genja/lint.lua: linter gitleaks exited with code: 1`
    - nvim-lint already passes `--exit-code=0`, so 1 is a gitleaks error, not a leak found.
      Hint: run the linter's command by hand on that buffer
      (`gitleaks stdin --report-format=json --report-path=- --exit-code=0 <file>` with the file on stdin).
    - merged: "Lint: find which file makes the named linter fail".
- Zen in nvim-qt: z0 doesn't restore the window size
    1. z1: zen opens, diagnostics limit drops to 2 (seven-errors.lua)
       - result: yes
    2. z2: zen closes and reopens maximized.
    3. z1 again: reopens, not maximized.
    4. z0: the window size and the limit of 3 come back.
       - result: window size remained maxed
    - merged decisions: should z0 stay closed instead of reopening at width 80?
      does setting &columns/&lines resize the nvim-qt window?
    - steps 2-3 have no result yet.
- Claude window: /exit brings forward some old buffer
    1. :ClaudeFterm as the only window, /exit: no E444 (works)
    2. in a split, /exit closes it (works)
    - follow-up: the window left behind shows an old buffer, not the one before claude.

## Not tested yet

- Terminal paste
    1. in pwsh, `<S-Insert>` with two lines
    2. pastes them without running each line.
- Lint setup (doc-wip/readme.2026-10-24.lint-vale-gitleaks.md, first run)
    1. :MasonToolsInstall
    2. :ValeSync
    3. open the guide's sample files, each shows its linter's warnings.
    - same as the open lint items in doc-wip/untested.2026-10-23.md and untested.2026-10-24.md.
- Telescope key help (lua/genja/ext/telescope-virthelp.lua)
    - the "footer" prototype was dropped 2026-10-25; its successor shows
      `key | m | description` in the empty results area.
    1. `<leader>jM`, `<F1>`, `<C-F1>`: each picker opens with the key help
    2. typing a query replaces it with results.

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

- comps011
  - reinstall lua-language-server (half-installed)
    and autotools-language-server
  - bashls and gopls attach without diagnostics,
    so check that go is on PATH.
- claudefterm tests
  - several FloatermKills in a row sometimes crash the headless test nvim.
- Ask-popup guide
  - readme.2026-10-23.ask-popup.md still points to lua/genja/ask.lua,
    which moved to plug-wip/genja-ask.nvim.
- Typos
  - a " Diagnosticz comment (hint: ignore this one)
  - Stardirs → Startdirs
- Skill paths
  - CLAUDE.md still names .claude/skills/close-issues/
  - nvim-auto-todo step 8 writes to ~/.claude/skills/auto-todo/runs.md
    - merge file from old locattion
    - update instructions
- close-issues skill
  - use `git commit -- <paths>` when no file is split by hunk
  - background sessions can't write the issue files in the main checkout
    - just commit them
    - also or specifically in the main checkout

### Decisions

- Telescope: answer the 6 spec questions.
- Markdown: filetype settings (linebreak, spell, list continuation).
- #39
  - session marker enabled:false toggle
  - !! markers in txt files
- #48
  - hollow box cursor
  - the blink that the program in the terminal sets

### Later or upstream

- nvim-lint
  - report the exit-code message and the checkmake quoting upstream.
- vint: revisit on Linux/WSL or a fork.
- glow on Linux: pick a terminal.
