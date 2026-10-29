# Test: which-key groups vs mappings

`tests/ui/test_which_groups.lua` boots the real config in a child nvim and compares
the which-key groups with the global mappings. It never fails; it lists what it
finds as notes after the summary.

1. Groups with no mapping under their prefix, in any mode.
   which-key's own labels for built-in keys (g, z, marks, registers) are left out.
2. `<leader>` prefixes with 2 or more mappings (n and x modes) that have no group
   and no mapping of their own. The count follows the prefix: `<Space>jb (10)`.

Buffer-local keys aren't seen (no file is open), so groups for LSP keys
(`<leader>c…`) show up as empty. Keys of plugins not loaded yet do count:
lazy.nvim maps stubs for them.

## Run

    cd tests
    make test D=ui

or only this file, from the config root:

    nvim --headless --noplugin -u tests/minimal_init.lua -c "lua MiniTest.run_file('tests/ui/test_which_groups.lua')"

## First run (2026-10-29)

- empty: `<Space>cA cG cW cc cd` (LSP, buffer-local), `<Space>mf`, `gS`
- no group: `<Space>A:`, `<Space>A=`, `<Space>T`, `<Space>bb`, `<Space>fml`, `<Space>g`, `<Space>jb`, `<Space>jj`

Groups for these go in `lua/lazyp/my/which-key.lua`.
