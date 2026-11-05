# Done 2026-11-05 (from todo-ideas.md; :KeymapsStats untested, doc-wip/untested.2026-11-05.md)

- [x] custom keymap logger: count which keys/binds I use more than others
  - legendary only counts palette picks (frecency needs sqlite.lua, off in lua/lazyp/new/legendary.lua)
  - plug-wip/abdul-keymaps.nvim has track_usage + :KeymapsStats, but it only records mode changes
    (n->c, c->n …); its per-keymap wrapper create_tracker() is never called (checked 2026-10-31)
  - plugins checked 2026-10-31, none fits: keystats.nvim (counts, needs cargo), stalker.nvim (motions only),
    tobira.nvim (teaching), vim-stats (Vim, Ex commands)
  - decided 2026-10-31: do both
  - [x] finish create_tracker in the abdul-keymaps fork (plug-wip/abdul-keymaps.nvim/lua/keymaps/tracker.lua),
        so :KeymapsStats counts keymaps, not mode changes
    - 2026-11-02: each keymap is wrapped (counts, then runs the original); lazy-loaded and buffer-local
          ones wrapped as they appear; spec loads on VeryLazy (06bca1b); fork's earlier commits restyled like upstream; untested
  - [x] build your own, no need for json. keep it lua-native
    - closed 2026-11-05: the fork's tracker already counts every keymap; its JSON file is fine
    - vim.on_key(), match typed keys against nvim_get_keymap() by lhs, count per mode:lhs (+ desc)
    - store as a Lua file returning a table (loadfile to read), in stdpath('state'), written on VimLeavePre
    - :KeyStats picker sorted by count
