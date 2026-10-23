# Ideas #12 and #17: telescope select and catch-all action menu

Status: implemented, untested (2026-10-17).

## #12 vim.ui.select in telescope

- File: `lua/genja/ui-select.lua`, loaded from `lua/genja/init.lua`
- Every `vim.ui.select` call opens a telescope dropdown
  - code actions
  - overseer's template list (`:OverseerRun`)
  - any other caller
- Telescope loads only when a list is shown
- `<Esc>` cancels: the caller gets "nothing picked" (`on_choice(nil)`)

## #17 action menu

- File: `lua/genja/actions.lua`
- Keys (in `lua/genja/map-telescope.lua`)
  - `g.`
  - `<LocalLeader>/` (`,/`)
- The list is built each time the menu opens, from what is available then
- `cur:` items: the item under the cursor, listed first
  - Language server (only what the attached server supports)
    - go to definition, declaration, implementation, type definition
    - references
    - rename
    - code actions
    - hover
    - signature help
    - incoming / outgoing calls
  - line diagnostics, if the cursor line has any
  - word under the cursor
    - grep for it
    - `:Inspect`
  - in oil, instead of the above
    - git add
    - unstage
    - diff preview
    - hide via `.oily`
- Unprefixed items: the buffer or wider
  - Language server, if one is attached
    - format buffer
    - document symbols
    - workspace symbols
    - toggle inlay hints
    - LSP health
  - Diagnostics
    - telescope list
    - send to quickfix
    - toggle
  - Pickers and tools
    - git commit (oil only)
    - `<F2>` make picker
    - find files, grep files (genja-finder)
    - recent files
    - keymaps
    - commands
    - help tags
  - syntax tree (`:InspectTree`), if the buffer has a treesitter parser
  - overseer task list

## Things to know

- Oil keeps `g.` as "toggle hidden files" (its buffer key wins); use `,/` there
- Rename has no `<F2>` anymore; it is `cur: rename` in the menu
- Both files are listed in `lua/genja/readme.md`

## To test

- Lua file with LuaLS attached, `g.` on a function call
  - `cur:` items come first
- Pick `cur: code actions`
  - the actions show in a telescope dropdown
- `:OverseerRun`
  - also a telescope dropdown
- Oil, `,/`
  - `cur: git add` and the other oil items
