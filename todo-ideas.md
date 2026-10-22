# list of improvements to nvim

## related files

    ./doc-wip/squash-ideas-oct-17.md
    ./doc-wip/squash-ideas-oct-17.details.md


## ideas october

- [~] 19. claude: from nvim (wip)
    - [x] prettier winbar names: `claude-ft «<session title>»`, else the cwd basename (bfd6eef)
    - [x] :ClaudeFterm [flags]: --chrome, --model, --effort, ... at start, <Tab> completes (55240fa)
    - [x] terminal keys: <C-Left> window on the left (4e79669), <C-Right> next tab (uncommitted)
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


- [x] 6. oil: auto confirm creation of a single dir / file


- [x] 1. genja-finder.nvim: move live grep/find and their togglers into 
    - plug-wip/genja-finder.nvim
    - see plug-wip/genja-finder.nvim/move-plan.md

- [x] telescope: picker keys to the location/quickfix list (<M-l/q> marked, <M-L/Q> append,
      <C-l/q> all), <C-/> lists the keys, hint in the empty prompt (0b48222)


-[.] which keys
    - [x] sort by description alphabetically, columns first
    - check if it's possible to search by description
        - check <leader>? (Keymaps)
            - does not show the updated descriptions for the default keymaps
                - maybe i need to redefine them after all.
        - check telescope keymaps
                - does not show oil maps
                - does not updated descriptions for fold keys
        - [ ] maybe extend telescope keymaps with refine-decorator
            - [ ] or cook <m-r> mapping for it to toggle / rotate groups
    - [x] redefine all standard fold mapping keys with a description prefix «Fold: »
        - do this in map-zero in a separate fold for folds
        - tried as descriptions only in lua/lazyp/my/which-key.lua (no remapping)

- [x] 11. redefine all standard fold commands with better descriptions «Fold: …»


- [ ] 14. gitcommit: lint commit messages with nvim-lint (mfussenegger/nvim-lint) + gitlint (Mason: gitlint, needs Python)
    - nvim-lint is not installed yet; would also cover other non-LSP linters
    - gitcommit currently has treesitter highlighting only
    - autofill with copilot

- [ ] find a plugin to rotate window / pane layouts
    - one key to rotate
        - vsplit : 50 / 50 -> 30 / 70 -> 60 / 40
        - some simeple way to hold + / - to make the current window bigger by incremental steps, that are not 1 column at a time
        - probably find a plugin for this



- [ ] almavimrc. clone in lua the behaviors
    - [ ] ~ to toggle false and other switches
    - [ ] create fold from visual selection (add {{{,}}} markers)

- [ ] telescope: mousability
    - select lines (actions in code actions from lsp, F1, F2, F3, scroll list)

- [ ] nvim-init
    - improve/add mouse functionality in nvim
    - for lazy mornings, or planning sessions
        - some mouseability
        - navigate notes, todo
        - better context support
        - check out what other people are doing

- [ ] bug in winbar or statusbar
    - resizing activates right-most tab

- [ ] move gitea definition to w11s-cut project


- [ ] telescope refine decorator in steps
    - see if someone has done it already
    - <m-f> refine
    - <m-x> exclude
    - telescope old files
        - implement <m-f> refinement for it too. reuse code if possible

- [ ] recent files
    - make my own plugin with my rules for saving and ranking files
    - study in essense
        - telescope old files
        - old mru plugin

- [ ] add keys in oil to auto-add a location (item) from the list to the startdirs
    - it can take some usability / features from harpoon - ask if they seem relevant
    - it should save new locations to NVIM/local/startdirs.json
        - or some lua-native format. maybe a plain text file will do
    - startdirs should become a plugin in plug-wip/


