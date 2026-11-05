# aerial sidebar follows the file (2026-11-05)

auto-todo J. Nothing changed in the config: `lua/lazyp/ui/aerial.lua` has `attach_mode = 'global'`,
so the sidebar outlines whatever the current window shows, and it opens only on the keys.
New test: `tests/ui/test_aerial_follow.lua` (`make test D=ui` in tests/), passes.

## Keys (lua/genja/map-plugin/aerial.lua)

`<leader>mo`, `<leader>oo`, `<c-s>`: sidebar; `<leader>mO`, `<leader>oO`: nav float; `[o` `]o`: symbols.

## Test by hand

1. Open a Lua file, `<leader>oo`: the outline appears on the right, the cursor stays in the code.
2. `:e` another file in the same window: the outline switches to it.
3. A split with a third file, move between the windows: the outline follows the current one.
4. Another tab: the sidebar belongs to its tab; open it there with `<leader>oo`.
