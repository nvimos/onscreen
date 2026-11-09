
command! LogEdit :call EditLogDir()
function! EditLogDir()
	let logpath = stdpath('data')
	execute 'edit ' .. logpath .. '/logs'
endfunction

" :Ss - Strip trailing spaces
command! Ss :call RemoveTrailingSpaces()
function! RemoveTrailingSpaces()
	let save_cursor = getpos('.')
	if &filetype == 'markdown'
		" allow 2 spaces at the end of a line in markdown 
		silent! %s/\v([^ ])( {3,}|( {1}))$/\1/e
		silent! %s/^\s\+$//e
	else
		silent! %s/\s\+$//e
	endif
	call setpos('.', save_cursor)
endfunction


" Right click menu: ToggleWrap
function! ToggleWrap()
	if &wrap
		set nowrap
	else
		set wrap
	endif
endfunction

" the right-click menu (PopUp) is in lua/genja/popup.lua; ToggleWrap above is called from it


" Modal Help
command -bar -nargs=? -complete=help F1 execute s:HelpCurwin(<q-args>)
command -bar -nargs=? -complete=help H execute s:HelpCurwin(<q-args>)
command -bar -nargs=? -complete=help J execute s:HelpCurwin(<q-args>)
let s:init_help_tags = v:false
function s:HelpCurwin(subject) abort
	" Open help using the whole window instead of splitting
	" Then skip the help.txt when using <C-o> and go back to the file that was open before.
	if !s:init_help_tags
		execute 'silent noautocmd keepalt help'
		execute 'silent noautocmd keepalt helpclose'
		let s:init_help_tags = v:true
	endif
	if !empty(a:subject)
		"execute 'silent noautocmd keepalt edit ' .. &helpfile
		set buftype=help
		execute 'help ' .. a:subject
		nnoremap <silent> <C-o> :call GotoMark2()<CR>
	endif
	return ''
endfunction
function! GotoMark2()
	execute "normal! 2\<C-o>"
	execute "nunmap <C-o>"
endfunction
