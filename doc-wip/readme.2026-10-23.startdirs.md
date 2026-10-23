# Start dirs plugin (idea 36)

Docs live in the plugin: `plug-wip/genja-startdirs.nvim/README.md`,
`doc/genja-startdirs.txt`, `CLAUDE.md`. Config side: spec
`lua/lazyp/new/genja-startdirs.lua`, keys
`lua/genja/map-plugin/genja-startdirs.lua`, oil `,s`/`,S` in
`lua/genja/map-oil.lua` + `oil-actions.lua`, the list in
`lua/genja/local/startdirs.txt` (gitignored, moved from `START_DIRS`).

## What changed

- The `START_DIRS` global in `lua/genja/init.lua` is gone. mydirs,
  `<leader>jd` find and `:CycleDirs` call the plugin.
- The machine switches (`oni`, `fonv`, `openmw`, `movies`) are `[group]`
  sections in the file and `opts.groups` in the spec; `windows` is a
  function (`has('win32')`).
- mydirs now lists by use count (most used first) and counts each `<CR>`.
- `<leader>sp` (sort paragraph) and `<leader>sf` (guifont) are commented
  out in `map-convoluted.lua`; `<F7>` still sets the font.

## Keys

| Key | |
|---|---|
| `<leader>sp`, `<leader>jD`, `<S-F3>` | picker (mydirs), most used first |
| `<leader>sa`, `<leader>jA` | add the current dir (oil's, the file's, else cwd) under `[added]` |
| `<leader>sr` | remove the current dir |
| `<leader>se`, `<leader>je`, `:StartdirsEdit` | edit the list |
| `<M-1>` … `<M-4>` | cd + open the first four entries |
| `,s` / `,S` in oil | add / remove the dir under the cursor (else oil's dir), `[oil]` |

Headless checks: the real file gives 18 dirs; add/remove/duplicate,
group switches, `CONFIG/`/`DATA/`/`HOME/` expansion and compaction,
`oil:///C/…` normalization, ranking.

## Test

1. `<leader>sp`: picker lists the dirs; pick one: cd + oil opens it.
2. `<leader>sp` again: the dir picked before is now first.
3. `<M-1>`: `finn-appartment` opens; `<M-4>`: `_setup.bauss`.
4. In oil on a folder line, `,s`: notice `added … [oil]`; `<leader>se`
   shows it under `[oil]`, with `HOME/…` if it's under home.
5. Same line, `,S`: removed.
6. `<leader>sa` in a file buffer: its dir is added under `[added]`.
7. In the spec, set `fonv = true`, restart: the Fallout dirs show (if they
   exist).
8. `<leader>jd`: find files across all start dirs.
9. `:CycleDirs` still cycles.
10. `<leader>s` in which-key: group `Dirs: start dirs`; no sort/font keys.
