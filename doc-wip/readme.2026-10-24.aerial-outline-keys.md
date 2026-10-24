# Outline keys under `<leader>o` (aerial)

What: the aerial sidebar and nav float also sit under their own prefix, and the
nav float closes on `<Esc>` (before: `<C-c>` only).

Files: keys in `lua/genja/map-plugin/aerial.lua`, `<Esc>` in the spec
`lua/lazyp/ui/aerial.lua` (`opts.nav.keymaps`, merged into aerial's defaults),
which-key group `<leader>o` in `lua/lazyp/my/which-key.lua`.

## Keys

| Key | Does |
|-----|------|
| `<leader>oo`, `<leader>mo`, `<C-s>` | outline sidebar, cursor stays in the code |
| `<leader>oO`, `<leader>mO` | nav float (symbols left/right: `h` `l`, `<CR>` jumps) |
| `<Esc>` in the nav float | close it (also `<C-c>`) |

## Test

1. A Lua file, `<leader>`: which-key shows `o  Outline: sidebar, nav`.
2. `<leader>oo`: the sidebar opens on the right; again: it closes.
3. `<leader>oO`: the nav float opens; `<Esc>`: it closes.
4. `<leader>mO`, then `<Esc>`: same.

Checked by Claude: loadfile of the three files. Not run in a real nvim.
