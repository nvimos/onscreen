# list of improvements to nvim

## related files

    ./doc-wip/squash-ideas-oct-17.md
    ./doc-wip/squash-ideas-oct-17.details.md


## ideas october

- [~] 19. claude: from nvim (wip)
    - [x] prettier winbar names: `claude-ft «<session title>»`, else the cwd basename (bfd6eef)
    - [x] :ClaudeFterm [flags]: --chrome, --model, --effort, ... at start, <Tab> completes (55240fa)
    - [x] terminal keys: <C-Left> window on the left (4e79669), <C-Right> next tab (4a917a0)
    - [x] talk to claude desktop or claude from nvim
        -[x] claude in float term for now. using claude.exe
    - need to work out a spec
        - [x] resume sessions based on commentstring
            - [ ] also if started from an oil buffer?
                - no. no need for now
        - one claude float term per project?
            - [ ] or use the <- session manager inside claude?
            - decided 2026-10-23: one floaterm per project root (marker cwd, git root, cwd),
              plus a picker of running ones: <leader>pl, :ClaudeFterm! (<CR> show, <M-d> kill)
    - [x] claude in a floaterm, :ClaudeFterm, <leader>pc paste context (lua/genja/claude.lua);
        - the pasting is WIP, need to work out / test out a spec
    - session marker: /rename in claude writes `claude-session: <uuid> <title>`
      into the buffer claude was started from; :ClaudeFterm from that file resumes the session
        - not sure if this is a fantastic idea
            - can accumulate context
            - convenient for restarting nvim
            - the commentstring can have enabled:false which can be toggled manually
            - for txt files, just put the markers at the bottom with !! as prefix
        - works for files
        - resume does not work if opened from oil
            - because there are no commentstrings to put the session marker
            - this is ok

- [~] 16. <m-?>:  popup with ai chat to ask some random question.
    - output should be mega brief and text-only (no markdown)
    - need to work out a spec
        - see what other people are doing for ideas
    - so far: <leader>pC prompt popup in lua/genja/claude.lua, sends to the claude floaterm (#19)
    - decouple the popup from the claude floaterm
    - send to multiple backends: a multi-agent simple prompt plugin
    - first backend: the claude -p pwsh function; reconsider it, rewrite it in lua as the first cli backend
    - <M-…> keys in the popup to pick: where to send the prompt, model, effort (each with a default)
    - spec 2026-10-23 (details: doc-wip/squash-ideas-oct-17.details.md #16)
        - code in lua/genja/ask.lua + lua/genja/ask/backends/ (move to plug-wip later)
        - <M-?> opens it (n, i, v: selection goes along), <leader>pC alias
        - in the popup: <M-t> target, <M-m> model, <M-e> effort, <M-s> save session
        - backends: claude -p, the claude floaterm, gemini / copilot / aichat
        - answer in the same float: q/<Esc> close, y yank, <CR> follow-up; log to ~/.claude/p-logs/nvim.log


-[.] 26. which keys
    - [x] sort by description alphabetically, columns first
    - [x] <F2>/<F3> scroll the popup (e6ffb52)
    - [.] check if it's possible to search by description
        - use <c-/> in telescope
        - [x] check <leader>? (Keymaps): `/` searches key, desc and category
            - [x] fold keys missing: keymaps.nvim hid `^z[zoOcCaAmMrRfF]$` as builtins
                - fork in plug-wip/abdul-keymaps.nvim (branch genja-desc-builtins), spec loads it (08400fd)
                - [x] include_builtins_with_desc: show builtin keys remapped with a desc (9130d41, 8231836)
                - [x] builtin_patterns as an option, full list declared in the spec (9130d41, 30713ca)
            - [x] category_order: Fold and LSP checked first, so 'Fold: delete' is not Editing (79f46dd, ae8e8e5)
            - [x] float popup: mode letters (aac76e3), t cycles n/i/v/x/…/all, T all (36b4cf4, d3af9d5, b401e29)
            - [x] float popup: one-line header, h toggles the hints (8b4daf3); empty search resets (0890585)
            - [x] cache_timeout 20s (1b41f8d)
            - section order on screen is still by name (ui.lua); category_order only picks the category
                - [x] stays by name (decided 2026-10-23)
            - [x] keep the fork as its own repo, commits go there; ignored via .git/info/exclude; PR upstream later
        - [-] check Telescope keymaps (<leader>jM): superseded by abdul-keymaps for now (custom picker: todo-2027.txt)
                - [x] does not show oil maps: oil maps are buffer-local, they show when opened from an oil buffer
                - [x] does not show updated descriptions for fold keys
                    - needed the manual remap of the fold keys in map-zero (bea7b97, 1d0d2db)
                - modes default to n,i,c,x (no o); pass modes = {...}
        - [ ] maybe extend telescope keymaps with refine-decorator (see 25)
            - [ ] or cook <m-r> mapping for it to toggle / rotate groups
    - [x] redefine all standard fold mapping keys with a description prefix «Fold: »
        - do this in map-zero in a separate fold for folds
        - tried as descriptions only in lua/lazyp/my/which-key.lua (no remapping)
        - the whick-key popup does sort correctly
        - [.] want to make them searchable in
            - [x] telescope keymaps (superseded by abdul-keymaps)
            - [x] Keymaps user func / custom popup


- [~] 14. gitcommit: plug-wip/genja-commit.nvim (details in its CLAUDE.md) (wip)
    - commit popup moved out of oil; :w keeps the draft in .git/COMMIT_EDITMSG
    - lint while typing: nvim-lint + gitlint, built-in Lua rules when Python/gitlint are missing
    - <M-g> writes the message from the staged diff (claude / copilot / gemini / aichat)
    - copilot ghost text in commit buffers, accept with <M-f>
    - opt-in Conventional Commits mode; cmp offers types, scopes, footers
    - commits: 64baa3b, 3d5dc8c, e02ab60, fdc634c


- [ ] 14e. nvim-lint: further linters (not covered by an LSP)
    - yaml / ansible: ansible-lint, yamllint
    - dockerfile: hadolint
    - markdown: markdownlint-cli2, vale (prose)
    - lua: selene or luacheck
    - make: checkmake
    - github workflows: actionlint
    - any filetype: codespell or typos, gitleaks (secrets), editorconfig-checker
    - python: ruff (pyright covers types only)
    - php: phpcs (phpactor runs phpstan, maybe not phpcs)
    - vim: vint (old)
    - skip: shellcheck (bashls), eslint (LSP)
    - check Windows support per tool; non-stdin linters run only after :w
    - first wave (decided 2026-10-23): markdownlint-cli2, typos (markdown, gitcommit), yamllint,
      ansible-lint (WSL, like phpactor), selene, checkmake, phpcs, actionlint
        - install: mason-tool-installer (all but ansible-lint)

- [ ] 30. telescope: mousability
    - click selects, double-click runs: built into telescope (found 2026-10-23, see #17)
    - select lines (actions in code actions from lsp, F1, F2, F3, scroll list)

- [ ] 31. nvim-init
    - improve/add mouse functionality in nvim
    - for lazy mornings, or planning sessions
        - some mouseability
        - navigate notes, todo
        - better context support
        - check out what other people are doing
    - spec 2026-10-23 (#30/31, details: doc-wip/squash-ideas-oct-17.details.md)
        - right-click PopUp entries per filetype (markdown, oil, code)
        - clickable winbar/statusline: branch -> Neogit, diagnostics -> list, filename -> oil
        - :Morning buffer (command only, not on start), `Morning` in the right-click menu
        - mini.starter spec in lua/lazyp/ui/, disabled
        - scroll wheel in telescope: default, the selection doesn't move

- [~] 32. bug in winbar or statusbar
    - resizing activates right-most tab
    - cause (likely): frameless nvim-qt (ginit.vim) sends top-edge resize drags as clicks on the tabline;
      nvim goes to the next tab on a click outside the labels (:h tabpage, "Click where there is no label")
    - [x] fix: no-op click region over the tabline's left edge and fill (genja-statusline autoload/genja_statusline.vim); untested
    - [ ] confirm: resize nvim-qt from the top edge, tab stays; optional repro with GuiWindowFrameless(0)

- [ ] 35. recent files
    - make my own plugin with my rules for saving and ranking files
    - study in essense
        - telescope old files
        - old mru plugin
    - spec 2026-10-23 (details: doc-wip/squash-ideas-oct-17.details.md #35)
        - plug-wip/genja-recent.nvim, ranking shared with genja-startdirs
        - record on BufWinEnter and BufWritePost; views and edits counted apart
        - skip: non-file buftypes, .git/, %TEMP%, nvim-data (option)
        - frecency, edits x2; picker on the current project, <M-a> all
        - data: nvim-data/genja-recent.txt; <C-F1> opens it, oldfiles moves to a free <leader>j key
