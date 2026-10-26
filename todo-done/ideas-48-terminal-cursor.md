from: todo-ideas.md

- [x] 48. terminal cursor: hollow box (unresolved, lua/genja/opt-term.lua)
  - [x] bar cursor, no blink, StatusLine color; :TermCursorShape bar|block; <S-Insert> pastes "+ in terminal mode (51a1942)
  - 'guicursor' has no hollow shape; Windows Terminal draws one with `"cursorShape": "emptyBox"`,
      but only when nvim sends no shape (`:set guicursor=`), which drops the shapes in all modes
  - still blinks: since 0.11 the app in the terminal sets cursor shape/blink (DECSCUSR);
      check which app (cmd vs pwsh vs claude), or turn blink off in Windows (Keyboard: cursor blink rate)
  - [x] closed 2026-10-26 (auto-todo-20261026-2311): tested, the bar cursor works well enough;
      a hollow box is not possible from nvim
