# Quickfix and location lists

A quickfix list is a list of positions (file, line, column, text). Every
command in this guide works on that list, no matter what made it.

- **Quickfix list**: one per editor (`:c…` commands).
- **Location list**: one per window (`:l…` commands). Use it when two lists
  are needed at once, such as grep results in one window and diagnostics in
  another.

Almost every `:c` command has an `:l` twin: `:cnext`/`:lnext`,
`:copen`/`:lopen`, `:cdo`/`:ldo`.

## Populate

| Source | Command |
|---|---|
| grep (rg if installed, nvim default `grepprg`) | `:grep foo`, `:lgrep foo` |
| vim's own regex, no external tool | `:vimgrep /foo/ **/*.lua`, `:lvimgrep` |
| compiler / linter output | `:make`, `:compiler tsc` then `:make` |
| any shell command with `file:line:` output | `:cexpr system('git grep -n foo')` |
| same, without jumping to the first hit | `:cgetexpr …`, `:lgetexpr …` |
| append instead of replace | `:caddexpr …`, `:grepadd`, `:vimgrepadd` |
| the current buffer, parsed with `errorformat` | `:cbuffer`, `:cgetbuffer` |
| a file of `file:line:` lines | `:cfile errors.txt` |
| diagnostics | `vim.diagnostic.setqflist()` / `setloclist()` (here: actions menu, "diagnostics to quickfix") |
| LSP references / symbols | `grr` (references), `gO` (document symbols, location list) |
| Telescope (this config) | in a picker: `<C-q>` all results to qf, `<M-q>` marked (`<Tab>`), `<M-Q>` append marked; `<C-l>` / `<M-l>` / `<M-L>` same for the location list |
| overseer tasks (this config) | `on_output_quickfix` in `lua/overseer/template/user/` |
| Lua, full control | `vim.fn.setqflist({}, ' ', { title = 'mine', items = items })` |

`:vimgrep` loads every file it searches: it's slow on big trees but
understands vim regex. `:grep` shells out: fast, but uses the tool's regex
syntax.

`:grep` jumps to the first hit. To fill the list without jumping, use
`:grep! foo`, or `:silent grep foo | copen`.

## Open and close

| Key / command | Effect |
|---|---|
| `:copen` / `:lopen` | open the list window (`:copen 20` for height) |
| `:cwindow` / `:lwindow` | open only if the list has entries, close if empty |
| `:cclose` / `:lclose` | close |
| `x` in the list (this config, `after/ftplugin/qf.lua`) | close whichever list this is |

Inside the list window:

| Key | Effect |
|---|---|
| `<CR>` | jump to the entry in the previous window |
| `<C-w><CR>` | open the entry in a new split |
| `:Cfilter foo` / `:Cfilter! foo` | keep / drop entries matching `foo` (needs `:packadd cfilter`) |

## Navigate

Nvim 0.11 ships unimpaired-style maps:

| Key | Command | Effect |
|---|---|---|
| `]q` / `[q` | `:cnext` / `:cprev` | next / previous entry |
| `]Q` / `[Q` | `:clast` / `:cfirst` | last / first entry |
| `]<C-q>` / `[<C-q>` | `:cnfile` / `:cpfile` | first entry of the next / previous file |
| `]l` `[l` `]L` `[L` `]<C-l>` `[<C-l>` | `:l…` twins | same for the location list |

More commands:

- `:cc 7`: go to entry 7. `:cc`: back to the current entry.
- `3]q`: skip three entries ahead.
- `:cbelow` / `:cabove`: the next entry below / above the cursor in this
  buffer. Handy after you've moved away from the list.
- `:clist` (`:clist!` shows all): print the list in the cmdline.

## List history

Every new list pushes the old one onto a stack of 10.

- `:chistory`: show the stack.
- `:colder` / `:cnewer`: go back / forward a list.

You can grep, then grep for something else, then `:colder` to get the
first result set back. `:Cfilter` also makes a new list, so `:colder` undoes
a filter.

## Act on every entry

| Command | Runs on |
|---|---|
| `:cdo cmd` | each entry (line) |
| `:cfdo cmd` | each file in the list, once |
| `:ldo` / `:lfdo` | same for the location list |

Project-wide rename (vim regex, so check the pattern with `:vimgrep` first):

```vim
:grep oldName
:cdo s/oldName/newName/g | update
```

Per file, faster when a file has many hits:

```vim
:cfdo %s/oldName/newName/ge | update
```

- `e` keeps `:s` quiet on files with no match. `update` writes only changed
  buffers.
- Replay a macro on every hit: `:cdo norm @q`.
- Narrow down first: `:Cfilter! test` drops test files, then `:cdo`.

## Tips from the community

- **Filter before acting.** Grep wide, then `:Cfilter` / `:Cfilter!` until
  the list has only what you want, then `:cdo`. `:colder` if you went too far.
- **`:cwindow` after commands that fill lists.** An autocmd opens the list
  only when it has entries:

  ```lua
  vim.api.nvim_create_autocmd('QuickFixCmdPost', {
  	pattern = { '[^l]*' }, -- grep, make, vimgrep, cexpr…
  	command = 'cwindow',
  })
  vim.api.nvim_create_autocmd('QuickFixCmdPost', {
  	pattern = { 'l*' }, -- lgrep, lmake…
  	command = 'lwindow',
  })
  ```

- **Silent grep.** `:silent grep! foo | cwindow` avoids the "press enter"
  prompt and the jump.
- **Toggle key.** A common map: open the list if it's closed, close it if
  it's open (check `getqflist({ winid = 0 }).winid ~= 0`).
- **Location list for "this file only".** `:lvimgrep /TODO/ %` lists TODOs
  in the current file without touching the project-wide quickfix list.
- **Collect from `:g`.** Gather matching lines from the current buffer:

  ```vim
  :cexpr []
  :g/pattern/caddexpr expand('%') .. ':' .. line('.') .. ':' .. getline('.')
  ```

- **Git as a source.** `:cexpr system('git diff --name-only')`
  doesn't parse (no line numbers), but `git grep -n` and `git diff -U0` piped
  through a script do. gitsigns has `:Gitsigns setqflist all` for hunks.
- **Clear a list.** `:cexpr []` or `:call setqflist([], 'r')`.
- **Titles.** Lists set from Lua take a `title`. The winbar shows it in qf
  windows, so give your own lists a readable title.

## Plugins people use

- **nvim-bqf** (kevinhwang91): previews the entry in a float, fzf filtering
  inside the list.
- **quicker.nvim** (stevearc): editable list. Change lines in the list
  window, `:w`, and the edits go to the files. Also expands context lines.
- **replacer.nvim** / **nvim-pqf**: editable list / prettier list.
- **trouble.nvim**: a nicer view of diagnostics, references and qf.

Built-in plus `cfilter` covers most needs; try those first.

## Help

`:h quickfix`, `:h :cdo`, `:h :Cfilter`, `:h errorformat`,
`:h setqflist()`, `:h quickfix-window`, `:h [q`.
