# colorcolumn on/off (2026-11-10)

What: switch the current window's colorcolumn off and back on. Off remembers the columns (`w:genja_colorcolumn`);
on brings them back, or 80 when there were none. Asked for during the zen z3 questions (z3 has no colorcolumn now).
Where: `lua/genja/ext/colorcolumn.lua`; key in `lua/genja/map-zero.lua`; F2 source `lua/genja/f2/collect/view.lua` (group `view`).

- `<leader>tC`   toggle (which-key: Toggle: colorcolumn (window))
- `<F2>` > `view  colorcolumn off (4,8,80)` / `view  colorcolumn on`

## Test

1. `<leader>z2` (colorcolumn 4,8,80), then `<leader>tC`: the columns go; again: 4,8,80 come back.
2. In a plain window `<leader>tC`: column 80.
3. `<F2>`, type `view`: the label shows on/off and the current columns.
