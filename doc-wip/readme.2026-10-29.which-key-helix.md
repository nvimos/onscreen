# which-key: helix layout

which-key opens as one narrow column in the bottom right, one key per line,
instead of the classic multi-column strip at the bottom.

File: `lua/lazyp/my/which-key.lua` (`preset = 'helix'`).

## Other layouts to try

Two commented-out lines under the preset:

- `preset = 'modern'`: centred float with a border, several columns.
- `preset = 'classic', layout = { width = { min = 20, max = 40 }, spacing = 2 }`: the old layout with narrower columns.

Swap the active line, then restart nvim.

## Test

1. Restart nvim, press `<leader>` and wait: a single column opens bottom right.
2. `<leader>j`: the `Jump` keys list top to bottom, groups first.
3. `<F2>` / `<F3>` scroll the list when it is longer than the window.
