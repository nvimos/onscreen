from: todo-ideas.md

- [x] 17. treesitter: add a gui-trigger key that lists further actions (maybe g.)
    -[x] make an entry in the right-click context menu for it: Actions (g.) (lua/genja/fn.vim); untested
        - [x] explore if it's possible to click items in telescope
            - built in: click selects, double-click runs (mouse=a)
    -[x] go to implementation, definition, rename.
    -[x] add actions; untested
        -[x] source current file (lua, vim)
        -[x] start ClaudeFterm
    - as if it's a catch-all-action right-click
        - consider adding that to the popup menu
        - can telescope be used with a mouse?
    - done instead: telescope action menu on g. and <LocalLeader>/ (lua/genja/actions.lua), built per call
    - cur: items for the cursor (LSP, line diagnostics, word, oil entry), unprefixed ones for buffer/editor
