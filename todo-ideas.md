
- [ ] 19. claude: from nvim
    - talk to claude desktop or claude from nvim

- [ ] 20. voice input in nvim

- [x] 2. quickfix list close with x

- [ ] 9. git:    gitsigns.nvim (Neovim): stage or reset hunks from the buffer. 
- [ ] 15. oil:    hide a set of predefined folders based on PWD/.oily. (implemented, untested)
    - nvim custom plugin or an existing one, or just config?
    - also add keybind to hide current item from the oil ui
- [x] 7. oil:    normal gga -> git add
- [x] 8. <S-F1>: search from oil plugin current dir.
- [ ] 16. <c-?>:  popup with ai chat to ask some random question. output should be mega brief and text-only (no markdown)

- [ ] 18. context-sensitive telescope dropdown on <F2>
    -make: list targets to execute
    -oil: git worktree: files to add with preview

- [ ] 10. cmp: delay popup by 500 ms if it starts with :w
    - the popup flashes annoyingly when auto-saving

- [ ] 17. treesitter: add a gui-trigger key that lists further actions (maybe g.)
    - go to implementation, definition, rename.
    - like a lazy catch-all-action "right-click"

- [ ] 13. json/yaml: display the outer key, or even path somewhere in the statusbar or tabbar


- [x] 3. nvim: remove charity nag. keep plain startup message
    - maybe look for a plugin that recreates the startup message

- [ ] 11. redefine all standard fold commands with better descriptions «Fold: …»

- [x] 5. lsp binds: scroll in hover window / buffer
- [x] 4. lsp binds: close hover window with <esc>

- [ ] 12. code actions - view in telescope


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
