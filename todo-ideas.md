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

- [ ] 48. terminal cursor: hollow box (unresolved, lua/genja/opt-term.lua)
    - [x] bar cursor, no blink, StatusLine color; :TermCursorShape bar|block; <S-Insert> pastes "+ in terminal mode (51a1942)
    - 'guicursor' has no hollow shape; Windows Terminal draws one with `"cursorShape": "emptyBox"`,
      but only when nvim sends no shape (`:set guicursor=`), which drops the shapes in all modes
    - still blinks: since 0.11 the app in the terminal sets cursor shape/blink (DECSCUSR);
      check which app (cmd vs pwsh vs claude), or turn blink off in Windows (Keyboard: cursor blink rate)

- [ ] 39. claude session marker follow-up (from #19, todo-done/ideas-19-claude-from-nvim.md)
    - the commentstring can have enabled:false which can be toggled manually
    - for txt files, just put the markers at the bottom with !! as prefix

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
        - tested 2026-10-24: hadolint, ruff, editorconfig-checker ok (.editorconfig got indent_style)
        - [ ] vint disabled (2026-10-24): broken on Windows. Python 3.13 venv: no `pkg_resources`
          (Vimjas/vint#394, draft PR #397; pinning setuptools<81 in the mason venv gets past it),
          then `PosixPath` can't be instantiated on Windows (#378, open since 2022). Last release 2019.
          Revisit for heavy vimscript editing: Linux/WSL only, or a fork. (266485f)
    - still later: vale, gitleaks
        - [x] done 2026-10-24: gitleaks on every filetype; vale on markdown, project .vale.ini or the shared
          lint/.vale.ini (Microsoft, write-good; :ValeSync downloads the styles); untested,
          doc-wip/readme.2026-10-24.lint-vale-gitleaks.md (9853946)
    - [x] checkmake works on Windows: own --format and parser (8dd25c3)
    - [x] exit-code warnings name the linter, not cmd.exe (09cc345)

- [x] extras outside the idea list (2026-10-23)
    - [x] winbar: quickfix windows show w:quickfix_title, no duplicate %q (6f29b37)
    - [x] map-telescope: helpers in fn.lua; <leader>jj1/jj2 quickfix/loclist, genja grep/find on jjJ/jjj,
          builtins under <leader>jb (6aa5a7b); which-key groups <leader>j. and <leader>j/ (73c4c3b)
    - [x] focus.nvim: vim.g.focus_disable, so <C-w>= sticks; <leader>tPf can turn it on (28c80c0)
    - [x] every vim.notify names its file through a SRC prefix (2aadf61)
    - [x] mylunsj lists Telescope mydirs first (1151dfb)
    - [x] cmdline completion: <Tab>/<S-Tab> next/previous, <Up>/<Down> pick while the menu is open (b5173ad)

- [x] extras outside the idea list (2026-10-24)
    - [x] cmdline: <C-j>/<C-k> pick items, <Up>/<Down> back to history (0de4d52)
    - [x] map-lsp: descs for nvim 0.11 gr* defaults, references on gR, [d ]d go the way their descs say (5e788aa)
    - [x] markdown: <F2> glow preview in a new pwsh window, Windows only (21cfe96)
    - [x] intro: eob ~ drawn in column 0 like vanilla (81a4659)
    - [x] gui: nvim-qt toggles on <leader>mQ…, GuiFuncs picker (<F3>, <F2> gui), right-click frameless,
          one shared state per Gui* function; neovim-gui-shim on again; tested (3580a06, ad94a79)
    - [x] edit: visual <leader>w, wraps lines as "line",; title case on <leader>wsT, sort paragraph <leader>wsp (8f25155)
    - [x] f2 git: <M-a> git adds the file, picker stays open (e6c04ac)
    - [x] hilite: darker Search/IncSearch/CurSearch background (a1b0857)
    - [x] startdirs: <M-1>…<M-4> jump by rank and don't count a use; :Mydirs picker,
          :Mydirs reset deletes the usage file; tested (1132d6b)

- [x] extras outside the idea list (2026-10-25)
    - [x] telescope keymaps: <M-r> after <M-f>/<M-x> cycles the groups of the refined list; tested (2debb3b)
    - [x] tests: map-plugin miss log and health (af13aed), claudefterm per project (63800da),
          comps011 lsp/cmp/lint with groups and timings (9f5f014); tests/Makefile runs every dir
    - [x] aerial: nav float 5% see-through (cbe6c13)
    - [x] gitsigns: <leader>mGs attaches skipped buffers again (e9e50f7)
    - [x] f2: groups of at most 6 chars, main list `group  label` in one column (5edddfa)
    - [x] floaterm: :PwshFterm (50e4b8a)
    - [x] mason: make mason-luals reinstalls lua-language-server headless (19d67f5)
    - [x] :ToggleDiagnostics for the current buffer (38e3d2d)

- [~] telescope
		- exploration in order to improve usability
		- try removing all the predefined keys except my own through the decorator
		- or maybe unset them via global config
		- i want to check if the built in <c-/> can be used to discover functionality
		- maybe i need to think about and experiment with a more elaborate layout
			- [-] a footer for relevant keymaps with descriptions thats always on
			- key help table (key | m | description) in the empty results buffer (lua/genja/telescope-virthelp.lua); untested
			- a custom preview-like component with hand-picked keys and leave <c-/> as is
		- [x] 2026-10-24: prototype footer (lua/genja/telescope-footer.lua, :TelescopeFooter) + spec with 6 questions:
		  doc-wip/readme.2026-10-24.telescope-explore.md; untested (9829d55)
		- [-] 2026-10-25: footer abandoned (approach not liked); footer code, :TelescopeFooter and its tests removed

<!-- claude-session: 7cdef237-3904-4b52-b7ca-c676e635151a test untested -->
