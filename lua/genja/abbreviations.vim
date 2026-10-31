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
" mksession(): :mksession! that keeps idle shell terminals (lua/genja/ext/term.lua);
" v:lua, not :lua, so `| qa` isn't read as Lua
" s: goes through :Unsaved, so modified buffers get a picker first (lua/genja/ext/unsaved.lua)
cnoreabbrev s:     Unsaved call <SID>SessionSweepOperations() \| call v:lua.require'genja.ext.term'.mksession('~/tmp/viss') \| qa
cnoreabbrev save:  call <SID>SessionSweepOperations() \| call v:lua.require'genja.ext.term'.mksession('~/tmp/viss')


cnoreabbrev e.   edit %:p:h
cnoreabbrev te.  tabedit %:p:h
cnoreabbrev te:  tabedit %:p:h

cnoreabbrev et: tabedit %:p:h
cnoreabbrev ee: edit %:p:h


" a bare :qa, :q, :x (and jj) ask about modified buffers instead of E37/E162; :qa! still drops them
cnoreabbrev <expr> qa (getcmdtype() ==# ':' && getcmdline() ==# 'qa') ? 'Unsaved qa' : 'qa'
cnoreabbrev <expr> q  (getcmdtype() ==# ':' && getcmdline() ==# 'q')  ? 'Unsaved q'  : 'q'
cnoreabbrev <expr> x  (getcmdtype() ==# ':' && getcmdline() ==# 'x')  ? 'Unsaved x'  : 'x'
cnoreabbrev jj Unsaved qa

" g (typo) to quit. :terminal opens pwsh
cnoremap <expr> <CR> getcmdtype() !=# ':' ? '<C-]><CR>'
    \ : getcmdline() ==# 'g' ? '<C-u>Unsaved q<CR>'
    \ : v:lua.require'genja.ext.term'.cmdline_cr()

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

