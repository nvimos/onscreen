# md-fix busy mark in the statusline (2026-11-10)

What: while typos and markdownlint-cli2 rewrite a markdown file (`<leader>mfx`, or after `:w` with fix on save),
the statusline shows `md-fix…` in the warning colour at the start of its right half.
Where: `lua/genja/ext/md-fix.lua` (`M.status`), passed to genja-statusline's new `statusline_extra` option
in `lua/lazyp/new/genja-statusline.lua` (plugin commit genja-statusline eed8864).

- A fixer that fails to start is reported and skipped; the mark still goes away.
- The mark is for the current buffer (one global statusline).

## Test

1. Open a long markdown file, `:w` (fix on save on: `<leader>tm` toggles it).
2. Right after the write: `md-fix…` before the git branch; it goes when the buffer reloads.
3. `<leader>mfx`: the same.
4. Turn fix on save off, `:w`: no mark.
