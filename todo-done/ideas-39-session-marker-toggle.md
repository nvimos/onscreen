from: todo-ideas.md

- [x] 39. claude session marker follow-up (from #19, todo-done/ideas-19-claude-from-nvim.md)
  - the commentstring can have enabled:false which can be toggled manually
  - for txt files, just put the markers at the bottom with !! as prefix
  - [x] done 2026-10-26: ` enabled:false` after the id switches a marker off: :ClaudeFterm starts a new
      session, /rename leaves the marker alone; :ClaudeFtermMarkerToggle adds or removes it
      (plug-wip/genja-claudefterm.nvim, toggle_marker())
  - [x] filetype text: `!! claude-session: <uuid> <title>` at the bottom (decided: text only; other
      filetypes without 'commentstring' still get no marker)
      - guide: doc-wip/readme.2026-10-26.session-marker-toggle.md; toggle checked headless, claudefterm tests pass
