# Zen toggles: switching, size memory, diagnostics limit

Keys in `lua/genja/map-plugin/zenmode.lua` (spec `lua/lazyp/ui/zenmode.lua`).

| Key | Does |
|-----|------|
| `<leader>z1` | zen width 120, no numbers, frameless; diagnostics limit 2 per severity |
| `<leader>z2` | zen width 80, relnum, colorcolumn 4,8,80, frameless + maximized |
| `<leader>z0` | close zen; frameless off, maximized off (if z2 set it), `&columns`/`&lines` and the diagnostics limit as before the first z1/z2 |
| `<leader>mz` | `:ZenMode` with the spec defaults (unchanged) |

- z1 <-> z2 while zen is open: zen closes and reopens, so the new width applies
  (`open()` on an open zen window kept the old one).
- The size is taken once, at the first z1/z2 after zen was off; z1 -> z2 -> z0 restores that.
- Maximized: z2 only; z1 after z2 un-maximizes.
- Diagnostics limit (lua/genja/ext/diag-limit.lua): z1 sets 2, z2 puts the earlier one back, z0 too.

## Test (nvim-qt)

1. Note the window size. `<leader>z1`: 120 wide, frameless; a file with errors shows 2 per severity.
2. `<leader>z2`: reopens at 80, relnum, maximized; diagnostics back to 3.
3. `<leader>z1`: 120 again, not maximized.
4. `<leader>z0`: framed, the size from step 1, diagnostics limit as before.

Open question: does setting `&columns`/`&lines` resize the nvim-qt window, or only the grid?
If only the grid, z0 needs `GuiWindowMaximized`/a GUI resize call instead.

Checked by Claude: loadfile; map-plugin tests (zenmode keys register) 10/10. Not run in nvim-qt.
