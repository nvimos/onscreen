# Markdown: fixers, fix on save, abbreviations

What: three ways to fix markdown mistakes.

| How | Does |
|-----|------|
| `<leader>mfx` | `:update`, then `typos --write-changes` and `markdownlint-cli2 --fix` on the file; the buffer reloads (view kept) |
| on `:w` | the same, unless `vim.g.md_fix_on_save = false` |
| insert mode | abbreviations from `lua/genja/md-abbrev.txt`: `teh` + space -> `the` |

Files: `lua/genja/md-fix.lua`, `lua/genja/md-abbrev.lua`, `lua/genja/md-abbrev.txt`,
set up per buffer in `after/ftplugin/markdown.lua`. Tests: `tests/md/test_md_fix.lua`
(`make test D=md` in `tests/`). markdownlint: the project's config, else `lint/.markdownlint.jsonc`.

## Your list

`lua/genja/md-abbrev.txt`: one `wrong right` pair per line, `right` may have spaces,
`#` comments. Read when a markdown buffer opens: `:e` an open one to pick up edits.
Abbreviations also fire inside code blocks; drop a pair if that bites.

## ft settings check (after/ftplugin/markdown.vim) — suggestions, nothing changed

Now: `wrap`, `conceallevel=1`, `showbreak=NONE`, `j`/`k` -> `gj`/`gk`.

1. `setlocal linebreak breakindent`: with `wrap` alone, long lines break mid-word.
2. `setlocal spell spelllang=en`: typos catches common typos only; spell marks unknown words
   (your `<leader><space>s` group has the spell keys).
3. `setlocal formatoptions+=nro comments=b:-,b:*,b:+,n:>`: `o` / `<CR>` continue `- ` lists and
   `> ` quotes; `n` formats numbered lists with `gq`.
4. `setlocal textwidth=0`: keeps `gq` from hard-wrapping when a global `textwidth` is set.
5. `conceallevel=2` hides link targets as well (`[text](url)` -> `text`); 1 only hides markers.

## Test

1. A `.md` file: type `teh ` -> `the `.
2. Write `This is teh text.` and a `#Heading` (no space), `:w`: both fixed, cursor stays.
3. `:let g:md_fix_on_save = v:false`, break it again, `:w`: stays; `<leader>mfx`: fixed.

Checked by Claude: `make test D=md`: 7 cases, 0 fails (one runs the real typos).
