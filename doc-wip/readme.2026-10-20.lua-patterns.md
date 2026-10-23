# How to look up Lua string patterns and substitution functions from nvim

Neovim ships the Lua 5.1 manual as `:help luaref`.

## Lua patterns and string functions

```vim
:h lua-pattern        " pattern syntax: %a %d %s . * + - ? [set] %b() %f[set], captures
:h lua-patternitem    " one pattern item, in detail
:h lua-lib-string     " the whole string library
:h string.gsub()      " substitute; the replacement can be a string, table or function
:h string.find()
:h string.match()
:h string.gmatch()
```

## Neovim helpers

```vim
:h vim.pesc()         " escape magic characters so a string matches literally
:h vim.gsplit()       " split by a pattern (or plain text, with {plain = true})
:h vim.regex()        " use a Vim regex from Lua instead of a Lua pattern
:h substitute()       " Vimscript substitute, call it as vim.fn.substitute()
```

## Tips

- Press `:h string.` then `<Tab>` (or `<C-d>`) to list every matching tag.
- `:Telescope help_tags` (`<leader>1`) searches tags with fuzzy matching, e.g. `lua-pat` or `gsub`.
- Lua patterns are not regex. They have no `|` for alternatives and no `{n}` repeat counts, and `-` means a lazy `*`. For alternatives, use `vim.regex()` or `vim.fn.substitute()`.
