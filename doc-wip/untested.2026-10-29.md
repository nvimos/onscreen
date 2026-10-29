# Untested, 2026-10-29

One feature per question in the guided session. Earlier lists: doc-wip/untested.2026-10-23.md.

- [ ] dropbar crumb letters: <leader>; then j w f a s … pick a crumb (lua/lazyp/ui/dropbar.lua) -> todo-done/ideas-52-dropbar-letters.md
- [ ] telescope key help: open a picker, type until no result: key table in the results (lua/genja/ext/telescope-virthelp.lua) -> todo-done/ideas-53-telescope-explore.md
- [ ] telescope default keys: uncomment one in after/plugin/telescope-after.lua, check it's off (A1) -> doc-wip/readme.2026-10-26.telescope-default-keys.md
- [ ] unsaved picker: :qa with a modified file and a no-name buffer, <M-x> / <M-w> (lua/genja/ext/unsaved.lua) -> doc-wip/readme.2026-10-29.unsaved-picker.md
- [ ] unsaved picker with s:: picker, then session saved to ~/tmp/viss (lua/genja/abbreviations.vim) -> doc-wip/readme.2026-10-29.unsaved-picker.md
- [ ] paste search: :Xty and :Wot; current provider unchanged after :Google (plug-wip/genja-paste-ai.nvim/plugin/genja-paste-ai.lua) -> todo-issue/solved-26.10.29-22.59-paste-commands.md
- [ ] paste search providers: each new one once, yandex, claude, google-ai, kagi … (plug-wip/genja-paste-ai.nvim/lua/genja-paste-ai/init.lua) -> todo-issue/solved-26.10.29-22.49-paste-providers.md
- [x] which-key height: <leader> then a group key, the box keeps its edges (lua/lazyp/my/which-key.lua) -> todo-issue/solved-26.10.29-22.59-which-key-height.md (works, 2026-10-30)
- [x] which-key groups: new group names show (lua/lazyp/my/which-key.lua) -> todo-issue/solved-26.10.29-22.49-which-key-groups.md (works, 2026-10-30)
- [x] mylunsj size: opens at 80 x 15 (lua/telescope/_extensions/mylunsj.lua) -> todo-issue/solved-26.10.29-22.49-legendary-size.md (works, 2026-10-30)
- [ ] older features (lint waves, genja-commit, startdirs, recent, ask popup …): see doc-wip/untested.2026-10-23.md
