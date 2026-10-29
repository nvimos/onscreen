from: todo-ideas.md

- [x] telescope
  - exploration in order to improve usability
  - try removing all the predefined keys except my own through the decorator
  - or maybe unset them via global config
  - i want to check if the built in <c-/> can be used to discover functionality
  - maybe i need to think about and experiment with a more elaborate layout
  - [-] a footer for relevant keymaps with descriptions thats always on
  - key help table (key | m | description) in the empty results buffer (lua/genja/ext/telescope-virthelp.lua); untested
  - [-] a custom preview-like component with hand-picked keys and leave <c-/> as is
    - dropped 2026-10-29 (auto-todo); item closed
  - [x] 2026-10-24: prototype footer (lua/genja/telescope-footer.lua, :TelescopeFooter) + spec with 6 questions:
    doc-wip/readme.2026-10-24.telescope-explore.md; untested (9829d55)
  - [-] 2026-10-25: footer abandoned (approach not liked); footer code, :TelescopeFooter and its tests removed
  - [x] 2026-10-26: telescope's default keys listed, commented out one per line, in two places: global
      (after/plugin/telescope-after.lua, A1) and pickers with attach_shared_keys (genja-finder `unmap`,
      lua/lazyp/new/genja-finder.lua, A2); uncomment to switch a key off; untested by hand
  - [x] 2026-10-26: <C-/> stays; loclist/quickfix picker keys got descs, so its list shows
      `Telescope: all to quickfix` etc. instead of action names (lua/genja/map-telescope.lua)
    - guide: doc-wip/readme.2026-10-26.telescope-default-keys.md
