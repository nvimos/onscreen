from: todo-ideas.md

- [x] 44. test out zen mode toggles (lua/genja/map-plugin/zenmode.lua, moved from map-convoluted.lua)
    - <leader>mz :ZenMode with spec defaults
    - <leader>z1 width 120, no numbers, frameless GUI window
    - <leader>z2 width 80, relnum, colorcolumn 4,8,80, frameless + maximized
    - <leader>z0 closes and unsets frameless (decided: stays closed)
        - remember the width from before z1/z2 (the commented-out `width` code)?
    - switching z1 <-> z2 while zen is open: zen_mode.open() on an open zen window
    - GuiWindowMaximized: on for z2 only, commented out in z0/z1; decide
    - [x] keys moved into lua/genja/map-plugin/zenmode.lua (2f5fdaa)
    - [x] <leader>z0 closes zen and unsets frameless; z1 then z0 tested in nvim-qt (209380a)
    - [x] done 2026-10-24: z1 <-> z2 closes and reopens zen; z0 restores &columns/&lines and the diag limit
      from before the first z1/z2; maximized on z2 only; z1 sets the diagnostics limit to 2
        - untested, doc-wip/readme.2026-10-24.zen-toggles.md
