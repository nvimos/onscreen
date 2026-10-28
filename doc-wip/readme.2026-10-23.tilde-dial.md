# `~` toggles and dial.nvim (idea 29a)

## `~` (lua/genja/ext/tilde.lua, key in lua/genja/map-zero.lua)

- On a word in the list, `~` swaps it: true/false, on/off, yes/no,
  enable/disable, enabled/disabled, and/or, 0/1, left/right, up/down,
  min/max, first/last. Case is kept: `True` -> `False`, `ON` -> `OFF`.
- On `+` `-` `<` `>`: swaps the char (`<=` -> `>=`).
- Anything else, or with a count (`3~`): plain `~`.
- `<M-~>`: plain `~` always.
- Alma's `TildeToggleUnderCursor` only swapped words after `=`; this one
  swaps them anywhere.

## dial.nvim (lua/lazyp/new/dial.lua, keys in lua/genja/map-plugin/dial.lua)

- `<C-a>`/`<C-x>` increment/decrement what's under or after the cursor.
- Default group: integers, hex, `%Y-%m-%d` dates, `%H:%M`, true/false,
  semver, weekdays, months, first…tenth, `&&`/`||`, and/or, on/off, yes/no.
- Per filetype on top: lua `==`/`~=`; ts/js `let`/`const`, `===`/`!==`; go
  `==`/`!=`; php `===`/`!==`, public/protected/private; css hex colors;
  markdown headers (`#` -> `##`) and `[ ]`/`[x]`.
- `vim.b.dial_group = 'markdown'` forces a group in a buffer.
- `g<C-a>` in visual mode: 1 2 3 … down the selection.
- Groups modeled on LazyVim's dial extra (`dials_by_ft`).
- Smoke-tested headless: 5 -> 6, a date, Monday, lua `==`, md header,
  md checkbox, semver.

## Test

1. `x = true`, cursor on `true`, `~`: `false`. `~` again: `true`.
2. `True`, `ON`: case kept.
3. `a <= b` on `<`: `a >= b`.
4. `hello` on `h`: `Hello` (plain ~). `3~` on `true`: `TRU`… plain.
5. `<M-~>` on `true`: `True`.
6. `<C-a>` on `2026-10-23`: next day; on `Monday`: Tuesday.
7. In a markdown file: `<C-a>` on `- [ ]` -> `- [x]`; on `# h` -> `## h`.
8. Select five lines of `0`, `g<C-a>`: 1 2 3 4 5.
9. Lua `a == b`, cursor on `==`, `<C-a>`: `~=`.
