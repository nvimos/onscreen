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
        - [x] one claude float term per project?
            - [-] or use the <- session manager inside claude?
            - decided 2026-10-23: one floaterm per project root (marker cwd, git root, cwd),
              plus a picker of running ones: <leader>pt (<leader>pl is Perplexity), :ClaudeFterm!
              (<CR> show, <M-d> kill); untested, doc-wip/readme.2026-10-23.claude-per-project.md
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


- [~] 14. gitcommit: plug-wip/genja-commit.nvim (details in its CLAUDE.md) (wip)
    - commit popup moved out of oil; :w keeps the draft in .git/COMMIT_EDITMSG
    - lint while typing: nvim-lint + gitlint, built-in Lua rules when Python/gitlint are missing
    - <M-g> writes the message from the staged diff (claude / copilot / gemini / aichat)
    - copilot ghost text in commit buffers, accept with <M-f>
    - opt-in Conventional Commits mode; cmp offers types, scopes, footers
    - commits: 64baa3b, 3d5dc8c, e02ab60, fdc634c


- [~] 14e. nvim-lint: further linters (not covered by an LSP)
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
    - [x] first wave (decided 2026-10-23): markdownlint-cli2, typos (markdown, gitcommit), yamllint,
      ansible-lint (WSL, like phpactor), selene, checkmake, phpcs, actionlint
        - install: mason-tool-installer (all but ansible-lint)
        - lua/genja/lint.lua; untested, doc-wip/readme.2026-10-23.lint-first-wave.md
    - later: hadolint, vale, ruff, gitleaks, editorconfig-checker, vint

- [~] 32. bug in winbar or statusbar
    - resizing activates right-most tab
    - cause (likely): frameless nvim-qt (ginit.vim) sends top-edge resize drags as clicks on the tabline;
      nvim goes to the next tab on a click outside the labels (:h tabpage, "Click where there is no label")
    - [x] fix: no-op click region over the tabline's left edge and fill (genja-statusline autoload/genja_statusline.vim); untested
    - [ ] confirm: resize nvim-qt from the top edge, tab stays; optional repro with GuiWindowFrameless(0)

