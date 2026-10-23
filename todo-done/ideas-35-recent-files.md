from: todo-ideas.md

- [x] 35. recent files (done 2026-10-23, untested: doc-wip/readme.2026-10-23.genja-recent.md)
    - make my own plugin with my rules for saving and ranking files
    - study in essense
        - telescope old files
        - old mru plugin
    - spec 2026-10-23 (details: doc-wip/squash-ideas-oct-17.details.md #35)
        - plug-wip/genja-recent.nvim, ranking shared with genja-startdirs
            - frecency.lua is separate; startdirs still ranks by counts (needs a last-used time)
        - record on BufWinEnter and BufWritePost; views and edits counted apart
        - skip: non-file buftypes, .git/, %TEMP%, nvim-data (option)
        - frecency, edits x2; picker on the current project, <M-a> all
        - data: nvim-data/genja-recent.txt; <C-F1> opens it, oldfiles moves to a free <leader>j key
            - oldfiles was already on <leader>jo
