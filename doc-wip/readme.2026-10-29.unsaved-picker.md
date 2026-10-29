# Unsaved buffers picker (2026-10-29)

Quitting with modified buffers used to stop at E37/E162. Now a telescope
picker lists them first; once each one is written or discarded, the quit
(or session save) goes ahead.

Code: `lua/genja/ext/unsaved.lua`, command in `plugin/unsaved.lua`,
abbreviations in `lua/genja/abbreviations.vim`.

## Commands

- `:qa`, `jj`: picker if anything is modified, then `qa`.
- `s:`: picker, then the usual session sweep, `mksession ~/tmp/viss`, `qa`.
- `:qa!`: drops everything as before (no picker).
- `:Unsaved [cmd]`: the picker, then `cmd` (any Ex command, `|` allowed). No
  `cmd`: only the picker.

Nothing modified: `cmd` runs at once.

## Picker keys

| key     | file buffer                 | no-file buffer                                      |
|---------|-----------------------------|-----------------------------------------------------|
| `<M-w>` | `:write`                    | `:w ~/tmp/bufw-<week>-<3 words>.txt` on the cmdline |
| `<M-x>` | reset to disk (`:edit!`)    | wipe the buffer                                     |
| `<CR>`  | go to the buffer, no `cmd`  | same                                                |
| `<Esc>` | close, `cmd` cancelled      | same                                                |

After each `<M-w>`/`<M-x>` the picker reopens with what's left. For a no-file
buffer `<M-w>` shows the buffer and leaves the `:w` line for editing: Enter
writes and the picker comes back; `<Esc>` leaves it there (run `:qa` again).
`~/tmp` is created when missing. Week is the ISO week (`%V`); the three words
are the first word-like runs of the buffer, non-ASCII removed.

## Try it

1. `:e ~/foo.txt`, type something, don't save.
2. `:enew`, type `hello there world`, `:DumpMessages` or any other scratch text.
3. `:qa`: the picker lists `foo.txt` and `[No Name N] hello-there-world`.
4. On `foo.txt` press `<M-x>`: it's reset, the picker reopens with one entry.
5. On the no-name entry press `<M-w>`: the cmdline shows
   `:w ~/tmp/bufw-44-hello-there-world.txt`; press Enter.
6. The list is empty, nvim quits.
7. Again with `s:` instead of `:qa`: after the picker the session is saved to
   `~/tmp/viss` (restore with `j:`).
8. `:qa!` with modified buffers: quits without the picker.
