# Telescope keymaps: refine keys and desc groups (#26b)

What: telescope's keymaps picker with genja-finder's refine keys and a key
that shows one description group at a time (`Git:`, `LSP:`, `Fold:` ...).

Files: `lua/genja/telescope-keymaps.lua`, keys in `lua/genja/map-telescope.lua`
(function in `map-telescope/fn.lua`).

## Keys

| Key | Where | Does |
|-----|-------|------|
| `<leader>jM`, `<leader>jbk`, `<leader>jb?` | normal | open the picker |
| `<M-r>` / `<M-R>` | picker | next / previous desc group; after the last: all |
| `<M-f>` | picker | freeze the list and filter within it |
| `<M-x>` | picker | drop entries containing the typed words |
| `<M-n>` | picker | fuzzy / exact |
| `<BS>` on empty prompt | picker | undo the last `<M-f>`/`<M-x>` |

- Groups come from the text before `: ` in each desc, biggest group first.
  The prompt title shows `Keymaps [Git: 1/14]`.
- The groups are taken from the list as it was at the first `<M-r>`.
- Modes: telescope's default `n, i, c, x`.

## Try it

1. `<leader>jM`: the keymaps list opens.
2. `<M-r>`: only one group shows (the biggest), the title names it.
3. `<M-r>` again: the next group. `<M-R>`: back one.
4. Keep pressing `<M-r>` past the last group: all keymaps again, title plain.
5. On a group, type `hunk`, `<M-f>`, then type `stage`: filtered within the group.
6. `<BS>` on the empty prompt: the filter is undone.
7. `<M-x>` with `oil` typed: entries with "oil" disappear.

Checked by Claude: headless `loadfile` of the three files. Not run in a
real nvim.
