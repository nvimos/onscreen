# Telescope: default keys to switch off, and named keys in `<C-/>`

## What it does

Nothing changes until you uncomment something. Telescope's default picker keys are listed, one
per line and commented out, in two places:

- **Every picker (A1):** `after/plugin/telescope-after.lua`, in `mappings.i` and `mappings.n`:
  `-- ['<C-x>'] = false, -- select_horizontal`. Uncommented, the key is gone in every picker,
  extensions included.
- **Only pickers with your shared keys (A2):** `lua/lazyp/new/genja-finder.lua`, option `unmap`:
  `-- { 'i', '<C-x>' }, -- select_horizontal`. Uncommented, the key is gone in pickers that get
  genja-finder's `attach_shared_keys` (enhanced builtins, F2 pickers, ui-select, mylunsj); other
  pickers keep it. genja-finder maps the key to `false`, which telescope reads as "taken" and
  skips its default.

The comment after each line names telescope's action. Lines marked "map-telescope sets it",
"Telemap sets it" or "refine uses it" are keys you have your own mapping for already.

`<C-/>` (insert) and `?` (normal) still open telescope's key list. Your loclist and quickfix keys
now have descs (`lua/genja/map-telescope.lua`), so the list shows `Telescope: all to quickfix`,
`Telescope: marked to loclist`, ... instead of `send_to_qflist + open_qflist`. Telemap and refine
keys already had descs.

## Try it

1. `<leader>jb…` (any builtin) or `<F1>`, then `<C-/>`: your keys show with their descs.
2. In `after/plugin/telescope-after.lua`, uncomment `-- ['<C-x>'] = false,` under `i`, restart,
   open a picker: `<C-x>` does nothing; `<C-/>` no longer lists it.
3. Comment it again. In `lua/lazyp/new/genja-finder.lua`, uncomment `-- { 'i', '<C-x>' },`,
   restart: `<C-x>` is gone in an F2 picker, still there in `:Telescope help_tags`.

Checked by Claude (headless): the key list shows the new descs; with `unmap = { { 'i', '<C-x>' } }`
an enhanced picker has no `<C-x>`.
