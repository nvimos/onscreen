from: todo-ideas.md

- [x] 12. code actions - view in telescope
    - done instead: vim.ui.select overridden with a telescope dropdown (lua/genja/ui-select.lua)
    - covers code actions and every other vim.ui.select caller (:OverseerRun etc.)
    - code actions by kind: <leader>cq quickfix, ce extract, cr rewrite, cs source (d8e497b);
      search and replace moved to <leader>cS (9013eb0)
