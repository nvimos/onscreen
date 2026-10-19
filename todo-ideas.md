
- [~] 19. claude: from nvim (wip)
    - [ ] prettier winbar names
        - figure out how floaterm sets them
        - use renamed session name instead of uuid
        - use first block of uuid if no name
            - or use dirname of workspace / project / Claude.md / lsp root marker
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
            - [ ] fix hourglass cursor
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


- [x] 3. nvim: remove charity nag. keep plain startup message
    - maybe look for a plugin that recreates the startup message

- [ ] 11. redefine all standard fold commands with better descriptions «Fold: …»

- [x] 5. lsp binds: scroll in hover window / buffer
- [x] 4. lsp binds: close hover window with <esc>

- [x] 12. code actions - view in telescope
    - done instead: vim.ui.select overridden with a telescope dropdown (lua/genja/ui-select.lua)
    - covers code actions and every other vim.ui.select caller (:OverseerRun etc.)


- [x] 6. oil: auto confirm creation of a single dir / file

- [ ] 14. gitcommit: lint commit messages with nvim-lint (mfussenegger/nvim-lint) + gitlint (Mason: gitlint, needs Python)
    - nvim-lint is not installed yet; would also cover other non-LSP linters
    - gitcommit currently has treesitter highlighting only

- [x] 1. genja-finder.nvim: move live grep/find and their togglers into 
    - plug-wip/genja-finder.nvim
    - see plug-wip/genja-finder.nvim/move-plan.md


- which keys
    - sort by description alphabetically, columns first
    - check if it's possible to search by description
    - redefine all standard fold mapping keys with a description prefix «Fold: »

- telescope old files
    - implement <m-f> refinement for it too. reuse code if possible

- find a plugin to rotate window / pane layouts
    - one key to rotate
        - vsplit : 50 / 50 -> 30 / 70 -> 60 / 40
        - some simeple way to hold + / - to make the current window bigger by incremental steps, that are not 1 column at a time
        - probably find a plugin for this

- [ ] almavimrc: incorporate / rewrite to lua
    - put submodules lua/genja/alma
    - [ ] the ~ behavior to toggle false and other switches

- [ ] telescope: mousability
    - select lines (actions in code actions from lsp, F1, F2, F3, scroll list)

- [ ] nvim-init
    - for lazy mornings, or planning sessions
        - some mouseability
        - navigate notes, todo
        - better context support
        - check out what other people are doing

- [ ] bug in winbar or statusbar
    - resizing activates right-most tab

- [ ] move gitea definition to w11s cut project

- [ ] consider adopting
    - https://github.com/folke/snacks.nvim/blob/main/docs/dashboard.md

## wip

claude --resume 7b18fe92-00bb-4c60-a50f-7be457ed680d
