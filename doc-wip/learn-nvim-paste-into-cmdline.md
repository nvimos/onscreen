# Paste the + register into the : command line

In command-line mode, press `Ctrl-R` then `+`:

```
:<C-r>+
```

Variants:
- `<C-r><C-r>+` inserts the text literally, so control characters like `<C-h>` aren't interpreted as keys.
- `<C-r><C-o>+` also inserts literally.
- `:@+` runs the contents of `+` as an Ex command and doesn't put it on the command line.

Multi-line register contents show up as `^M` on the command line.
