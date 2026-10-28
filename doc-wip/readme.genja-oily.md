# genja-oily.nvim: .oily moved into its own plugin

The `.oily` code now lives in its own plugin, `plug-wip/genja-oily.nvim`,
with the new lookup: every folder oil shows is searched for `.oily`, then its
parents up to the drive root, stopping at the first one found. Not run or
tested yet (2026-10-18).

## How it behaves now

- A `.oily` covers the folder it's in and every folder below it. Bare names
  and name globs hide entries anywhere below; paths and path globs are
  relative to the folder holding the `.oily`.
- Rules don't add up: a closer `.oily` replaces one further up.
- The search runs again each time oil shows a folder, including a refresh. A
  newly created or deleted `.oily` takes effect on the next visit.
- `<LocalLeader>M` (also in the `g.` menu) appends the entry to the `.oily`
  that applies to the current folder. If there's none, it creates one in
  `:pwd` when the folder is inside `:pwd`, otherwise in the folder itself.

## Files

- `plug-wip/genja-oily.nvim/`: the code (`lua/genja-oily/init.lua`),
  README, help file (`:help genja-oily`) and CLAUDE.md.
- `lua/lazyp/new/genja-oily.lua`: loader spec. It loads the first time oil
  needs it, like genja-finder.
- `lua/lazyp/explorer/oil.lua`: oil's hidden-file check and `<LocalLeader>M`
  call genja-oily. The `g.` menu entry in `lua/genja/ext/actions.lua` does the same.
- `lua/genja/fn-oil.lua`: the old `.oily` code is gone, replaced by a
  one-line pointer.
- Pointers elsewhere:
  - the `.oily` section in `lua/genja/readme.md` points to the plugin
  - a line in the root CLAUDE.md's plugin list
  - a `START_DIRS` entry in `lua/genja/init.lua`

## Decisions not specified by jaro

Marked as inferred in the plugin's CLAUDE.md, to confirm or change:

- A first version re-checked on entering an oil buffer. Dropped because oil
  may draw the folder before or after that event fires. Now a folder's lookup
  result is kept for 500 ms, so it runs once per oil redraw.
- The "no `.oily` found" case falls back to `:pwd`, as before.

## To test

1. Put `.oily` with `node_modules` in a parent folder.
2. Open oil two levels below it: `node_modules` should be hidden there.
3. Add a `.oily` in the child folder: the parent's rules should no longer
   apply there.
4. `<LocalLeader>M` on an entry should append its path to the nearest `.oily`.
