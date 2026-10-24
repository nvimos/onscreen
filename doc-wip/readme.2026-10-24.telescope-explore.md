# Telescope: usability exploration (spec, open questions) + key footer prototype

From todo-ideas.md "telescope": remove predefined keys except your own, check whether
`<C-/>` is good for discovery, a more elaborate layout (always-on key footer, or a
preview-like panel with hand-picked keys).

## Prototype built: key footer

`lua/genja/telescope-footer.lua`, hooked in `plugin/telescope-footer.lua` (FileType
`TelescopePrompt`, so every picker gets it). One line on the results window's bottom border:
the prompt's insert-mode keys whose desc reads `Area: what` (the config's convention), e.g.

    <M-f> filter the listed results · <M-n> switch between fuzzy and exact match · <M-x> exclude entries …

- telescope's own maps (desc = action name, `move_selection_next`) are left out; `<C-/>` shows them.
- `<BS>` and `<Esc>` are left out (known, long descs).
- Off: `vim.g.telescope_footer = false`, or `:TelescopeFooter` toggles for the next pickers.
- Tests: `tests/telescope-footer/test_footer.lua`.

Try: `<leader>jM` (keymaps: `<M-r>` group keys show too), `<F1>` live grep, `<C-F1>` recent files.

## What exists today

- Shared keys: `Telemap` (`<Esc>`, `<F2>`/`<F3>`) and the refine keys (`<M-f>`, `<M-x>`, `<M-n>`, `<BS>`)
  via genja-finder's `attach_shared_keys(map)` / `enhance(picker)`.
- telescope's defaults are all still mapped (`<C-x>`, `<C-v>`, `<C-t>`, `<C-u>`/`<C-d>`, `<C-q>`, `<M-q>`,
  `<Tab>`, `<C-/>` / `?` which_key, …); `after/plugin/telescope-after.lua` adds a few.
- `<C-/>` (insert) / `?` (normal) open telescope's which_key float: every map with its action
  name, keys that aren't actions show as `<anonymous>`-like names; our descs are not used there.

## Options

### A. Remove the predefined keys
1. Global: `defaults.mappings = { i = { ['<C-x>'] = false, … } }` in the telescope spec: one list,
   applies to every picker, extensions included.
2. Decorator: `attach_shared_keys(map)` unmaps the defaults per picker: only the wrapped pickers.
3. Keep the defaults, only hide them from the footer (what the prototype does now).

### B. Discovery
1. Keep `<C-/>`; teach it our descs: telescope's which_key reads `mapping.desc`? (check: it shows
   the action name; a `desc` on `map()` may already be used in newer telescope).
2. The footer (prototype), one line, picks `Area: what` descs.
3. A toggleable panel (like a preview window) with 2–3 columns of keys + descs, `<M-?>` toggles.

### C. Layout
1. ivy bottom pane everywhere (genja-finder already uses it), footer on the results border.
2. dropdown for small lists (F2, ui-select), footer only when ≥ 3 own keys.
3. A custom layout_strategy with a reserved key row (no overlay on the border).

## Questions (one per answer)

1. Footer: keep it on by default, or only after `<M-?>`?
2. Which keys belong in it: only ours (`Area: what` descs), or also a few telescope ones
   (`<C-q>` send to quickfix, `<Tab>` mark, `<C-v>` vsplit)?
3. Remove telescope defaults: global list (A1), per wrapped picker (A2), or not at all (A3)?
   Which ones do you actually use?
4. When the footer is wider than the window: cut with `…` (now), wrap to 2 lines, or rotate?
5. Does `<C-/>` stay as the full list, or should it open our own list (with descs) instead?
6. Footer on the border (overlay) or a separate row (custom layout, C3)?

Checked by Claude: `make dir D=telescope-footer` (see the commit). Not looked at in nvim-qt.
