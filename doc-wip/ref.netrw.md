# netrw tldr

Source: https://vonheikemen.github.io/devlog/tools/using-netrw-vim-builtin-file-explorer/
More: `:help netrw`

## Open

- `:Explore [dir]`: current file's dir (or `dir`); splits if the buffer has unsaved changes and `hidden` is off
- `:Explore!`: vertical split
- `:Hexplore` / `:Sexplore`: horizontal split, below / above (`!` flips)
- `:Vexplore`: vertical split, left (`!` flips)
- `:Texplore`: new tab
- `:Lexplore [dir]`: left side panel, toggles; files open in the window it was called from

## Keys

From `:help netrw-browse-maps`.

Navigate:

- `<CR>`: open file or enter dir
- `-`: up one dir
- `u`: back in dir history
- `U`: forward in dir history
- `gn`: make the dir under cursor the tree top
- `gd`: treat the entry as a dir
- `gf`: treat the entry as a file
- `cd`: make the browsing dir the current dir
- `<C-l>`: refresh listing
- `<C-Tab>`: shrink / expand the netrw window

Open:

- `o`: open in horizontal split
- `v`: open in vertical split
- `t`: open in new tab
- `p`: preview (`<C-w>z` closes)
- `P`: open in the previously used window
- `C`: set the window that files open in
- `x`: open with the system's associated program
- `X`: execute the file under cursor
- `O`: obtain a remote file
- `<C-r>`: browse using a gvim server

Display:

- `i`: cycle listing style: thin, long, wide, tree
- `I`: toggle banner
- `s`: sort by name, time, size, ext
- `r`: reverse sort order
- `S`: set suffix priority for name sort
- `gh`: toggle dotfiles
- `a`: cycle hiding: normal, hide `g:netrw_list_hide`, show only matches
- `<C-h>`: edit the hiding list
- `qf`: show file info
- `<F1>`: help

Files:

- `%`: new file in the current dir (created on `:w`)
- `d`: new dir
- `R`: rename file(s) / dir(s)
- `D`: delete file(s) or empty dir(s)
- `<Del>`: delete file or dir
- `gp`: change permissions (local only)

Marks:

- `mf`: mark / unmark file
- `mF`: unmark files in buffer
- `mu`: unmark all
- `mr`: mark by shell-style pattern
- `qF`: mark files from the quickfix list
- `qL`: mark files from the location list
- `mp`: print marked files
- `mt`: browsing dir becomes copy/move target
- `mc`: copy marked to target
- `mm`: move marked to target
- `md`: diff marked files (up to 3)
- `me`: put marked on the arglist and edit
- `mg`: vimgrep in marked files
- `mh`: toggle marked files' suffixes in the hiding list
- `mv`: run a vim command on each marked file
- `mx`: run a shell command on each marked file
- `mX`: run a shell command on all marked files at once
- `mz`: compress / decompress marked files
- `mT`: ctags on marked files

Copy/move: `mt` on the target dir, `mf` the files, then `mc` or `mm`.

Bookmarks:

- `mb`: bookmark the current dir
- `mB`: remove the last bookmark
- `gb`: jump to the last bookmark
- `qb`: list bookmarks and history

## Gotchas

- Moving files fails with "tried using g:netrw_localmovecmd" unless `g:netrw_keepdir = 0`.
- Mark actions only apply to marked files listed in the current buffer.
- `D` won't delete a non-empty dir: `mf` it, then `mx` with `rm -r`.
- Dirs don't copy without `g:netrw_localcopydircmd = 'cp -r'`.

## Settings the article suggests

```vim
let g:netrw_keepdir = 0           " keep browsing dir and current dir in sync (fixes move)
let g:netrw_winsize = 30          " split size in %
let g:netrw_banner = 0            " hide banner (I shows it)
let g:netrw_list_hide = '\(^\|\s\s\)\zs\.\S\+'   " hide dotfiles
let g:netrw_localcopydircmd = 'cp -r'            " copy dirs recursively
hi! link netrwMarkFile Search     " highlight marked files
```

## Keymaps the article suggests

- Global: `<leader>dd` -> `:Lexplore %:p:h`, `<leader>da` -> `:Lexplore`.
- Buffer-local, set from `autocmd FileType netrw`:
	- `h` up, `l` open, `H` back, `.` toggle dotfiles, `P` close preview, `L` open file and close netrw
	- `<Tab>` mark, `<S-Tab>` unmark buffer, `<leader><Tab>` unmark all
	- `ff` new file and save, `fe` rename, `fc`/`fx` copy/move marked, `fC`/`fX` set target under cursor and copy/move, `f;` shell command
	- `fl` list marks: `netrw#Expose("netrwmarkfilelist")`, `fq` show target: `netrw#Expose("netrwmftgt")`
	- `bb`/`bd`/`bl` bookmark add/remove/jump
	- `FF` recursive delete: `mu`, `mf`, `mx` with `rm -r` filled in (`<C-c>` cancels)
