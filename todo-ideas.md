# list of improvements to nvim


## related files

squash ideas details and estimations

    ./doc-wip/squash-ideas-oct-17.md
    ./doc-wip/squash-ideas-oct-17.details.md

future work (need to limit the neovim-2026 project)

    ./todo-2027.txt

migration from 0.9 to 0.11 (the file that started it all)

    ./todo-2026-neovim011.txt

## ideas october

- [~] 19. claude: from nvim (wip)
    - [x] prettier winbar names: `claude-ft «<session title>»`, else the cwd basename (bfd6eef)
    - [x] :ClaudeFterm [flags]: --chrome, --model, --effort, ... at start, <Tab> completes (55240fa)
    - [x] terminal keys: <C-Left> window on the left (4e79669), <C-Right> next tab (4a917a0)
        - [x] <M-]>/<M-[> next/previous tab (af9c7a4), <M-{> previous window (6a4c414)
    - [x] :DevReloadClaude drops the cached claude modules; :F2Reload renamed :DevReloadF2 (bab761a)
    - [x] prompt popup: bigger, placed up-left (55140b2); <C-CR> sends, <CR> adds a newline (96562ed)
    - [x] talk to claude desktop or claude from nvim
        -[x] claude in float term for now. using claude.exe
    - need to work out a spec
        - [x] resume sessions based on commentstring
            - [-] also if started from an oil buffer?
                - no. no need for now
        - [x] one claude float term per project?
            - [-] or use the <- session manager inside claude?
            - decided 2026-10-23: one floaterm per project root (marker cwd, git root, cwd),
              plus a picker of running ones: <leader>pt (<leader>pl is Perplexity), :ClaudeFterm!
              (<CR> show, <M-d> kill); untested, doc-wip/readme.2026-10-23.claude-per-project.md (80f96ba)
    - [x] claude in a floaterm, :ClaudeFterm, <leader>pc paste context (lua/genja/claude.lua);
        - the pasting is WIP, need to work out / test out a spec
        - [x] <L>pC opens a modal but the ability to paste to claudefterm is gone. map it to <m-p> for now
            - <M-p> in the ask popup sends to the claude floaterm, whatever the target (2026-10-24)
        - [x] otherwise mark as untested: <leader>pc, doc-wip/untested.2026-10-24.md
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
        - lua/genja/lint.lua; untested, doc-wip/readme.2026-10-23.lint-first-wave.md (b5383bd)
    - later: hadolint, vale, ruff, gitleaks, editorconfig-checker, vint
    - [x] second wave (decided 2026-10-24): hadolint, ruff (only without the ruff LSP),
      editorconfig-checker (any filetype, below a .editorconfig), vint
        - untested, doc-wip/readme.2026-10-24.lint-second-wave.md
    - still later: vale, gitleaks

- [x] extras outside the idea list (2026-10-23)
    - [x] winbar: quickfix windows show w:quickfix_title, no duplicate %q (6f29b37)
    - [x] map-telescope: helpers in fn.lua; <leader>jj1/jj2 quickfix/loclist, genja grep/find on jjJ/jjj,
          builtins under <leader>jb (6aa5a7b); which-key groups <leader>j. and <leader>j/ (73c4c3b)
    - [x] focus.nvim: vim.g.focus_disable, so <C-w>= sticks; <leader>tPf can turn it on (28c80c0)
    - [x] every vim.notify names its file through a SRC prefix (2aadf61)
    - [x] mylunsj lists Telescope mydirs first (1151dfb)
    - [x] cmdline completion: <Tab>/<S-Tab> next/previous, <Up>/<Down> pick while the menu is open (b5173ad)



- [ ] improve: key maps map-plug
    - idea: calls from spec-files; log missing and detect with healthcheck
    - the error message about no maps for "plugin" should indicate which plugin
    - probably via reflection also
    - this should be logged as a notice, only once per nvim-session. not notify, log
    - there should be a healthcheck for this
        - ok to grep / parse?
        - maybe use treesitter to reverse-lookup references?
        - who calls Maps:mappings()? who comes up empty handed?
        - i guess we can not record this, because the healthcheck should be stateless.
            - but then again, maybe call an api in the plugin to record a missing lookup when it happens?
            - should not be that bad. we already have the caller and his file then
    - [x] done 2026-10-24: misses go to stdpath('log')/genja-map-plugin.log, once per name and session,
      with the caller's file; no notify. :checkhealth genja.map-plugin lists this session's misses,
      keys nobody asked for, mappings not used yet (runtime only, no grep, doesn't read the log)
        - untested, doc-wip/readme.2026-10-24.map-plugin-health.md



- [ ] when a lua trace makes it to the :messages list
    - add an <f2> action to go to the relevant file and line
    - can this be done in an efficient way?
    - need to monitor all notifications?
    - explore options. other people must have done something similar before

- [ ] disable gitsigns indicators in markdown files by default
    - add a toggle keybind
        - <leader>mGs


- [ ] <leader>oO opens the same ui as <leader>mO
    - that ui needs an <esc> bind to disappear
    - i think its aerial
    - <leader>oo opens the sidebar outline


<!-- claude-session: 7cdef237-3904-4b52-b7ca-c676e635151a test untested -->
