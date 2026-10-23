# Tabline: resizing nvim-qt walked to the last tab (idea 32)

Docs in the plugin: `plug-wip/genja-statusline.nvim/README.md` (tabline
note) and `doc/genja-statusline.txt`.

## Cause (likely, not confirmed by hand)

- `ginit.vim` calls `GuiWindowFrameless(1)`: nvim-qt draws no frame, so
  dragging the top edge to resize sends mouse events into nvim, on row 0,
  the tabline.
- `:h tabpage`: "Click where there is no label to go to the next tabpage";
  a double click opens a new tab.
- `tabline.lua` had no click region on the left edge (triangle) and the
  empty fill after the labels, so each drag event went one tab further.

## Fix

- `autoload/genja_statusline.vim`: `genja_statusline#noop`, a click
  handler that does nothing, set with `%@genja_statusline#noop@` on the
  left edge and the fill area. Labels (`%NT`), the per-tab window-count
  close buttons (`%NX`) and the close-all at the right (`%999X`) keep
  working.

## Test

1. nvim-qt with 3+ tabs, on the first tab.
2. Resize the window from the top edge and the top corners: the tab stays.
3. Click the empty tabline area right of the labels: nothing happens.
   Double-click there: no new tab.
4. Click a tab label: switches. Click a label's window count: closes that
   tab. The icon at the far right closes the current tab.
5. If tabs still change on resize: set `GuiWindowFrameless(0)` in
   `ginit.vim` and resize again, then report which edge triggers it.
