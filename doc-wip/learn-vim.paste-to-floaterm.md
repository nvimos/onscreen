# Pasting into a floaterm

A floaterm (vim-floaterm) is a terminal buffer, so there are a few ways to paste into it.

## 1. System clipboard (simplest)

Use your terminal app's own paste shortcut while the floaterm is focused: `Ctrl+Shift+V`, or `Ctrl+V` / right-click in Windows Terminal.

## 2. Paste a Vim register

- Press `Ctrl+\` then `Ctrl+N` to leave terminal mode
- Press `p` for the unnamed register, or `"+p` for the clipboard
- Press `i` to go back to typing

In a terminal buffer, `p` sends the text to the running program as input.

## 3. Make `Ctrl+R` work like it does in insert mode

Add to your config:

```lua
vim.keymap.set('t', '<C-r>', function()
  return '<C-\\><C-n>"' .. vim.fn.nr2char(vim.fn.getchar()) .. 'pi'
end, { expr = true })
```

Then in the floaterm, `Ctrl+R +` pastes the clipboard and `Ctrl+R "` pastes the last yank.

## 4. Send lines from a buffer

Visually select lines in a normal buffer and run `:FloatermSend`. This sends them to the floaterm, which is handy for running code in a REPL.
