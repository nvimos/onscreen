# Right-click entry for the `g.` menu (idea 17b)

`lua/genja/fn.vim` adds `Actions (g.)` to the mouse popup menu (`PopUp`),
next to `ToggleWrap`. It opens the same picker as `g.` /
`<LocalLeader>/` (`lua/genja/actions.lua`).

New actions in the menu: `source this file` (lua and vim buffers) and
`claude (floaterm)` (`:ClaudeFterm`).

Mouse in telescope: built in. With `mouse=a`, a click selects an entry,
a double-click runs it (telescope's default `<LeftMouse>` /
`<2-LeftMouse>` maps). The scroll wheel scrolls the results.

## Test

1. Right-click in a Lua buffer: `Actions (g.)` is at the end of the menu.
2. Pick it: the Actions picker opens.
3. Click an entry once (selected), double-click it (runs).
4. In the picker, type `source`: `source this file` shows in lua/vim
   buffers only; run it on a small file.
5. `claude (floaterm)` opens the claude split (`:ClaudeFterm`).
6. In oil, right-click: `Actions (g.)` shows oil entry items.
