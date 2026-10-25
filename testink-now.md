# Open tests (from todo-issue/)

## From this session

- Lint
    1. restart nvim
    2. open the buffer that gave the warning
    3. :messages names the linter
  - result
        lua/genja/lint.lua: linter gitleaks exited with code: 1
- Aerial
    1. with `<leader>oO`
    2. the float is barely see-through.
- Gitsigns
    1. in a tracked .md file, `<leader>mGs` shows signs
    2. press it again
    3. they're gone.
- F2
    1. in a markdown file
    2. the labels start in one column.
- Terminal cursor
    1. in :terminal insert mode, a steady orange bar
    2. :TermCursorShape block switches it.
- Terminal paste
    1. in pwsh, `<S-Insert>` with two lines
    2. pastes them without running each line.
- PwshFterm
    1. :PwshFterm opens a float
    2. exit closes it.
- Mason
    1. make mason-luals
    2. make mason.
- ToggleDiagnostics
    1. open a lua file with warnings
    2. :ToggleDiagnostics twice.

## From earlier sessions

- Diagnostics limit
    1. `<F2>` show all
    2. `<F2>` hide excess
    3. goes back to 3.
- Lint setup
    1. :MasonToolsInstall
    2. :ValeSync
    3. the guide's samples.
- Markdown fixes
    1. the  in a .md file
    2. :w fixes #Heading.
- Messages
    1. :luafile a failing file
    2. :Messages
    3. `<CR>`
    4. also :Messages -quick.
- Telescope footer
    1. `<leader>jM`
    2. `<F1>`
    3. `<C-F1>`.
- zenmode, in nvim-qt:
    1. in nvim-qt
    2. z1: zen opens and the diagnostics limit drops to 2. Use seven-errors.lua to see it.
      - result: yes
    3. z2: zen closes and reopens maximized.
    4. z1 again: reopens, not maximized.
    5. z0: the window size and the limit of 3 come back.
      - result: window size remained maxed

- comps011 tests
    1. make dir D=comps011 G=gather
    2. make timings.
- Claude window
    1. :ClaudeFterm as the only window
    2. /exit
    3. should leave no E444
    4. in a split, /exit closes it.
- Cmdline
    1. :e `<Tab>`
    2. `<C-j>`/`<C-k>`
    3. `<Up>` gives the previous command.
- Older items
  - F2 make targets
  - glow on a path with spaces or '
  - oil git add with `<M-a>`
  - search colors
  - g? in oil
  - `<leader>w`
  - / wsp / wsT
  - /close-issues with staged files
- Untested lists
  - doc-wip/untested.2026-10-23.md still has 31 unchecked items
  - untested.2026-10-24.md has 7
  - many overlap with the items above.

## Other open items

### Fixes and checks

- Lint: find which file makes the named linter fail.
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
- Zen
  - should z0 stay closed instead of reopening at width 80?
  - does setting &columns/&lines resize the nvim-qt window?
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
