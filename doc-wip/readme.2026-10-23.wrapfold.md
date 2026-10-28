# Fold markers with a title (idea 29b)

`lua/genja/ext/wrapfold.lua`, keys in `lua/genja/map-zero.lua` (Folds block),
`:WrapFold` set up from `lua/genja/init.lua`. Port of alma's `WrapFold`.

## Use

- Select lines, `zf`, type a title, `<CR>`: the selection is wrapped in
  `<comment> {{{ title` and `<comment> }}}`, indented like the first line.
  `commentstring` gives the comment (`/* {{{ x */` for C-style).
- Empty title: the built-in `zf` (`:fold`). `<Esc>` at the prompt: nothing.
- `<leader>wwf` in normal mode: same for the paragraph under the cursor.
- `:[range]WrapFold [title]`: no title asks.
- Normal-mode `zf{motion}` stays the built-in operator.
- The markers fold only with `foldmethod=marker`; otherwise a notice, once
  per buffer.

## Test

1. Open a Lua file, `:setl fdm=marker`.
2. `Vjj` then `zf`, type `test`, `<CR>`: lines `-- {{{ test` and `-- }}}`
   appear; `zc` closes the fold, the fold line shows `test`.
3. `Vj` `zf`, `<CR>` with an empty title: built-in fold markers (no title).
4. Cursor inside a paragraph, `<leader>wwf`, title `para`: the paragraph is
   wrapped.
5. In a `.c` file: `/* {{{ x */` / `/* }}} */`.
6. `:2,4WrapFold cmd`, then `:2,4WrapFold` (asks).
7. A file with `fdm=manual`: the notice shows once.
