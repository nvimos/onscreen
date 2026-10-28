# Telescope keymaps: refine keys and desc groups (#26b)

What: telescope's keymaps picker with genja-finder's refine keys and a key
that shows one description group at a time (`Git:`, `LSP:`, `Fold:` ...).

Files: `lua/genja/ext/telescope-keymaps.lua`, keys in `lua/genja/map-telescope.lua`
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
- The groups come from the list shown when a cycle starts: after `<M-f>`/`<M-x>`, `<M-r>` cycles
  the groups of the refined list (fixed 2026-10-24: it went back to the full list).
  `<BS>` back to a group view continues that view's cycle. The group stays in the title: `[Git: 1/9] [filter]`.
- Modes: telescope's default `n, i, c, x`.

## Try it

1. `<leader>jM`: the keymaps list opens.
2. `<M-r>`: only one group shows (the biggest), the title names it.
3. `<M-r>` again: the next group. `<M-R>`: back one.
4. Keep pressing `<M-r>` past the last group: all keymaps again, title plain.
5. On a group, type `hunk`, `<M-f>`, then type `stage`: filtered within the group.
6. `<BS>` on the empty prompt: the filter is undone.
7. `<M-x>` with `oil` typed: entries with "oil" disappear.

Unit tests: `make test D=telescope-keymaps` in `tests/` (`tests/telescope-keymaps/test_keymaps.lua`,
10 cases, real keys in a child nvim with telescope). Steps 1-4, 6 also tested by hand.
