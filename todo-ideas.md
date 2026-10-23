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
        - one claude float term per project?
            - [ ] or use the <- session manager inside claude?
    - so far (untested): claude in a floaterm, :ClaudeFterm, <leader>pc paste context (lua/genja/claude.lua);
      codecompanion «idea 19 companion» (lua/lazyp/langs-comps/codecompanion.lua)
        - the pasting is WIP, need to work out / test out a spec
        - floaterm works ok
            - [~] fix hourglass cursor: claude's title updates off while it starts (4e79669)
    - session marker: /rename in claude writes `claude-session: <uuid> <title>`
      into the buffer claude was started from; :ClaudeFterm from that file resumes the session
        - not sure if this is a fantastic idea
            - can accumulate context
            - convenient for restarting nvim
            - maybe the commentstring can have enabled:false which can be toggled manually
        - works for files
        - resume does not work if opened from oil,
          because there are no commentstrings to put the session marker

- [ ] 20. voice input in nvim
    - check out windows input possibilities
    - check out via chrome
    - claude.exe voice input works well enough

- [x] 2. quickfix list close with x

- [ ] 9. git:    gitsigns.nvim (Neovim): stage or reset hunks from the buffer. 
- [x] 15. oil:    hide a set of predefined folders based on PWD/.oily.
    - nvim custom plugin or an existing one, or just config?
    - also add keybind to hide current item from the oil ui
- [x] 7. oil:    normal gga -> git add
- [x] 8. <S-F1>: search from oil plugin current dir.
- [~] 16. <c-?>:  popup with ai chat to ask some random question. output should be mega brief and text-only (no markdown) (wip)
    - need to work out a spec.
    - so far: <leader>pC prompt popup in lua/genja/claude.lua, sends to the claude floaterm (#19)
    - decouple the popup from the claude floaterm
    - send to multiple backends: a multi-agent simple prompt plugin
    - first backend: the claude -p pwsh function; reconsider it, rewrite it in lua as the first cli backend
    - <M-…> keys in the popup to pick: where to send the prompt, model, effort (each with a default)

- [.] 18. context-sensitive telescope dropdown on <F2> (partly: make done, oil open)
    -make: list targets to execute
    -oil: git worktree: files to add with preview
    - sources (2026-10-19): lua/genja/f2/ (adhoc, git, make); items prefixed `group: `
    - notes and user guide: doc-wip/readme.idea18-f2-context.md
        - adhoc: `go mod init <dirname>` when no go.mod/go.work, then gopls restarts
        - [x] git source (oil only): `git: add (N files)` sub-picker with status codes, diff preview, <Tab> marks
        - [x] f2.add_tasks(tasks, { buffer? }) / f2.add_task(group, label):…:add() builder / f2.remove_tasks({ group, label?, buffer? }), f2.group_order
            - task: label, group, action (keys|function) or cmd (+ runner overseer|floaterm, cwd), order, cond, autoremove
            - [ ] first caller
        - [x] git add picker: preview hidden at start, <C-p> toggles it, <M-t> tabs (picker stays), <M-e> edit; :F2Reload (6fdd7e3)
    - unit tests: tests/f2/ (mini.test), `make test` in lua/genja/f2/ (96c9375); not run yet

- [x] 10. cmp: delay popup by 500 ms if it starts with :w
    - the popup flashes annoyingly when auto-saving
    - done instead: no delay; normal-mode :w<CR> mapped to <Cmd>write<CR> (map-zero.lua), so no cmdline and no popup
    - which-key filter keeps ':' mappings out, so ':' still opens the cmdline; nothing typed :w automatically

- [x] 17. treesitter: add a gui-trigger key that lists further actions (maybe g.)
    -[x] go to implementation, definition, rename.
    -[ ] add actions
        -[ ] source current file
        -[ ] start ClaudeFterm
    - as if it's a catch-all-action right-click
        - consider adding that to the popup menu
        - can telescope be used with a mouse?
    - done instead: telescope action menu on g. and <LocalLeader>/ (lua/genja/actions.lua), built per call
    - cur: items for the cursor (LSP, line diagnostics, word, oil entry), unprefixed ones for buffer/editor

- [ ] 13. json/yaml: display the outer key, or even path somewhere in the statusbar or tabbar
    - navigatable  https://github.com/Bekaboo/dropbar.nvim
    - simpler      https://github.com/SmiteshP/nvim-navic
    - Full sidebar 
        - https://github.com/hedyhli/outline.nvim
        - https://github.com/stevearc/aerial.nvim
        - https://github.com/oskarrrrrrr/symbols.nvim
    - aerial outline sidebar also on <C-s> (5bc3fb8)


- [x] 3. nvim: remove charity nag. keep plain startup message
    - maybe look for a plugin that recreates the startup message


- [x] 5. lsp binds: scroll in hover window / buffer
- [x] 4. lsp binds: close hover window with <esc>

- [x] 12. code actions - view in telescope
    - done instead: vim.ui.select overridden with a telescope dropdown (lua/genja/ui-select.lua)
    - covers code actions and every other vim.ui.select caller (:OverseerRun etc.)
    - code actions by kind: <leader>cq quickfix, ce extract, cr rewrite, cs source (d8e497b);
      search and replace moved to <leader>cS (9013eb0)

- [x] 21. Go: gopls local import groups from go.work/go.mod, code lenses, <leader>cl runs the lens (e3c61d5, 4a917a0)


- [x] 6. oil: auto confirm creation of a single dir / file


- [x] 1. genja-finder.nvim: move live grep/find and their togglers into 
    - plug-wip/genja-finder.nvim
    - see plug-wip/genja-finder.nvim/move-plan.md

- [x] 22. telescope: picker keys to the location/quickfix list (<M-l/q> marked, <M-L/Q> append,
      <C-l/q> all), <C-/> lists the keys, hint in the empty prompt (0b48222)

- [x] 23. urlview.nvim: visual gx and <leader>gx pick URLs, <Tab> marks, <CR> opens all marked (a9ef21d, 4a3aed3, 082fd2d)

- [x] 24. genja-splitpad.nvim: padding column next to the separator in unfocused splits (4956074, 0bb1d95); spec disabled in lua/lazyp/no/ (6fdd7e3)

- [ ] setup Neogit + gitsigns + diffview.
    - also mini.git


- [ ] 25. telescope refine decorator in steps
    - reusable decorator that enhances any picker; separate file in lua/genja/ for now
        - [x] moved into genja-finder instead: refine.lua (<M-f> filter, decorate), telemap.lua (Telemap moved there),
              require('genja-finder').attach_shared_keys(map) / .enhance(picker) use both; untested
        - [x] decorate a first picker: <C-F1> oldfiles via enhance() (lua/genja/map-telescope.lua); untested
        - [ ] <M-x> exclude
    - see if someone has done it already
    - <m-f> refine
    - <m-x> exclude
    - telescope old files
        - implement <m-f> refinement for it too. reuse code if possible

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

- [x] 11. redefine all standard fold commands with better descriptions «Fold: …»
    - map-zero maps the built-in fold keys to themselves with «Fold: …» descriptions (bea7b97, 1d0d2db)


- [~] 14. gitcommit: plug-wip/genja-commit.nvim (details in its CLAUDE.md) (wip)
    - commit popup moved out of oil; :w keeps the draft in .git/COMMIT_EDITMSG
    - lint while typing: nvim-lint + gitlint, built-in Lua rules when Python/gitlint are missing
    - <M-g> writes the message from the staged diff (claude / copilot / gemini / aichat)
    - copilot ghost text in commit buffers, accept with <M-f>
    - opt-in Conventional Commits mode; cmp offers types, scopes, footers
    - commits: 64baa3b, 3d5dc8c, e02ab60, fdc634c

- [x] 27. copilot.vim: ghost text, keys in the cheatsheet (7d3d537, 53744b7); loads only for gitcommit, <leader>at toggles the other filetypes (e02ab60)

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

- [ ] 28. find a plugin to rotate window / pane layouts
    - one key to rotate
        - vsplit : 50 / 50 -> 30 / 70 -> 60 / 40
        - some simeple way to hold + / - to make the current window bigger by incremental steps, that are not 1 column at a time
        - probably find a plugin for this



- [ ] 29. almavimrc. clone in lua the behaviors
    - [ ] ~ to toggle false and other switches
    - [ ] create fold from visual selection (add {{{,}}} markers)

- [ ] 30. telescope: mousability
    - select lines (actions in code actions from lsp, F1, F2, F3, scroll list)

- [ ] 31. nvim-init
    - improve/add mouse functionality in nvim
    - for lazy mornings, or planning sessions
        - some mouseability
        - navigate notes, todo
        - better context support
        - check out what other people are doing

- [ ] 32. bug in winbar or statusbar
    - resizing activates right-most tab

- [ ] 33. move gitea definition to w11s-cut project

- [ ] 34. f2 context: markdown
    - turn selection into checklist



- [ ] 35. recent files
    - make my own plugin with my rules for saving and ranking files
    - study in essense
        - telescope old files
        - old mru plugin

- [ ] 36. add keys in oil to auto-add a location (item) from the list to the startdirs
    - it can take some usability / features from harpoon - ask if they seem relevant
    - it should save new locations to NVIM/local/startdirs.json
        - or some lua-native format. maybe a plain text file will do
    - startdirs should become a plugin in plug-wip/


