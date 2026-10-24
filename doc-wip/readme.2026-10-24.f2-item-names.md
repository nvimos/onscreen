# F2 item names: less noise

What: the `<F2>` lists show labels lower case, without `« » ' " ! ` [ ]`, with single
spaces; `group: label` and parens stay. The labels themselves got shorter, and the main
list no longer ends items in `(~/path)`.

Files: `lua/genja/f2/picker.lua` (`clean()`, used for every row and group), labels in
`f2/claude.lua`, `f2/gui.lua`, `f2/adhoc.lua`, `f2/make.lua`, `lua/genja/md-checklist.lua`,
`lua/genja/md-glow.lua`. Tests: `tests/f2/test_picker.lua`, `test_adhoc.lua`.

## Before / after

| Before | After |
|--------|-------|
| `claude: claude-ft «fix the tabline»  (~/AppData/Local/nvim)` | `claude: fix the tabline` (no title: the root's name) |
| `Gui: Funcs: frame, full, scroll` | `gui: funcs frame full scroll` |
| `adhoc: go mod init foo  (~/src/foo)` | `adhoc: go mod init foo` |
| `make: targets (12)  (nvim)` | `make: targets in nvim (12)` |
| `markdown: checklist: add/remove [ ] (selection or line)` | `markdown: checklist toggle` |
| `markdown: preview: glow in a new terminal` | `markdown: glow preview` |

Tasks added with `f2.add_task()` from elsewhere go through the same filter; the
registry still matches on the label as written.

## Test

1. A markdown file, `<F2>`: `markdown: checklist toggle`, `markdown: glow preview`.
2. With a claude terminal running: `claude: <title or project name>`.
3. In nvim-qt: `gui: funcs frame full scroll`.
4. In this repo: `make: targets in nvim (…)`.

Checked by Claude: `make test` in `lua/genja/f2/`: 53 cases, 0 fails.
