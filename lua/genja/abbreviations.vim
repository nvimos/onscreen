" vim: foldmethod=marker foldlevel=0
" Abbreviations

" s:SessionSweepOperations() {{{
" Before :mksession: close the buffers and splits that shouldn't be saved
" or can't be restored, and anything that would block :qa.
function! s:SessionSweepOperations() abort
	call mkdir(expand('~/tmp'), 'p', 493) " 493 = 0755; 'p': no error when it exists
	pclose " previews
	lua if package.loaded['genja-claudefterm'] then require('genja-claudefterm').kill() end
endfunction
" }}}

cnoreabbrev j:     source ~/tmp/viss
" <SID>: a script-local function can't be called by name from the cmdline
cnoreabbrev s:     call <SID>SessionSweepOperations() \| mksession! ~/tmp/viss \| qa
cnoreabbrev save:  call <SID>SessionSweepOperations() \| mksession! ~/tmp/viss


cnoreabbrev e.   edit %:p:h
cnoreabbrev te.  tabedit %:p:h
cnoreabbrev te:  tabedit %:p:h

cnoreabbrev et: tabedit %:p:h
cnoreabbrev ee: edit %:p:h

cnoreabbrev jj qa
cnoreabbrev g q

cnoreabbrev helf vert help
cnoreabbrev helv vert help
cnoreabbrev velp vert help
cnoreabbrev he\| vert help
cnoreabbrev he:  vert help


cnoreabbrev dgen DogeGenerate

inoreabbrev .... …
inoreabbrev ...( (…)
inoreabbrev ...) (…)

" <expr>: expand to today's date at the time of typing, not when sourced.
" Not ..date: a lhs mixing '.' with letters is invalid (:h abbreviations).
inoreabbrev <expr> ymd! strftime('%Y-%m-%d')
inoreabbrev <expr> ymdt! strftime('%Y-%m-%d %H:%M:%S')

