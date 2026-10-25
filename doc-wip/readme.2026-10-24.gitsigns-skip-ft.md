# gitsigns: off in markdown, `<leader>mGs` toggles per buffer

What: gitsigns doesn't attach to the filetypes in `vim.g.gitsigns_skip_ft`
(default `{ 'markdown' }`): no signs, no `<leader>h…` hunk keys there.
`<leader>mGs` attaches or detaches the current buffer, in any filetype.

Files: `lua/genja/map-plugin/gitsigns.lua` (`on_attach` returns false for
skipped filetypes; `toggle_attach()`), which-key `<leader>mG` group, cheatsheet Git.

## How it works

- `on_attach` runs on every attach attempt. It returns false (gitsigns stays off) when
  `b:gitsigns_force` is false, or when it is unset and the filetype is in the list.
- `<leader>mGs` on an attached buffer: detach, `b:gitsigns_force = false`
  (stays off, also after `:e`). On a detached one: `b:gitsigns_force = true`, attach.
- "Attached" means gitsigns has the buffer in its cache (`gitsigns.cache`). Not
  `b:gitsigns_status_dict`: gitsigns sets it before `on_attach`, also on skipped buffers
  (the first version checked it, so `<leader>mGs` never attached; fixed 2026-10-25).
- More filetypes: `vim.g.gitsigns_skip_ft = { 'markdown', 'text' }` before gitsigns
  loads (it loads on VeryLazy), e.g. in `lua/genja/opt.lua`.

## Test

1. Open a tracked `.md` file with changes: no signs in the sign column; `]c` is nvim's.
2. `<leader>mGs`: signs appear, `]c` jumps to hunks; `<leader>mGs` again: gone.
3. A `.lua` file: signs as before; `<leader>mGs` turns them off for that buffer only.

Checked by Claude: loadfile of the changed files; gitsigns' `on_attach() == false`
check (attach.lua:388) and `attach`/`detach` exist. Not run in a real nvim.
