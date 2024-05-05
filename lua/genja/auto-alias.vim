
" Aliases

command! -nargs=* M MRU <args>
command! -nargs=* T       tabedit <args>
command!          Td      tabedit | Dashboard
command!          Tt      tabedit | Telescope
command! -nargs=* Tabedit tabedit <args>

command! QQQ tabdo write | qa
command! JJJ tabdo write | qa
command! QQ qa
command! JJ qa
command! O only
command! Tm tabmove +1
command! TM tabmove -1
command! -nargs=* W write <args>
command! -nargs=* So source <args>

" Oneliners

" compare current state of the file vs last save or commit
command! DiffOrigGit vert new | set bt=nofile | execute 'silent r !git show HEAD:'.expand('%').' | 0d_' | diffthis | wincmd p | diffthis | wincmd r
command! DiffOrig    vert new | set bt=nofile | r ++edit # | 0d_ | diffthis | wincmd p | diffthis | wincmd r
command! Lspclients :lua =vim.lsp.get_clients()



" Abbreviations

cnoreabbrev load:  source ~/tmp/viss
cnoreabbrev r:     source ~/tmp/viss
cnoreabbrev save:  mksession! ~/tmp/viss \| qa

cnoreabbrev e.   edit %:p:h 
cnoreabbrev te.  tabedit %:p:h 
cnoreabbrev te:  tabedit %:p:h 

cnoreabbrev et: tabedit %:p:h
cnoreabbrev ee: edit %:p:h

cnoreabbrev jj qa

cnoreabbrev helf vert help
cnoreabbrev helv vert help
cnoreabbrev velp vert help
cnoreabbrev he\| vert help
cnoreabbrev he:  vert help


cnoreabbrev dgen DogeGenerate
inoreabbrev iferr: if err != nil {<cr>return err<cr>}<cr>  



" Autocommands

augroup _general_settings
	autocmd!

	" close with q
	autocmd FileType qf,help,man,lspinfo,telescope nnoremap <silent> <buffer> q :close<CR> 

	" -cro : do not insert comment leaders, and do not auto wrap comments
	autocmd BufWinEnter * :set formatoptions-=cro

	autocmd FileType qf set nobuflisted

	" go back to last position.
	autocmd BufReadPost *
				\ if line("'\"") > 0 && line("'\"") <= line("$") |
				\   exe "normal! g`\"" |
				\ endif


	" show what was yanked, briefly
	autocmd TextYankPost * silent! lua require('vim.highlight').on_yank({higroup = 'Visual', timeout = 333}) 

augroup end

" autocmd BufNewFile * if &buftype ==# 'nofile' | file Empty | endif
" autocmd BufNewFile * if &filetype ==# 'dashboard' | file Dashboard | endif


augroup _alpha
	autocmd!
	autocmd User AlphaReady set showtabline=0 | autocmd BufUnload <buffer> set showtabline=2
augroup end

augroup _auto_resize
	autocmd!
	autocmd VimResized * tabdo wincmd = 
augroup end

augroup _markdown
	autocmd!
	autocmd FileType markdown setlocal wrap
	autocmd FileType markdown setlocal spell
augroup end

augroup _git
	autocmd!
	autocmd FileType gitcommit setlocal wrap
	autocmd FileType gitcommit setlocal spell
augroup end




