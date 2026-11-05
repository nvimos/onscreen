# Done 2026-11-05 (from todo-ideas.md)

- [x] aerial: outline sidebar on demand, follows the file shown in the source window
  - 2026-11-05: already works (attach_mode global, opens only on the keys); tests/ui/test_aerial_follow.lua proves it (auto-todo J)
  - open only on the key, not always, not for every file
  - open a different file in the window it describes: the sidebar reloads for that file, never shows the old one
  - today: lua/lazyp/ui/aerial.lua, attach_mode = 'global' (should already follow the current window),
    close_automatic_events = { 'unsupported' }; test if it really follows, also across tabs
