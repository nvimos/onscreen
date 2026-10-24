# F2 markdown: lines to checklist (idea 34)

`lua/genja/md-checklist.lua`, registered per markdown buffer from
`after/ftplugin/markdown.lua` with `f2.add_task('markdown', …):fn():buffer():add()`,
the first caller of the f2 task API (#18). Visual `<F2>` is new in
`lua/genja/map-telescope.lua`; it stores the selected lines in
`vim.b.f2_range` for tasks to read. Normal `<F2>` clears it.

## Use

- Select lines, `<F2>`, pick `markdown: checklist toggle`.
- Each non-blank line gets a box: `text` -> `- [ ] text`,
  `- item` -> `- [ ] item`, `* item` -> `* [ ] item`, `1. x` -> `1. [ ] x`.
  Indent is kept, blank lines are skipped, boxed lines stay.
- All lines boxed already: the boxes are removed (`- [x] a` -> `- a`).
  Plain text becomes a bullet after a round trip.
- Normal `<F2>`: the cursor line only.

## Test

1. Open a `.md` file with a few plain lines and a bullet list.
2. `Vjj<F2>`, pick the markdown task: boxes added.
3. Same selection, `<F2>` again, same task: boxes removed.
4. Normal mode on one line, `<F2>`: only that line.
5. In a `.lua` file, `<F2>`: no markdown task (per buffer).
6. Visual `<F2>` in a non-markdown file: picker opens as usual.
