# Find where a command, map or option is defined

## :verbose

```vim
:verbose command Buffers
```

Prints the definition and `Last set from <file> line N`.

- Vimscript definitions show the file and line directly.
- Lua definitions (`nvim_create_user_command`) often show only `Last set from Lua`.
  Neovim records Lua locations only when `'verbose'` was on at definition time:

  ```
  nvim -V1
  :verbose command Buffers
  ```

- Lazy-loaded (`cmd` trigger): before first use the command is a lazy.nvim stub,
  so `:verbose` points to lazy.nvim. Run the command once, then ask again.

Same trick for other things:

```vim
:verbose map <key>
:verbose set {option}?
:verbose autocmd {event}
:verbose function {name}
```

## List by name

```vim
:command Buf
:filter /Buffers/ command
```

## Search the files

```
rg -n "Buffers" %LOCALAPPDATA%\nvim %LOCALAPPDATA%\nvim-data --glob "*.{lua,vim}"
```

Look for `command! ... Buffers` (Vimscript) or `nvim_create_user_command('Buffers'` (Lua).
