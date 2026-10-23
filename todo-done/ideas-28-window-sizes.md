from: todo-ideas.md

- [x] 28. find a plugin to rotate window / pane layouts
    - one key to rotate
        - vsplit : 50 / 50 -> 30 / 70 -> 60 / 40
        - some simeple way to hold + / - to make the current window bigger by incremental steps, that are not 1 column at a time
        - probably find a plugin for this
    - done (own module, no plugin): lua/genja/winsize.lua; untested by hand
        - <M-=>/<M--> grow/shrink 10% (or 8 cols / 4 lines), <M-0> share cycle 50/30/70/60
        - <leader>wr resize mode: which-key loop over <leader>W h j k l = 0 s
        - smart-splits.nvim spec, disabled (lua/lazyp/new/smart-splits.lua)
