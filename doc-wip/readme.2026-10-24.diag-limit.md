# Diagnostics: first 3 per severity

What: in each buffer, only the first 3 errors, the first 3 warnings, the first 3 infos and
the first 3 hints (by line, then column, LSP and linters together) get virtual text, a sign
and an underline. The rest still exist: `]d`, the loclist, floats and `vim.diagnostic.get()`
see all of them.

Files: `lua/genja/ext/diag-limit.lua` (wraps nvim's `virtual_text`, `signs`, `underline` handlers),
`plugin/diag-limit.lua` (setup, key), F2 source `lua/genja/f2/diag.lua`.
Tests: `tests/diag-limit/test_diag_limit.lua` (`make test D=diag-limit` in `tests/`).

## Keys and settings

| Key / setting | Does |
|---------------|------|
| `<leader>tt3` | limit on (3) / off (all) |
| `<F2>` -> `diag  show all (N hidden)` | this buffer shows all; others keep the limit |
| `<F2>` -> `diag  hide excess (N over 3 per severity)` | after show all: this buffer follows the limit again |
| `vim.g.diag_limit = n` | per severity, all buffers; `0`: all |
| `vim.b.diag_limit = n` | one buffer, wins over the global one |
| zen `<leader>z1` | sets 2, `<leader>z0` puts the old value back |

## Test

1. A Lua file with 5 undefined globals: virtual text on the first 3 only; `]d` still visits all 5.
2. `<F2>`: `diag  show all (2 hidden)`; pick it: all 5 drawn here.
   `<F2>` again: `diag  hide excess (2 over 3 per severity)`; pick it: back to 3.
   Sample files: `plug-wip/genja-completion011.nvim/test-files/seven-errors.{lua,md,sh}`.
3. `<leader>tt3`: all drawn everywhere; again: back to 3.

Checked by Claude: `make test D=diag-limit`: 8 cases, 0 fails (extmarks of the real handlers);
not run after adding hide excess (9 cases).
Not tried in a real nvim with an LSP.
