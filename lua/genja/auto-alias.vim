" Aliases

command! -nargs=* P Luapad <args>
command! -nargs=* M MRU <args>
command! -nargs=* -complete=file T       tabedit <args>
command! -nargs=* -complete=file Te      tabedit <args>
command! -nargs=* -complete=file Tabedit tabedit <args>
command!                         Tet     tabedit | Telescope
command!                         Tm      tabmove +1
command!                         Tmm     tabmove -1
command!                         TM      tabmove -1

command! DumpMappings :enew | put=execute('map')

function! DumpMessages()
	redir => messages
	silent messages
	redir END
	enew
	setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted nomodified
	enew
	silent put=messages
endfunction
command! DumpMessages :call DumpMessages()

command! LazygitFterm :FloatermNew --height=0.96 --width=0.94 --wintype=float --name=lazygit --autoclose=smart lazygit <cr>
command! PythonFterm  :FloatermNew                            --wintype=vsplit --name=python python <cr>

command! PwshFterm    :FloatermNew --height=0.8 --width=0.8 --wintype=float --name=pwsh --autoclose=smart pwsh <cr>
command! BashFterm    :FloatermNew --height=0.8 --width=0.8 --wintype=float --name=bash --autoclose=smart bash <cr>
command! RangerFterm  :FloatermNew --height=0.6 --width=0.4 --wintype=float --name=floaterm1 --position=topleft --autoclose=smart ranger --cmd="cd ~"
command! -nargs=* Ct ClaudeFterm <args>
" :ClaudeFterm comes from plug-wip/genja-claudefterm.nvim (spec: lua/lazyp/new/genja-claudefterm.lua)

command! QQQ tabdo write | qa
command! JJJ tabdo write | qa
command! QQ qa
command! JJ qa
command! O only
command! -nargs=* W write <args>
command! -nargs=* So source <args>

" Oneliners

" compare current state of the file vs last save or commit
command! DiffOrigGit vert new | set bt=nofile | execute 'silent r !git show HEAD:'.expand('%').' | 0d_' | diffthis | wincmd p | diffthis | wincmd r
command! DiffOrig    vert new | set bt=nofile | r ++edit # | 0d_ | diffthis | wincmd p | diffthis | wincmd r
command! Lspclients :lua =vim.lsp.get_clients()

command! YankFilenameClipboard let @+ = expand('%:p')
command! YankFilename put =expand('%:p')
command! YankYmd put =luaeval('os.date([[%Y-%m-%d]])')


" Autocommands

augroup FileType c,cpp,java set mps+==:;
augroup FileType lua set mps+function(:end
augroup GenjaGeneralSettings
	autocmd!

	" close with q, x
	autocmd FileType qf,help,man,lspinfo,telescope nnoremap <silent> <buffer> q :close<CR>
	autocmd FileType qf,help,man                   nnoremap <silent> <buffer> x :close<CR>

	" -cro : do not insert comment leaders, and do not auto wrap comments
	autocmd BufWinEnter * :set formatoptions-=cro

	autocmd FileType qf set nobuflisted

	" go back to last position.
	autocmd BufReadPost *
				\ if line("'\"") > 0 && line("'\"") <= line("$") |
				\   exe "normal! g`\"" |
				\ endif

	" show what was yanked, briefly
	if has('nvim')
		autocmd TextYankPost * silent! lua vim.hl.on_yank({higroup = 'Visual', timeout = 333})
	end

augroup end

" autocmd BufNewFile * if &buftype ==# 'nofile' | file Empty | endif
" autocmd BufNewFile * if &filetype ==# 'dashboard' | file Dashboard | endif


augroup _alpha
	autocmd!
	autocmd User AlphaReady set showtabline=0 | autocmd BufUnload <buffer> set showtabline=2
augroup end

" even out the splits of every tab when nvim is resized; tabdo ends on the last tab,
" so go back to the tab that was current (idea 32: resizing jumped to the last tab)
augroup _resize_equalize_tabs
	autocmd!
	autocmd VimResized * let s:tab = tabpagenr() | tabdo wincmd = | execute s:tab .. 'tabnext'
augroup end

augroup _markdown
	autocmd!
	autocmd FileType markdown setlocal wrap
	autocmd FileType markdown setlocal nospell
	autocmd FileType markdown setlocal listchars=tab:\ \ 
	autocmd FileType markdown setlocal listchars=multispace:\ \ \ \ 
augroup end

augroup _git
	autocmd!
	autocmd FileType gitcommit setlocal wrap
	autocmd FileType gitcommit setlocal spell
augroup end



autocmd FileType vim,help setlocal keywordprg=:help


