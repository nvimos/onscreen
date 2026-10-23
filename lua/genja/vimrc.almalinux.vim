" vim: fdm=marker

" todo: break up into parts and source indivitually from nvim
"       idea is to keep it maintainable and concatenate a 
"       full solid alma-vimrc when needed for the nomad setup



" todo - taglist for folds -or- treesitter?

" {{{ PORTABLE CORE -- vim and nvim
" Everything in this fold is loaded by both legacy vim and nvim.
" nvim sources this file from init.vim after the genja Lua profile, then stops
" at the `finish` below. Keep only plugin-free settings here that don't fight
" lua/genja/opt.lua or the genja keymaps.

" {{{ optiones
" {{{ syntax, filetype, encoding
if getenv('VIM_TYPE') != 'lean'
	syntax on
	syntax sync minlines=256
	"syntax sync minlines=768
	filetype on
	filetype plugin on
	filetype indent on
endif
set encoding=utf-8
set synmaxcol=1020

 " }}}

set hlsearch
set nocompatible
set nowrap

" vim9
set wildmenu
set wildmode=full

" {{{ behavior
set backspace=indent,start,eol
set ignorecase
set smartcase
" }}}

" {{{ look and feel

set splitbelow splitright

" {{{ rice
" set lazyredraw
set nocursorline
set nocursorcolumn
set norelativenumber
" }}}

set modeline
set modelines=2
set cmdheight=2
set termguicolors

" set foldmethod=syntax
set shortmess=flmnxS
set shortmess-=I " I disables greeting

set sidescroll=1
set wrapmargin=1

" }}}

" }}}

" {{{ folds
set foldcolumn=3 " fdc=2
set foldopen-=block
" }}}

" {{{ autoformatting
set formatoptions -=c
set formatoptions -=r
set formatoptions -=o
" set formatoptions-=crot
 " }}}

" {{{ vivi text, wrapping, space-tabs
set nowrap
set autoindent
set smartindent
set noexpandtab   " convert tabs to spaces, if true
set shiftwidth=4  " the number of spaces inserted for each indentation
set tabstop=4     " width of tabs
" set softtabstop=4   " Pressing Tab inserts 4 spaces
 " }}}


" {{{Show effects of a substitution command incrementally in the buffer, not in a preview buffer
if exists('&inccommand')
	set inccommand=nosplit
endif
 " }}}

" {{{ mapleader <leader>
let mapleader=" "
 " }}}


" {{{ keymaps

"inoremap <Tab> <C-n>

" nnoremap <silent> <F11> :TlistToggle<CR>
" nnoremap <F7> :set guifont=*<cr>
" nnoremap <F8> :setl noai nocin nosi inde=<CR>

" let g:startify_custom_header =
	" \ map(split(system('fortune | cowsay'), '\n'), '"   ". v:val') + ['','']



" {{{ keymaps focused scrolling
nnoremap <m-j> jz.
nnoremap <m-1> kz.
nnoremap <m-k> kz.
nnoremap <m-f> kz.
 " }}}

" {{{ keymaps random
" dont move on #
" nn # #<c-o>
nnoremap <f5>          <cmd>source %<cr>
nnoremap !             :<up><home><c-right>!<cr>
" }}}

" {{{ keymaps folding controls
" https://www.vimfromscratch.com/articles/vim-folding
" https://learnvimscriptthehardway.stevelosh.com/chapters/49.html
" {{{ folds open
nn zo zo
nn z<right> zo
nn zu zR
nn z] zR
" }}}
" {{{ folds open
nn zy zc
nn z<left> zc
nn zY zM
nn z[ zM
" }}}
" {{{ folds toggle
nn z<space> za
" }}}
" {{{ fold paragraph
" duplicated in lua/genja/wrapfold.lua (<leader>wwf, visual zf, :WrapFold)
nnoremap <leader>wwf vip:<c-u>WrapFold<cr>?NamelessFold<cr>ciw
vnoremap <leader>wwf    :<c-u>WrapFold<cr>?NamelessFold
" :<c-u>norm k0WWciw

" }}}
" }}}

" {{{ simplify input
nnoremap gf :e <cfile><CR>

" {{{ select block
nn <leader>s. vip
" }}}
" }}}

" {{{ search
nnoremap / /\v
nnoremap ? ?\v
" }}}

" }}}

" {{{ bewen-tags motion
onoremap iT <cmd>:norm F>lvf<<cr>

 " }}}

" {{{ abbreviations

inoreabbrev #! #!/usr/bin/env sh
cnoreabbrev so. source $MYVIMRC
cnoreabbrev ep. e ~/.config/bash/_profile
cnoreabbrev eps. e ~/.config/bash


" {{{ abbreviations command mode

" cnoreabbrev ;w     <left>

" {{{ session
cnoreabbrev j:     source     $MYVIMDIR/tmp/viss
cnoreabbrev s:     pclose \| mksession! $MYVIMDIR/tmp/viss \| qa
cnoreabbrev save:  pclose \| mksession! $MYVIMDIR/tmp/viss
 " }}}

" {{{ substitute global, paragraph, section
cnoreabbrev su.       s,\v,,g<left><left><left>
cnoreabbrev sug.     %s,\v,,g<left><left><left>
cnoreabbrev sup. '{,'}s,\v,,g<left><left><left>
cnoreabbrev sus. '[,']s,\v,,g<left><left><left>
" }}}

" {{{ write, quit
cnoreabbrev wj wq
cnoreabbrev jw wq
cnoreabbrev jj qa
cnoreabbrev j. q
" }}}

" {{{ cd and other macros
cnoreabbrev cd.  cd %:p:h
cnoreabbrev cdv. cd $MYVIMDIR
cnoreabbrev cdp. cd $XDG_CONFIG_HOME
cnoreabbrev cd-  cd $HOME
cnoreabbrev er. e %
 " }}}

" {{{ edit close current file
cnoreabbrev te. tabe %:p:h
cnoreabbrev et. tabe %:p:h
cnoreabbrev e.  edit %:p:h
" }}}

" {{{ edir vim files
cnoreabbrev ei. edit $MYVIMRC
cnoreabbrev ev. edit $MYVIMDIR
" }}}

" {{{ help
cnoreabbrev ve.  vert help
cnoreabbrev helv vert help
cnoreabbrev velp vert help
cnoreabbrev he:  vert help
" }}}
 " }}}

" {{{ abbreviations insert mode, unicode stuff
inoreabbrev ,,, …
inoreabbrev ,,( (…)
" }}}
 " }}}


" {{{ autogroups whatever {{{
augroup Tmp
	au!
	" au BufWritePost $MYVIMRC call system('scp .vimrc hope:~')
augroup END " }}}


let MYVIMDIR = expand('$MYVIMDIR')

augroup Whatever
	au!

	au BufRead,BufEnter $MYVIMRC nnoremap <buffer> <c-j> :call search('\v^[\t ]*" (vivi\|\{\{\{)', 'W')<cr>
	au BufRead,BufEnter $MYVIMRC nnoremap <buffer> <c-f> :call search('\v^[\t ]*" (vivi\|\{\{\{)', 'bW')<cr>
	au BufRead,BufEnter $MYVIMRC setlocal foldmethod=marker


	au BufRead,BufEnter bash nnoremap <buffer> <c-j> :call search('(function\|\{\{\{)', 'W')<cr>
	au BufRead,BufEnter bash nnoremap <buffer> <c-f> :call search('(function\|\{\{\{)', 'bW')<cr>

	" close with q
	au FileType qf set nobuflisted
	au FileType qf nnoremap <silent><buffer>q :close<CR>
	au FileType man nnoremap <silent><buffer>q :close<CR>
	au FileType help nnoremap <silent><buffer>q :close<CR>
	au FileType help nnoremap <silent><buffer>x :close<CR>
	au FileType lspinfo nnoremap <silent><buffer>q :close<CR>
	au FileType telescope nnoremap <silent><buffer>q :close<CR>

	au FileType vim,help setlocal keywordprg=:help " <K> uses :help
	au FileType help nnoremap <buffer> <return> <C-]>
	au FileType help nnoremap <buffer> <backspace> <C-o>

	au FileType netrw nnoremap <buffer> j jz.

	" -cro : no comment leaders, wrapping, splitting

	au BufWinEnter * set formatoptions-=c
	au BufWinEnter * set formatoptions-=r
	au BufWinEnter * set formatoptions-=o
	au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") |
				\ exe "normal! g'\"" | endif " jump to " -- check &buftype?

 	au VimResized * exe wincmd = " auto reflow panes


augroup end
" }}}


" {{{ autogroups filetypes
augroup VimrcFiletypes
	au!
	au FileType sh setlocal shiftwidth=4 softtabstop=4 noexpandtab
	au FileType sh match Statement /^function/
	au FileType sh match shSlash /\~*\//
	"
	au FileType markdown setlocal wrap
	au FileType markdown setlocal nospell
	au FileType markdown setlocal listchars=tab:\ \
	au FileType markdown setlocal listchars=multispace:\ \ \ \
	"

	au FileType gitcommit setlocal wrap
	au FileType gitcommit setlocal spell

	au FileType text setlocal wrap linebreak textwidth=76

	au FileType vim,sh,bash,make setlocal iskeyword+=-

	au FileType html setlocal noexpandtab shiftwidth=2 softtabstop=2
	au FileType java setlocal noexpandtab shiftwidth=4 tabstop=4
	au FileType javascript setlocal expandtab shiftwidth=2 softtabstop=2

	au FileType php let g:syntastic_php_checkers = ['php']
	au FileType php setlocal expandtab
	au FileType php setlocal noexpandtab
	au FileType php setlocal shiftwidth=4
	au FileType php setlocal softtabstop=4
	au FileType php setlocal tabstop=4

	au BufReadPost,BufNewFile *.fl nnoremap <buffer> <enter> gf
	au BufReadPost,BufNewFile *.fl nnoremap <buffer> ] 3j
	au BufReadPost,BufNewFile *.fl nnoremap <buffer> [ 3k
	au BufReadPost,BufNewFile *.fl nnoremap <buffer> f k
	au BufReadPost,BufNewFile *.fl nnoremap <buffer> <Leader>u :Unite line:<C-r>=bufname('%')<CR><CR>


	autocmd BufReadPre * if getfsize(expand("<afile>")) > 1024*1024 | syntax off | set nocursorline nocursorcolumn | endif

augroup end
" }}}


" {{{ commands

command! Hitest source $VIMRUNTIME/syntax/hitest.vim
command! Cotest :runtime syntax/colortest.vim

command! JJJ tabdo write | qa
command! JJ qa
command! J q
command! O only
command! Tm  tabmove +1
command! Tmm tabmove -1
command! TM  tabmove -1

" Toggle boolean option (:To wrap , :To number, …)
command! -nargs=1 -complete=option -bar To execute 'set ' . <q-args> . '!'
command! -nargs=0 ExampleIfElse
      \ if 0 | echo "Condition true" |
      \ else | echo "Condition false" |
      \ endif


command! -nargs=* -complete=file T tabedit <args>
command! -nargs=* -complete=file Te tabedit <args>
command! -nargs=1 -complete=help Th tabedit | help <args> | only

command! -nargs=* W write <args>
command! -nargs=* So source <args>


" [c, ]c - Jump to previous, next change
command! DiffSee     write !diff -u % -
command! DiffOrig    vnew | set bt=nofile bh=wipe nobl noswf | r ++edit # | 0d_ | diffthis | wincmd p | diffthis
command! DiffOrigGit vnew | set bt=nofile bh=wipe nobl noswf | exe printf("%r! git -C %s show HEAD:./%s", expand('#:p:h:S'), expand('#:t:S')) | 0d_ | diffthis | wincmd p | diffthis
command! DiffYesterday let [a, b] = [tempname().'-a', tempname().'-b'] | earlier 24h | exec 'w '.a | later 24h | exec 'w '.b | update | exec 'tabnew '.a | diffthis | vert split | exec 'edit '.b | diffthis
"  {{{ diffage
" set diffopt+=iwhite
" set diffopt+=horizontal
" git config --global diff.tool vimdiff
" git config --global diff.tool nvimdiff
" git config --global difftool.prompt false
" for rw mode
" git config --global difftool.vimdiff.cmd 'vimdiff "$LOCAL" "$REMOTE"'.
" another tool
" git config --global alias.d difftool -x 'nvim -d'
" if &diff
"    highlight! link DiffText MatchParen
" endif
"" git
"" [merge]
""     tool = nvim
"" [mergetool]
""     keepBackup = false
"" [mergetool "nvim"]
""     cmd = nvim -d $LOCAL $REMOTE $MERGED -c '$wincmd w' -c 'wincmd J'
" }}}


function! BindBackspace()
  " does not work as a command for some reason, only as a function
  nnoremap <buffer> <Backspace> dd
  normal dd
endfunction
command! BackspaceDD call BindBackspace()

" }}}

" {{{ commands yank
command! YankFilename put = expand('%:p')
command! YankDate call append(line('.'), split(system('date'), "\n"))
command! YankYmd  call append(line('.'), split(system('date +%Y-%m-%d'), "\n"))
command! YankWeek call append(line('.'), split(system('date +%W'), "\n"))
if exists('*luaeval')
	command! YankYmd  put =luaeval('os.date([[%Y-%m-%d]])')
	command! YankWeek put =luaeval('os.date([[%W]])')
	command! YankDate put =luaeval('os.date([[%a %b %d %H:%M:%S %z %Y]])')
endif
" }}}


" {{{ functions and usercommands
" {{{ command Sub(stitute)
function! s:easy_sub(p, r, f='', g='', l1='', l2='')
	let r = a:r
	if r == '""' || r == "''"
		let r = ''
	endif
	" todo cycle / @ ^ : as splitter if pattern contains it.
	" execute printf('%ss^\v%s^%s^%s', a:g, a:p, r, a:f)
	execute printf('%d,%d%ss^\v%s^%s^%s', a:l1, a:l2, a:g, a:p, r, a:f)
endfunction
command -nargs=+ SR   call s:easy_sub(<f-args>, "",  "")
command -nargs=+ -range Sub  call s:easy_sub(<f-args>, "",  "", <line1>, <line2>)
command -nargs=+ -range Suba call s:easy_sub(<f-args>, "g", "", <line1>, <line2>)
command -nargs=+ Subg call s:easy_sub(<f-args>, "g", "%")
" }}}
" {{{ DumpMessages
command! DumpMessages :call s:dumpMessages()
function! s:dumpMessages()
	redir => messages
	silent messages
	redir END
	new
	setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted nomodified
	silent put=messages
endfunction "}}}



" command Ss - strip trailing spaces {{{
command! Ss call s:removeTrailingSpaces()
function! s:removeTrailingSpaces()
	let save_cursor = getpos('.')
	if &filetype == 'markdown'
		" allow 2 spaces at the end of a line in markdown
		silent! %s/\v([^ ])( {3,}|( {1}))$/\1/e
		silent! %s/^\s\+$//e
	else
		silent! %s/\s\+$//e
	endif
	call setpos('.', save_cursor)
endfunction " }}}

" {{{ vim operator ~ extended tilde - toggle true/false under cursor
" duplicated in lua/genja/tilde.lua (~, <M-~> plain)
function! TildeToggleUnderCursor()
	let save_pos = getpos(".")
	let line = getline('.')
	let col = col('.')
	let char_under = line[col - 1]
	function! s:ReplaceUnderCursor(old_text, new_text) abort
		let [l, c] = [getline('.'), col('.') - 1]
		let [before, after] = [ strpart(l, 0, c), strpart(l, c + len(a:old_text))]
		call setline('.', before . a:new_text . after)
		normal! l
	endfunction

	if char_under ==# '-' || char_under ==# '+'
		let new_char = char_under ==# '-' ? '+' : '-'
		call s:ReplaceUnderCursor(char_under, new_char)
		return
	endif
	if char_under ==# '<' || char_under ==# '>'
		let new_char = char_under ==# '>' ? '<' : '>'
		call s:ReplaceUnderCursor(char_under, new_char)
		return
	endif
	let word_start = col('.') - 1
	while word_start > 0 && line[word_start - 1] =~# '\a'
		let word_start -= 1
	endwhile
	let word_end = col('.') - 1
	while word_end < len(line) && line[word_end] =~# '\a'
		let word_end += 1
	endwhile
	let word = strpart(line, word_start, word_end - word_start)
	if match(strpart(line, 0, word_start), '=\s*$') != -1
		let multi_char_toggle = {
					\ 'yes': 'no',
					\ 'true': 'false',
					\ 'on': 'off',
					\ }
		let l:done = v:false
		for [key, val] in items(multi_char_toggle)
			if word == key
				exe 'normal! ciw'.val
				let l:done = v:true
			elseif word == val
				exe 'normal! ciw'.key
				let l:done = v:true
			endif
		endfor
		if l:done
			return
		endif
	endif
	normal! ~
endfunction
nnoremap <silent> ~ :call TildeToggleUnderCursor()<cr>
nnoremap <silent> <esc>~ ~
" }}}

" {{{ command Info - describe buffer and host environment
function! s:info_buffer_host()
  let l:bufnum = bufnr('%')
  let l:filename = expand('%:p')
  let l:filetype = &filetype
  let l:modified = &modified ? 'Modified' : 'Not Modified'
  let l:readonly = &readonly ? 'ReadOnly' : 'Writable'
  let l:line = line('.')
  let l:col = col('.')
  let l:total_lines = line('$')
  let l:percent = printf('%.0f%%', (l:line * 100.0) / max([l:total_lines, 1]))
  let l:hostname = substitute(system('hostname'), '\n', '', '')
  let l:os = substitute(system('uname -v'), '\n', '', '')
  let l:info = ''
			  \ . printf( " | Host: %s | OS..: %s", l:hostname, l:os)
			  \ . printf( " | Buffer.: %d | File...: %s | Type...: %s | Modified: %s | Readonly: %s",l:bufnum, l:filename, l:filetype, l:modified, l:readonly)
			  \ . printf( " | Line....: %d/%d (%s) ", l:line, l:total_lines, l:percent)
			  \ . printf( " | File....: %s", expand('%'))
  9split
  enew
  setlocal readonly buftype=nofile bufhidden=hide
  setlocal nomodified
  nnoremap <buffer> q :close<cr>
  nnoremap <buffer> <c-w> :close<cr>
  call append(0, split(substitute(l:info, " | ", "\n", "g"), "\n"))
endfunction
command! Info call s:info_buffer_host() " }}}

if !exists('s:HandleEnters')
    let s:HandleEnters = []
endif
function! s:handle_enter_add(f) abort
    call add(s:HandleEnters, a:f)
endfunction

" {{{ <return> handler
function! s:HandleEnter() abort
    " for F in s:HandleEnters
    "     try
	" 		call F()
    "     catch
	" 		echom "HandleEnter error in"
	" 	endtry
    " endfor
	call s:ToggleFold()
    call feedkeys("\<Enter>", 'n')
endfunction
nnoremap <Enter> <cmd>call <SID>HandleEnter()<CR>
" }}}

" {{{ <return> toggle fold or <return>
function! s:ToggleFold()
	if foldlevel(getpos('.')[1])
		let l:fc = foldclosed(getpos('.')[1])
		if l:fc != -1
			normal! zo
		elseif l:fc  == -1
			normal! zc
		endif
		" stay on the same line
		"call feedkeys("k", 'n')
	endif
endfunction
" call s:handle_enter_add(function('ToggleFold'))
" }}}

" {{{ command WrapFold -- insert fold marker around selection
" duplicated in lua/genja/wrapfold.lua
function! s:wrap_fold_with_marker(fold_title='NamelessFold') range
  let csp = split(&commentstring, '%s')
  if len(csp) == 2
    let prefix = substitute(csp[0], '\s*$', '', '')
    let suffix = substitute(csp[1], '^\s*', '', '')
  else
    let suffix = ''
    let prefix = substitute(&commentstring, '%s', '', 'g')
  endif
  " call append(a:firstline - 1, printf('%s %s %s', prefix, repeat('{', 3), a:fold_title))
  let m1 = repeat('{', 3)
  let m2 = repeat('}', 3)
  let a = printf('%s %s %s', prefix, m1, a:fold_title)
  let b = printf('%s %s', prefix, m2)
  call append(a:firstline - 1, a)
  call append(getpos("'>")[1], b)
endfunction
command! -range -nargs=* WrapFold call <SID>wrap_fold_with_marker(<f-args>)
" }}}




" }}}

" {{{ show syntax group
function! SyntaxGroup()
  let [ lnum, cnum ] = [line("."), col(".")]
  let [ syn1, syn2 ] = [synID(lnum, cnum, 1), synID(lnum, cnum, 0)]
  let [ synt ] = [ synIDtrans(syn1) ]
  echo printf('hi<%s> trans<%s> lo<%s>', synIDattr(syn1, 'name'), synIDattr(syn2, 'name'), synIDattr(synt, 'name'))
endfunction
command SyntaxGroup call SyntaxGroup()
" nnoremap <F10> :call SyntaxGroup()<CR>
nnoremap <leader>s? :call SyntaxGroup()<CR>
" }}}

" {{{ Redirect command output
" put output from a (system) command into a scratch
function! Redir(cmd, range, start, end)
	for win in range(1, winnr('$'))
		if getwinvar(win, 'scratch')
			execute win . 'windo close'
		endif
	endfor
	if a:cmd =~ '^!'
		" shell command; expand %, strip leading !
		let cmd = a:cmd =~' %'
			\ ? matchstr(substitute(a:cmd,' %',' '.expand('%:p'),''),'^!\zs.*')
			\ : matchstr(a:cmd,'^!\zs.*')
		if a:range == 0
			let output = systemlist(cmd)
		else
			let joined_lines = join(getline(a:start, a:end), '\n')
			let cleaned_lines = substitute(shellescape(joined_lines), "'\\\\''", "\\\\'", 'g')
			let output = systemlist(cmd . " <<< $" . cleaned_lines)
		endif
	else
		redir => output
		execute a:cmd
		redir END
		let output = split(output, "\n")
	endif
	vnew
	let w:scratch = 1
	setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile
	call setline(1, output)
endfunction
command! -nargs=1 -complete=command -bar -range Redir 
			\ silent call Redir(<q-args>, <range>, <line1>, <line2>)
" }}}


" {{{ Greetings
" autocmd VimEnter * echow "Welcome to my custom Vim setup!"
function! ShowCenteredMessage(msg)
	" Calculate center position
	let width = winwidth(0)
	let height = winheight(0)
	let lines = split(a:msg, "\n")
	let line_count = len(lines)
	let top_padding = (height - line_count) / 2
	enew
	setlocal buftype=nofile bufhidden=hide noswapfile
	call append(0, repeat([''], top_padding))
	for line in lines
		let padding = repeat(' ', (width - strlen(line)) / 2)
		call append('$', padding . line)
	endfor
	if getline(1) == ''
		silent 1delete_
	endif
	setlocal nomodifiable nonumber norelativenumber nospell
	setlocal nobuflisted
endfunction
" }}}

" }}} PORTABLE CORE

" {{{ END OF PORTABLE CORE: nvim stops here
if has('nvim') | finish | endif
" Everything below runs in legacy vim only. It's kept out of nvim because it
" either needs vim-plug plugins that nvim doesn't install, has side effects
" (curl downloads, plugin bootstrap, auto-writes), or would override the genja
" Lua profile (options, statusline, colors, state/shada, keymaps).
" }}}

" {{{ VIM-ONLY: options that differ from genja
" Why this block is below the finish:
" each option here has a different value in lua/genja/opt.lua (or nvim's
" default, or init.vim for guifont). nvim sources this file *after* genja,
" so if these lines ran in nvim they would silently replace genja's values.
" Here, below the finish, they only shape legacy vim; nvim keeps genja's.
" When you change one of these, check whether opt.lua should change too.
if !has('win64')
	set termencoding=utf-8
endif
set wildoptions=pum
set guifont=Source\ Code\ Pro\ Medium\ 11
" set guifont=SauceCodePro\ Nerd\ Font
set foldlevelstart=2
set colorcolumn=0
"

" {{{ fillchars
set fillchars=fold:│     " instead of +/-
set fillchars+=stl:\     " statusline
set fillchars+=stlnc:─   " statusline
if v:version >= 800
  set fillchars+=vert::
  set fillchars+=foldopen:▼,foldclose:▶,foldsep:│
endif
" }}}


"
set ttimeoutlen=60
set timeoutlen=1200
set timeoutlen=800

"" {{{ no (visual) bells
set noerrorbells
set belloff=all
set t_vb=
set visualbell " }}}

set formatoptions -=t " genja appends t
" {{{ listchars

" {{{ unicode
" ᚱ U+16B1 Runic Letter Raido Rad Reid R
" ᛋ U+16CB Runic Letter Sigel Long-Branch-Sol S
" ᛜ U+16DC Runic Letter Ingwaz
" ᛝ U+16DD Runic Letter Ing
" ᛬ U+16EC Runic Multiple Punctuation
" ᚤ U+16A4 Runic Letter Y
" ᛃ U+16C3 Runic Letter Jeran J
" ᛇ (U+16C7) Runic Letter Iwaz Eoh
"
" ↚ Leftwards Arrow With Stroke (U+219A)

" ⇤ Leftwards Arrow To Bar (U+21E4)
" ⇥ Rightwards Arrow To Bar (U+21E5)

" set listchars=eol:\\x24
" set listchars=eol:\\u21b5
" set listchars=eol:\\U000021b5
 " }}}
set listchars="eol: "
set listchars+=tab:\\u16EC\\u16EC\\u16EC
set listchars+=tab:\ \ \\u16EC
set listchars+=tab:\\u21e4\\u2500\\u21e5
set listchars+=tab:\\u2500\\u2500
set listchars+=trail:\\u16DC
set listchars+=leadmultispace:\\u16DC\\u16DC\\u16DC\\u16DC
set listchars+=leadmultispace:\ \ \ \\u16DC
set listchars+=leadmultispace:\ \ \ \\u0020
set listchars+=extends:…
set listchars+=precedes:\\u21e4
set listchars+=extends:\\u21e5
 " }}}

set list
set nolist


" {{{ mouse scroll
set mouse=nvh
set selectmode=mouse " ctrl-g to entrer visual
inoremap <ScrollWheelUp>   4<c-y>
inoremap <ScrollWheelDown> 4<c-e>
nnoremap <MiddleMouse>     i<MiddleMouse>

" }}}

" set foldtext=v:folddashes.substitute(getline(v:foldstart),'/\\*\\\|\\*/\\\|{{{\\d\\=','','g')
" }}} closes the fold the regex above opens
" {{{ generate foldtext
function s:generate_foldtext1()
	let margin = &fdc + &number * &numberwidth
	let extra = 0
	let wwin = winwidth(0) - margin - extra
	let hidden = v:foldend - v:foldstart
	let line = getline(v:foldstart)
	let csp = split(&commentstring, '%s')
	let comment1 = len(csp)>0 ? csp[0] : ' '
	let line = substitute(line, comment1 , ' ', '')

	let mark = split(&foldmarker, ',')
	let mark1 = len(mark) > 0 ? mark[0] : ''
	let line = substitute(line, mark1 , repeat(' ', len(mark1)), '')

 	let stab = strpart(repeat(' ', 99), 0, &tabstop)
 	let line = substitute(line, '\t', stab, 'g')

" {{{ zzz
 	let line = strpart(line, 0, wwin -len(hidden))
 	let fill = wwin - len(line) - len(hidden)

	let prefixlen = len(matchstr(line, '^\s*'))
	let line = strpart(line, prefixlen)
" }}}

	let left = '-'
	let left = '⏤'
	while prefixlen > 0 && strdisplaywidth(prefixs) < 3
		let left = '⏤'.prefixs
		let prefixlen -= 1
	endwhile

	" U+23E4 STRAIGHTNESS

 	return repeat(' ', prefixlen-2).left .' '
				\. line  . ' ⏤⏤⏤' .
				\. repeat(' ', fill-4) .
				\ hidden

 	" return line . ' '
" 				\ . repeat(' ', fillcharcount-3)
" 				\ . repeat('…', 3)
" 				\ .' '. hidden .' '
endfunction
set foldtext=s:generate_foldtext1()

" }}}
" }}}

" {{{ VIM-ONLY: state dirs and viminfo (nvim: shada set in opt.lua)

" {{{ state and backup
" call mkdir(expand('~/tmp/vimZ'), 'p', 0o700)
" call mkdir(expand('~/tmp/vimZ/backupZ'), 'p', 0o700)


if !has('nvim')
	call mkdir(expand('~/tmp/vimZ/undoZ'), 'p', 448) " 0o700
	call mkdir(expand('~/tmp/vimZ/swapZ'), 'p', 448) " 0o700
	let &backupdir = expand('~/tmp/vimZ/backupZ//')
	set nobackup

	set undofile
	let &undodir = expand('~/tmp/vimZ/undoZ//')
	set undolevels=1337

	"set swapfile
	set noswapfile
	let &directory = expand('~/tmp/vimZ/swapZ//')
	let &viminfofile = expand('~/tmp/vimZ/viminfoZ')
endif

"set directory=$MYVIMDIR/tmp//,$HOME/tmp//

" % buffers save/restore
set viminfo=%27,'133,<50,/202,:9801,<9950,s16,h,
set viminfo+=ra:,r:b,r/tmp
" ,r$HOME/tmp
"set viminfo+=n$HOME/tmp/viminfo

" }}}
" }}}


" {{{ statusline and tabline
if !has('nvim')
	set laststatus=2
	let Dirname = {-> join(reverse(reverse(split(fnamemodify(expand('%'), ":h:~"), '/'))[0:2]), '/')}
	set statusline=\       "help file flag
	set statusline +=%a      " argstatus
	set statusline +=%t      " filename
	set statusline +=%<
	set statusline +=\ in\ %{Dirname()}
	set statusline +=%=
	set statusline +=\       " help file flag
	set statusline +=%c,     " cursor column
	set statusline +=%l/%L   " cursor line/total lines
	set statusline +=\ %P    " percent through file

	" set statusline +=%r      " read only flag
	" set statusline +=%h      " help file flag
	" set statusline +=%M      " modified flag

endif
" }}}


" {{{ VIM-ONLY: colors and highlight overrides (nvim: colorscheme in genja/init)
" {{{ autogroup post-enter / reload
command! PostEnter :call s:post_vim_enter()
augroup PostEnter
  au!
  au SourcePost $MYVIMRC call s:post_vim_enter()
  au VimEnter * call s:post_vim_enter()
augroup END
function! s:post_vim_enter()
	hi StatusLine term=none cterm=none gui=none
	hi FoldColumn term=none cterm=none gui=none

	hi Folded term=none cterm=none gui=none
	hi ModMsg term=none cterm=none gui=none

	hi FoldColumn ctermbg=black ctermfg=8
	hi Folded     ctermbg=black ctermfg=8

	hi TablineSel guibg=black guifg=red
	hi Tabline    guibg=black guifg=red

	if getenv('VIM_TYPE') != 'lean'
		set background=dark
		colorscheme lunaperche
		if filereadable($MYVIMDIR."colors/colors.vim")
			source $MYVIMDIR/colors/colors.vim
		endif
	endif
endfunction
" }}}
" }}}

" {{{ VIM-ONLY: autocmds with side effects or that clash with genja
" BufWritePost re-sources $MYVIMRC (init.vim under nvim), FocusLost auto-writes,
" formatoptions-=t fights opt.lua, ClearSearch would wipe genja's augroup of
" the same name (auto.lua).
augroup WhateverVim
	au!
	au BufWritePost *colors.vim call s:post_vim_enter()
	au BufWritePost $MYVIMRC source $MYVIMRC
	au BufWritePost $MYVIMRC call s:post_vim_enter()
	au BufWinEnter * set formatoptions-=t
	au FocusLost * silent! if &modifiable write | endif
augroup end
" {{{ autogroup reset the search register after:
" - nohlsearch does not work in autocommands in old vim
" - [x] cursor movement in insert mode
" - [x] leaving netrw
augroup ClearSearch
	au!
	" au CursorMovedI * let @/ = ''
	if exists('#CursorMovedC')
	   "au CursorMovedC * let @/ = ''
	   au CursorMovedC * nohlsearch
	endif
	au WinLeave,BufLeave netrw let @/ = ''
	au TabLeave * let @/ = ''
augroup END
" }}}
" }}}

" {{{ VIM-ONLY: keymaps that clash with genja or nvim built-ins
" <Tab> = <C-i> in nvim (jumplist); <Esc>, <C-down>, <leader>?, <leader>z,
" <leader>.., <leader>j/, <leader>c, <leader>ei and the window maps are
" already defined in genja (map-zero, map-telescope, abdul-keymaps).
" {{{ keymaps tabs

if has('gui_running')
	execute "set <M-[>=\e["
	execute "set <M-]>=\e]"
	nnoremap <M-[> :tabprev<cr>
	nnoremap <M-]> :tabnext<cr>
else
	nnoremap <c-backspace> <cmd>tabprev<cr>
	nnoremap <tab>         <cmd>tabnext<cr>
	nnoremap <m-]>         <cmd>tabnext<cr>
	nnoremap <m-[>         <cmd>tabprev<cr>
endif

 " }}}
nnoremap  <silent><esc> <cmd>let @/ = ''<cr><esc>
nn <leader>z zMzvzz
" {{{ keymaps window
" Window: quit, only
nnoremap <c-w>1     :only<CR>
nnoremap <c-w>`     :quit<CR>
nnoremap <leader>w` :quit<CR>

" Window: next
nnoremap <leader>` <c-w>w
nnoremap <C-q>     <c-w>w

" Window: goto
nnoremap <C-left>  <c-w>h
nnoremap <C-down>  <c-w>j
nnoremap <C-up>    <c-w>k
nnoremap <C-right> <c-w>l
" Window: move
nnoremap <c-w><s-right> <c-w>L
nnoremap <c-w><s-left>  <c-w>R
" }}}

" {{{ keymap vim-oscyank (copy text)
" mintty: +(mittyrc / config) AllowSetSelection=yes

nmap <leader>c <Plug>OSCYankOperator
nmap <leader>cc <leader>c_
vmap <leader>c <Plug>OSCYankVisual
" }}}

" {{{ toggle comments with tpope/vim-commentary
nnoremap <c-/> :norm gcc<cr>j
vnoremap <c-/> :norm gcc<cr>j
nnoremap <c-down> :norm gcc<cr>j
vnoremap <c-down> :norm gcc<cr>j
" }}}

" {{{ <leader> jump to…
nnoremap <leader>/ <cmd>Lines<cr>
nnoremap <leader>j/ <cmd>Lines<cr>
nnoremap <leader>.. :&&<CR>
" }}}

" {{{ <leader>questionmark to lookup help/man
nnoremap <leader>? K
nnoremap <localleader>? K
" }}}

" {{{ <leader>edit …
" {{{ vimrc
nnoremap <leader>ei <cmd>tabedit $MYVIMRC<cr>
" }}}
" {{{ <.> dir
nnoremap <leader>e. <cmd>edit %:p:h<cr>
nnoremap <leader>et <cmd>tabedit %:p:h<cr>
" }}}
" {{{ <..> dir
noremap <c--> <cmd>edit %:p:h<cr>
noremap <c-=> <cmd>edit %:p:h<cr>
" }}}
" }}}
" }}}

" {{{ VIM-ONLY: plugins (vim-plug), curl downloads, plugin config
" {{{ vimlog
function! s:vimlog(msg)
	redir >> /tmp/vimlog
	silent echo a:msg
	redir END
endfunction
" }}}

" {{{ Bootstrap vim-plug and fzf and stuff
" {{{ curlf
function! s:curlf(filepath, url)
	if !filereadable(expand(a:filepath))
		call system(printf('curl --create-dirs -sfL %s -o %s', shellescape(a:url), shellescape(expand(a:filepath))))
		" For better cross-platform compatibility, especially on Windows, consider wrapping call system(...) with executable('curl') or a fallback like fetch().
		redraw
	endif
endfunction " }}}
" {{{ curld
function! s:curld(dict)
	let args = ''
	for [f, u] in items(a:dict)
		let f = expand(f)
		if !filereadable(f)
			silent! echo 's:curld(): ' . f
			let args = args . printf(' %s -o %s', shellescape(u), shellescape(f))
			" silent echo "getting " . f
			call s:vimlog("getting N " . f)
		endif
	endfor
	if args != ""
		call system(printf('curl --create-dirs -sfL %s', l:args))
	endif
endfunction " }}}

" {{{ iPlug
" {{{ PopupMessage()
function! PopupMessage(msg)
	call s:vimlog('plugindir does not exist')
    if exists(':echow') " Vim 9 feature
        execute 'echow ' . string(a:msg)
    elseif has('nvim')
        call luaeval('vim.notify(_A, vim.log.levels.INFO)', a:msg)
    else
        echomsg a:msg
    endif
endfunction
" }}}

function! s:iPlug(autoload_plug_vim, url='https://raw.githubusercontent.com/junegunn/vim-plug/refs/heads/master/plug.vim')
	if filereadable(expand(a:autoload_plug_vim))
	" {{{ is installed ? decalre and load plugins
		" {{{ declare plugins
		" if exists('*plug#begin')
			call plug#begin()
			" Plugz
			Plug 'tpope/vim-sensible'
			Plug 'tpope/vim-commentary'
			Plug 'tpope/vim-surround'
			Plug 'tpope/vim-vinegar'
			Plug 'markonm/traces.vim' " mark replacements in realtime
			Plug 'junegunn/vim-easy-align' " :normal gaip*=
			" {{{ Plug Fzf
			Plug 'junegunn/fzf.vim'
			if has('win64')
				Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
			else
				Plug 'junegunn/fzf'
			endif
			"  }}}
			Plug 'ojroques/vim-oscyank' " paste-copy via ssh
			Plug 'vim-scripts/QuickBuf' " simparu bufferu serector

			Plug 'romainl/vim-qf'
			" Plug 'vim-scripts/taglist.vim' " needs ctags

			" Plug 'SilentGlasses/colorhighlighter' " render detected colors
			" Plug 'KabbAmine/vCoolor.vim' " color picker (needs os gui)


			" learn-vim https://github.com/dahu/LearnVim
			" learn-vim Type :helptags ~/.vim/doc/ from within Vim.
			" learn-vim Type :help learnvim to get started.

			" templates? dahu/Area-41 plugin skeleton
			" templates? /aperezdc/vim-template
			" templates? let g:templates_no_autocmd = 1


			" grandfather of fzf
			" - redundancy with fzf
			" - wants more plugins for more sources
			Plug 'Shougo/unite.vim'
			" Plug 'Shougo/vimproc.vim', {'do' : 'make'}
			" Plug 'Shougo/neomru.vim'



			" Plug 'SilentGlasses/colorhighlighter' " render detected colors
			" Plug 'KabbAmine/vCoolor.vim' " color picker (needs os gui)
			" Plug 'lpenz/vimcommander' " basic file manager
			

			" themez Plug 'chriskempson/base16-vim'
			" themez Plug 'dracula/vim', { 'as': 'dracula' }
			" themez Plug 'arcticicestudio/nord-vim'
			" themez Plug 'ayu-theme/ayu-vim'"
			" themez Plug 'jschmold/sweet-dark.vim'
			" themez Plug 'embark-theme/vim', { 'as': 'embark', 'branch': 'main' }
			" themez Plug 'catppuccin/vim', { 'as': 'catppuccin' }

			" checkout Plug 'jlanzarotta/bufexplorer'
			" checkout Plug 'vim-scripts/diffchanges.vim'
			" checkout Plug 'mhinz/vim-startify'
			" checkout Plug 'tpope/vim-fugitive'
			" checkout Plug 'airblade/vim-gitgutter'
			" checkout Plug 'ctrlpvim/ctrlp.vim'
			" checkout Plug 'jeffkreeftmeijer/vim-numbertoggle'
			" checkout Plug 'vim-scripts/DeleteTrailingWhitespace'
			" checkout Plug 'mrk21/yaml-vim'


			Plug 'junegunn/vader.vim'
			" testing "Plug 'junegunn/vader.vim'
			" for java Plug 'artur-shaik/vim-javacomplete2' " needs configuration
			" for html Plug 'mattn/emmet-vim'
			" for php phpcomplete.vim 
			" for linting syntastic

			" test 'tomtom/tlib.....'
			" test 'tomtom/autolinker_vim'
			" test 'tomtom/foldtext_vim'
			" test 'tomtom/tcomment_vim'
			" test 'tomtom/tfiles_vim'
			" test 'tomtom/tmru_vim'
			" test 'tomtom/trag_vim'
			" test 'tomtom/tregisters_vim'
			" test 'tomtom/tstatus_vim'

			" checkout Plug inkarkat/vim-SyntaxRange
			" checkout Plug inkarkat/vim-mark

            " meh Plug 'inkarkat/vim-EnhancedJumps' " -- too mush chording
			" meh Plug 'inkarkat/vim-ingo-library'  " -- microfunctions

			" nostalgia / code examples Plug 'lpenz/vimcommander' " basic file manager


			call plug#end() " }}}
		" else
			" echo 'NO PLUG#BEGIN'
		" endif
		" {{{ no plugin dir, force reinstall
		if !isdirectory(fnamemodify($MYVIMRC,':h').'/plugged')
			call PopupMessage('plugindir does not exist')
			nnoremap j       <cmd>close<cr><cmd>quit<cr>
			nnoremap q       <cmd>close<cr><cmd>quit<cr>
			nnoremap <c-w>   <cmd>close<cr><cmd>quit<cr>
			call s:vimlog(':PlugInstall --sync')
			if has('win64')
				:PlugInstall --sync
			else
				call system("for i in {1..3}; do vim -es  -i NONE -U NONE  '+PlugInstall' '+PlugInstall --sync' +qall ; done ; echo")
				call system("reset")
			endif
		endif " }}}
	" }}}
	else
		call s:vimlog("iPlug(): nofile! «".expand(a:autoload_plug_vim)."»")
		call system("mkdir -p ".
					\ " $MYVIMDIR/tmp/swap" .
					\ " $MYVIMDIR/tmp/backup" .
					\ " $MYVIMDIR/tmp/undo")
		" {{{ install autoload/plug.vim
		call s:curlf(a:autoload_plug_vim, a:url)
		call s:vimlog("vim '+PlugInstall --sync' +qall") " not available yet?

		echo "\njunegunn/vim-plug installed?"
		quit " }}}
		"}}}
	endif
endfunction
if !has('nvim')
	" nvim should have its own plugins
	call s:iPlug(fnamemodify($MYVIMRC,':h').'/autoload/plug.vim') " }}}
endif

" {{{ curl stuff
" {{{ plunder github raw
if !has('nvim')
	call  s:curld({
				\ '$MYVIMDIR/plugin/toggle-ui-elements.vim'   : 'https://raw.githubusercontent.com/muellan/vim-toggle-ui-elements/refs/heads/master/plugin/toggle_ui_elements.vim',
				\ '$MYVIMDIR/after/ftplugin/qf.vim'           : 'https://raw.githubusercontent.com/muellan/vim-toggle-ui-elements/refs/heads/master/after/ftplugin/qf.vim',
				\ '~/.local/dot/bash/wsi-fzf-key-bindings.sh' : 'https://raw.githubusercontent.com/junegunn/fzf/refs/heads/master/shell/key-bindings.bash',
				\ '~/.local/bin/fzf-tmux'                     : 'https://raw.githubusercontent.com/junegunn/fzf/refs/heads/master/bin/fzf-tmux',
				\ '~/.local/bin/yadm'                         : 'https://raw.githubusercontent.com/yadm-dev/yadm/refs/heads/develop/yadm',
				\ '~/.local/bin/transcrypt'                   : 'https://raw.githubusercontent.com/elasticdog/transcrypt/refs/heads/main/transcrypt',
				\}) " }}}
	" \ '~/.local/install-fzf'                   : 'https://raw.githubusercontent.com/junegunn/fzf/refs/heads/master/install',
	" {{{ download fzf binary
	if ! filereadable(expand('~/.local/bin/fzf'))
		if !has('win64')
			call system('bash ~/.vim/plugged/fzf/install --no-zsh --no-fish --no-completion --xdg --key-bindings --no-update-rc --bin')
			call system('ln ~/.vim/plugged/fzf/bin/fzf ~/.local/bin/fzf')
		else
			" todo: handle this on windows
		endif
		" silent! echo "got fzf bin"
	endif " }}}
endif
 " }}}
" {{{ plugin  config variables

" {{{ plugin fzf config
map <f1> <cmd>FZF<cr>
map <s-f1> <cmd>Rg<cr>
command -bang -nargs=* Lines call fzf#vim#buffer_lines(<q-args>, <bang>0)
command -bang -nargs=* Linesg call fzf#vim#lines(<q-args>, <bang>0)
let g:fzf_layout = { 'window': '-tabnew' }
"
function! s:build_quickfix_list(lines)
	call setqflist(map(copy(a:lines), '{ "filename": v:val, "lnum": 1 }'))
	copen
	cc
endfunction
let g:fzf_action = {
			\ 'ctrl-q': function('s:build_quickfix_list'),
			\ 'ctrl-t': 'tab split',
			\ 'ctrl-x': 'split',
			\ 'ctrl-v': 'vsplit' }
" }}}

" {{{ plugin easy-align config
" {{{ define ga
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)
" }}}

vnoremap <leader>aE       <plug>EasyAlign
nnoremap <leader>aa
			\ <cmd>:norm gaip\<space>:<cr>
			\ <cmd>:norm gaip*:<cr>
			\ <cmd>:norm gaip*,<cr>

xnoremap <leader>a:       :EasyAlign *:<cr>
xnoremap <leader>a;       :EasyAlign *;<cr>
xnoremap <leader>a<space> :EasyAlign *<space>\<cr>
xnoremap <leader>a=       :EasyAlign *=<cr>

nnoremap <leader>a:       :norm gaip*:<cr>
nnoremap <leader>a;       :norm gaip*;<cr>
nnoremap <leader>a<space> :norm gaip*\<space>\<cr>
nnoremap <leader>a=       :norm gaip*=<cr>

if !exists('g:easy_align_delimiters')
	let g:easy_align_delimiters = {}
else
	let g:easy_align_delimiters[';'] = { 'pattern': ';', 'stick_to_right': 1 }
endif
" }}}

" {{{ plugin netrw config
let g:netrw_banner         = 0
let g:netrw_liststyle      = 2 " list / columns
let g:netrw_liststyle      = 1 " list + details
let g:netrw_liststyle      = 3 " tree
let g:netrw_winsize        = 30 " only 30% for file listing when vertically splitting
let g:netrw_sizestyle      = 'H'
let g:netrw_browse_split   = 3 " new tab
let g:netrw_browse_split   = 0 " same win
let g:netrw_list_hide = '\(^\|\s\s\)\zs\.\S\+'

let g:netrw_sort_by        = 'time'
let g:netrw_sort_direction = 'reverse'

let g:netrw_sort_by        = 'name'
let g:netrw_sort_direction = 'normal'
let g:netrw_home = '$MYVIMDIR/tmp'
let g:netrw_dirhistmax = 99


"let g:netrw_list_cmd = "ls -Fla"   " -F = type flags, -l = long, -a = all
" }}}

" }}}

" {{{ Syntastic (maybe)
" " {{{ JevaScrapt
" "let g:syntastic_jshint_exec='C:\Users\jaroslav\AppData\Roaming\npm\jshint.cmd'
" "let g:syntastic_jshint_exec='/home/jaroslav/lib/node_modules/.bin/jshint'
" "let g:syntastic_javascript_checkers = ['jshint', 'eslint']
" let g:syntastic_javascript_checkers = ['eslint']
" let g:syntastic_javascript_checkers = ['cat']
" let g:syntastic_javascript_checkers = ['jshint']
" " }}}
" 
" let g:syntastic_quiet_messages = { "type": "style" }
" let g:syntastic_sh_checkers = ['shellcheck']
" let g:syntastic_php_checkers = ['php', 'phpcs' ]
" let g:syntastic_java_checkers = ['javac']
" let g:syntastic_yaml_checkers = ['yamllint']
" "let g:syntastic_yaml_yamllint_args = '-c ~/.config/yamllint.yml'
" "let g:syntastic_html_jshint_args="-extract"
" " let b:syntastic_skip_checks = 0
" }}}

" {{{ NERDTree (probably not)
" "if exists(":NERDTree")
" "	let g:NERDTreeMapOpenInTabSilent = '<2-LeftMouse>'
" "endif
" let g:NERDTreeWinPos="right"
" let g:NERDTreeStatusline=1
" let g:NERDTreeMouseMode=3 " single click on all
" let g:NERDTreeQuitOnOpen=1
" let g:NERDTreeHighlightCursorline=0
" let g:NERDTreeChDirMode=2
" let g:NERDTreeMinimalUI=1
" let g:NERDTreeAutoCenter=0
" let g:NERDTreeShowBookmarks=1
" "function! MY_NERD_settings()
" "	"let g:NERDTreeMapOpenInTabSilent = '<2-LeftMouse>'
" "	:let g:NERDTreeStatusline=1
" "	:let g:NERDTreeMouseMode=0
" "	:let g:NERDTreeQuitOnOpen=1
" "	:let g:NERDTreeHighlightCursorline=0
" "	:let g:NERDTreeChDirMode=2
" "	:let g:NERDTreeMinimalUI=1
" "	:let g:NERDTreeAutoCenter=0
" "endfunction
" "autocmd VimEnter * :call MY_NERD_settings()
" }}}


    let g:qf_shorten_path = 3
    let g:qf_mapping_ack_style = 1

" {{{ Tlist
let Tlist_Auto_Update = 1
let Tlist_GainFocus_On_ToggleOpen = 1
let Tlist_Use_Right_Window = 1
let Tlist_Use_SingleClick = 1
let Tlist_WinWidth = 40
let Tlist_Close_On_Select = 0
let Tlist_Enable_Fold_Column = 0
let Tlist_File_Fold_Auto_Close = 1
let tlist_php_settings = 'php;c:class;f:function;j:js_functions;d:constants;v:variables'
" }}}

" {{{ auto-yank with osc-yank
if (!has('nvim') && !has('clipboard_working'))
    " In the event that the clipboard isn't working, it's quite likely that
    " the + and * registers will not be distinct from the unnamed register. In
    " this case, a:event.regname will always be '' (empty string). However, it
    " can be the case that `has('clipboard_working')` is false, yet `+` is
    " still distinct, so we want to check them all.
    let s:VimOSCYankPostRegisters = ['', '+', '*']
    " copy text to clipboard on both (y)ank and (d)elete
    let s:VimOSCYankOperators = ['y'] "['y', 'd']
    function! s:VimOSCYankPostCallback(event)
        if index(s:VimOSCYankPostRegisters, a:event.regname) != -1
            \ && index(s:VimOSCYankOperators, a:event.operator) != -1
            call OSCYankRegister(a:event.regname)
        endif
    endfunction
    augroup VimOSCYankPost
        autocmd!
        autocmd TextYankPost * call s:VimOSCYankPostCallback(v:event)
    augroup END
endif
" }}}
" }}}

