from: todo-ideas.md

- [x] 30. telescope: mousability (closed 2026-10-23)
    - click selects, double-click runs: built into telescope (found 2026-10-23, see #17)
    - select lines (actions in code actions from lsp, F1, F2, F3, scroll list)

- [x] 31. nvim-init (done 2026-10-23, untested: doc-wip/readme.2026-10-23.mouse-morning.md)
    - improve/add mouse functionality in nvim
    - for lazy mornings, or planning sessions
        - some mouseability
        - navigate notes, todo
        - better context support
        - check out what other people are doing
    - spec 2026-10-23 (#30/31, details: doc-wip/squash-ideas-oct-17.details.md)
        - [x] right-click PopUp entries per filetype (markdown, oil, code): lua/genja/popup-menu.lua
        - [x] clickable statusline: branch -> Neogit, diagnostics -> list, filename -> oil (genja-statusline clicks)
            - statusline only: with laststatus=3 it acts on the current window; the winbar is not clickable
        - [x] :Morning buffer (command only, not on start), `Morning` in the right-click menu
        - [x] mini.starter spec in lua/lazyp/ui/, disabled
        - scroll wheel in telescope: default, the selection doesn't move
