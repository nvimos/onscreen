# :Messages and F2: jump from errors in :messages to file:line

What: Lua tracebacks (`C:/…/x.lua:42:`, also shortened `...ocal/nvim/lua/genja/x.lua:42:`)
and Vim script errors (`Error detected while processing <file>:` + `line 12:`) in `:messages`
become jump targets. Nothing runs in the background: `:messages` is read when you ask.

Files: `lua/genja/messages.lua`, `plugin/messages.lua` (`:Messages`), F2 source
`lua/genja/f2/messages.lua`. Not active: `lua/genja/messages-capture.lua`.
Tests: `tests/messages/test_messages.lua` (`make test D=messages` in `tests/`).

## Commands and keys

| Command | Does |
|---------|------|
| `:Messages`, `:Messages -dump` | `:messages` in a scratch buffer in the current window; `<CR>` opens the file:line on the cursor line, `q` goes back |
| `:Messages -quick` | append every location to the quickfix list (title `:Messages`), `:copen` |
| `:Messages -loc` | the same into this window's location list, `:lopen` |
| `<F2>` -> `messages: lua/genja/x.lua:42` | the newest 10 locations; picking one opens it |

## -dump vs the old :DumpMessages (lua/genja/auto-alias.vim, left as is)

- The old one ran `setlocal buftype=nofile …` after the first `enew`, then `enew` again: the
  messages landed in a second, normal buffer, so `:q` stopped with "No write since last change".
- `-dump` makes one unlisted scratch buffer (`nofile`, `bufhidden=wipe`, no swap file), named
  `messages://<n>`, `filetype=messages`, cursor on the newest line, `<CR>` and `q` mapped.
- More ideas for it: `:Messages -dump` in a split (`:vert Messages` doesn't pass mods yet);
  a `syntax` for `E\d\+:` lines; `:messages clear` from the dump buffer (`dd`-like key).

## messages-capture.lua (off)

Wraps `vim.notify` and records WARN and up with a traceback taken where notify was called,
so messages without a path in their text still point at the code. `enable()`, `disable()`,
`entries()`, `to_qflist()`, `last()`, `count_by_source()`, `dump()`. Its header lists uses
(startup audit, noisy plugin finder, tests asserting no warnings) and how noice, nvim-notify,
snacks, scriptease, VS Code, Emacs and JetBrains keep message history.
Try: `:lua require('genja.messages-capture').enable()`.

## Test

1. `:lua error('x')`, then `:Messages`: the last line has `[string ":lua"]` (no file: nothing
   to open). Better: `:luafile` a file with `error("boom")` on line 2, `:Messages`, `<CR>` on its
   line: the file opens at line 2.
2. `:Messages -quick` twice: the items appear twice (appended), title `:Messages`.
3. `<F2>`: `messages: …/bad.lua:2` at the bottom; pick it.

Checked by Claude: `make test D=messages`: 10 cases, 0 fails; f2 tests 53/53.
