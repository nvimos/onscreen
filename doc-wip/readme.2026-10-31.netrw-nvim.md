# netrw.nvim: icons in netrw (2026-10-31)

What it does

- `prichrd/netrw.nvim` draws file icons in netrw's sign column.
- Icons come from nvim-web-devicons, the same set oil uses (`use_devicons = true`).
- Spec: `lua/lazyp/new/netrw.lua`; loads on `ft = 'netrw'`, so nothing runs until netrw opens.
- netrw options stay in `lua/genja/opt.lua` (tree style, sort, size style, move command).
- No custom mappings yet; `opts.mappings` takes `['<key>'] = function(payload) ... end`
  (payload: the node under the cursor) or a string Ex command.

Pros / cons (decided: add it)

- pros: small, one setup call; icons match oil and telescope; Lua key actions get the node under the cursor;
  costs nothing until netrw opens.
- cons: oil is the default explorer, so netrw is rare (`:Explore`, `:Lexplore`, `scp://`);
  with `liststyle = 3` the icons sit at the left edge, away from the indented names;
  small project (18 commits), last commit date not checked.

How to use

- `:Lexplore` or `:Explore` (oil handles `:e <dir>`), or `:e scp://host/path/`.

How to test

1. Start nvim, run `:Lazy` and check that netrw.nvim is installed (lazy installs it on start).
2. `:Lexplore` in a project folder: each entry shows a file or folder icon in the sign column.
3. `:Lazy` again: netrw.nvim is now loaded (it was not before step 2).
4. Compare with oil (`-`): same icon for a `.lua` file.
5. If no icons show: `:set signcolumn?` in the netrw buffer, and `:lua print(require('nvim-web-devicons').get_icon('a.lua'))`.
