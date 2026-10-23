from: todo-ideas.md

- [x] 32. bug in winbar or statusbar (fixed 2026-10-23)
    - resizing activates right-most tab
        - any edge or corner, not only the top (found by hand 2026-10-23)
    - cause (likely): frameless nvim-qt (ginit.vim) sends top-edge resize drags as clicks on the tabline;
      nvim goes to the next tab on a click outside the labels (:h tabpage, "Click where there is no label")
        - wrong guess: the real cause was `autocmd VimResized * tabdo wincmd =` in
          lua/genja/auto-alias.vim; tabdo ends on the last tab
    - [x] fix: no-op click region over the tabline's left edge and fill (genja-statusline autoload/genja_statusline.vim); untested
        - kept: harmless, a stray click on the empty tabline no longer switches tabs
    - [x] real fix: the autocmd goes back to the current tab after tabdo; augroup renamed
      _auto_resize -> _resize_equalize_tabs (lua/genja/auto-alias.vim); headless check: tab 2 of 4 stays
    - [ ] confirm: resize nvim-qt by any edge, tab stays (untested list)
