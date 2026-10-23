# Window sizes (idea 28)

`lua/genja/winsize.lua`, keys in `lua/genja/map-zero.lua` (Windows block),
which-key group `<leader>W` in `lua/lazyp/my/which-key.lua`.

## Use

- `<M-=>` / `<M-->`: grow / shrink the current window by 10% of the
  screen. Side by side: width; stacked: height.
- `<M-0>`: cycle the share of the split: 50/50 → 30/70 → 70/30 → 60/40.
  Two windows: the left (or top) one gets the first number. Three or more:
  the current window gets it. The share shows in the message line.
- `<leader>wr`: resize mode. A which-key popup stays open; `h` narrower,
  `l` wider, `j` lower, `k` taller, `=` equal, `0` share cycle, `s` step
  percent/cells. `<Esc>` leaves.
- `<leader>Ws` or `require('genja.winsize').config.step = 'cells'`:
  fixed steps of 8 columns / 4 lines instead of 10%.
- Config: `require('genja.winsize').config` (`percent`, `cols`, `rows`,
  `shares`).
- smart-splits.nvim: spec with typed opts in `lua/lazyp/new/smart-splits.lua`,
  `enabled = false`. Enable to compare: `<M-h/j/k/l>` resize,
  `<leader>wR` its resize mode, `<leader>w<left>/<right>` swap buffers.

Headless check: share cycle on a 101-column vsplit gave 30/70, 70/30,
60/40; grow and taller worked.

## Test

1. `:vsplit`, `<M-0>` four times: 30/70, 70/30, 60/40, 50/50.
2. `<M-=>` three times: the window grows in big steps; `<M-->` back.
3. `:split` in one side, `<M-=>`: height grows (stacked).
4. `<leader>wr`, then `l l l h j k =`, `<Esc>`: popup stays until `<Esc>`.
5. `<leader>Ws`, `<M-=>`: steps of 8 columns now. `<leader>Ws` back.
6. Three windows side by side, `<M-0>` in the middle: the middle one gets
   30%, 70%, ….
