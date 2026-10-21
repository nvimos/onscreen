

-- [[ ftplugins ]]

vim.g.dosbatch_colons_comment = true


--[[ plugin settings ]]--
-- set in init.vim
-- vim.g.genja_enable_autoresource = false
-- vim.g.genja_enable_autoresource = true -- genja-autoresource.lua



--[[ netrw ]]--
-- more: https://vonheikemen.github.io/devlog/tools/using-netrw-vim-builtin-file-explorer/
-- more2: https://github.com/prichrd/netrw.nvim
--
--vim.g.netrw_browse_split = 0
--vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3 -- tree
-- vim.g.netrw_browse_split = 4 -- behave like P (preview in same window)
vim.g.netrw_winsize = 30 -- only 30% for file listing when vertically splitting

vim.g.netrw_sizestyle = 'H'
vim.g.netrw_sort_by        = 'time'
vim.g.netrw_sort_direction = 'reverse'

vim.g.netrw_sort_by        = 'name'
vim.g.netrw_sort_direction = 'normal'

vim.g.netrw_localmovecmd = (function() if vim.fn.has('win32') == 1 then return 'move'; else return 'mv'; end end)()


--[[ status bars , lines

	%{} not expanded as statusline
	%{%}    expanded as statusline

]]




--[[ vim options ]]--

vim.opt.shada = [[%27,'133,<50,/202,:9801,<9950,s16,h,ra:,r:b,r/tmp]]

vim.opt.inccommand = "nosplit"

vim.opt.synmaxcol = 1020

vim.opt.shortmess= 'flmnxS'
vim.opt.shortmess:append('I') -- no intro screen (charity nag); genja/intro.lua draws one without it
vim.opt.shortmess:append("F")


-- a restored terminal reruns its command (e.g. claude --session-id, which then clashes);
-- claude comes back through the session marker instead (genja/claude.lua)
vim.opt.sessionoptions:remove('terminal')

vim.o.laststatus = 3 -- only one status line even with several windows
-- {{{ folds (from vimrc.almalinux.vim)
vim.opt.foldcolumn = '3'                     -- fdc=2 ; overrides the '2' above
vim.opt.fillchars = 'fold:│'
vim.opt.fillchars = 'fold:·'
vim.opt.fillchars = vim.opt.fillchars + 'stl: '      -- statusline
vim.opt.fillchars = vim.opt.fillchars + 'stlnc:─'    -- statusline (non-current)
vim.opt.fillchars = vim.opt.fillchars + 'vert::'     -- v:version >= 800 is always true in nvim
vim.opt.fillchars = vim.opt.fillchars + 'vert:│'     -- v:version >= 800 is always true in nvim


-- vim.opt.fillchars:append({ vert = '  │' }) -- Two spaces before the line


vim.opt.fillchars = vim.opt.fillchars + 'foldopen:▼'
vim.opt.fillchars = vim.opt.fillchars + 'foldclose:▶'
vim.opt.fillchars = vim.opt.fillchars + 'foldsep:│'
vim.opt.foldopen:remove 'block'

-- maybe-todo: redo this for nvim
-- vim.cmd[[
-- " {{{ command WrapFold -- insert fold marker around selection
-- function! s:wrap_fold_with_marker(fold_title='NamelessFold') range
--   let csp = split(&commentstring, '%s')
--   if len(csp) == 2
--     let prefix = substitute(csp[0], '\s*$', '', '')
--     let suffix = substitute(csp[1], '^\s*', '', '')
--   else
--     let suffix = ''
--     let prefix = substitute(&commentstring, '%s', '', 'g')
--   endif
--   " call append(a:firstline - 1, printf('%s %s %s', prefix, repeat('{', 3), a:fold_title))
--   let m1 = repeat('{', 3)
--   let m2 = repeat('}', 3)
--   let a = printf('%s %s %s', prefix, m1, a:fold_title)
--   let b = printf('%s %s', prefix, m2)
--   call append(a:firstline - 1, a)
--   call append(getpos("'>")[1], b)
-- endfunction
-- command! -range -nargs=* WrapFold call <SID>wrap_fold_with_marker(<f-args>)
-- " }}}
-- " {{{ generate foldtext
-- function s:generate_foldtext1()
-- 	let margin = &fdc + &number * &numberwidth
-- 	let extra = 0
-- 	let wwin = winwidth(0) - margin - extra
-- 	let hidden = v:foldend - v:foldstart
-- 	let line = getline(v:foldstart)
-- 	let csp = split(&commentstring, '%s')
-- 	let comment1 = len(csp)>0 ? csp[0] : ' '
-- 	let line = substitute(line, comment1 , ' ', '')
-- 	let mark = split(&foldmarker, ',')
-- 	let mark1 = len(mark) > 0 ? mark[0] : ''
-- 	let line = substitute(line, mark1 , repeat(' ', len(mark1)), '')
--  	let stab = strpart(repeat(' ', 99), 0, &tabstop)
--  	let line = substitute(line, '\t', stab, 'g')
-- " {{{ zzz
--  	let line = strpart(line, 0, wwin -len(hidden))
--  	let fill = wwin - len(line) - len(hidden)
-- 	let prefixlen = len(matchstr(line, '^\s*'))
-- 	let line = strpart(line, prefixlen)
-- " }}}
-- 	let left = '-'
-- 	let left = '⏤'
-- 	while prefixlen > 0 && strdisplaywidth(prefixs) < 3
-- 		let left = '⏤'.prefixs
-- 		let prefixlen -= 1
-- 	endwhile
-- 	" U+23E4 STRAIGHTNESS
--  	return repeat(' ', prefixlen-2).left .' '
-- 				\. line  . ' ⏤⏤⏤' .
-- 				\. repeat(' ', fill-4) .
-- 				\ hidden
-- 
--  	" return line . ' '
-- " 				\ . repeat(' ', fillcharcount-3)
-- " 				\ . repeat('…', 3)
-- " 				\ .' '. hidden .' '
-- endfunction
-- set foldtext=s:generate_foldtext1()
-- 
-- ]]


-- }}}




vim.opt.hidden = true

vim.o.modeline = true
vim.o.modelines = 2

-- vim.o.listchars = 'leadmultispace:>   ·,lead:>,multispace:· ,space:·,tab: '


vim.o.showbreak = '⬉      ' -- display after wrapped
vim.o.showbreak = '`      ' -- display after wrapped

-- {{{ tab replcement character
if vim.fn.has('gui_running') == 1 then
	vim.o.listchars = 'eol:`,tab: ' -- todo: make an easy-swap pluqin in telescope (myeasy-swap)
	vim.o.listchars = 'eol:󰭿,tab: '
	vim.o.listchars = 'tab: '
else
	vim.o.listchars = 'eol:`'
end
---- how it looks....
----....====++++
                                                -- multispace
												--[[ tabs
z                                               
	-tab
 ---space]]
-- vim.opt.listchars:append('space: ,multispace:·   ') -- multispace is distracting more than anything
vim.opt.listchars:append('space: ,multispace:    ')
vim.opt.listchars:append('lead: ,leadmultispace:·   ')
-- vim.opt.listchars:append('trail:󱁐,')
vim.opt.listchars:append('trail:_,')
vim.opt.listchars:append('extends:→,precedes:←')
vim.opt.listchars:append('tab: ')

vim.o.list = true
-- }}}



vim.o.shiftwidth = 4

vim.o.backupcopy = "yes" -- copy to backup location first, overwrite the original file directly -- ntfs symlink workaround
vim.o.backup = false
vim.o.swapfile = false
vim.opt.undodir = (vim.fn.stdpath('data') .. '/undodir'):gsub([[\]], [[/]])
vim.opt.undofile = true




-- vim.o.ruler = true -- the cursor positon in statusline: line,col (Top|Bot)  %62
-- vim.o.rulerformat = ''

vim.o.fileencoding = "utf-8"
vim.o.ignorecase = true
vim.o.mouse = "a"
vim.o.showmode = false
vim.o.showtabline = 2 -- 0: never -- 1: iff >= 2 tabs -- 2: always


-- how many lines to show of the command...
vim.o.cmdheight = 1
vim.o.cmdheight = 4
vim.o.cmdheight = 2

vim.o.smartcase = true
vim.o.smartindent = true
vim.o.splitbelow = true
vim.o.splitright = true

vim.o.timeoutlen = 300                        -- time to wait for a mapped sequence to complete (in milliseconds)
vim.o.updatetime = 300                        -- faster completion (4000ms default)
vim.o.updatetime = 200


vim.o.expandtab = false                       -- convert tabs to spaces, if true
vim.o.shiftwidth = 4                          -- the number of spaces inserted for each indentation
vim.o.tabstop = 4                             -- insert 2 spaces for a tab

vim.o.cursorline = false                       -- highlight the current line

vim.o.number = false                           -- set numbered lines
vim.o.relativenumber = false                  -- set relative numbered lines
vim.o.numberwidth = 3                         -- set number column width to 2 {default 4}

vim.o.signcolumn = "yes"                      -- always show the sign column, otherwise it would shift the text each time
vim.o.wrap = false                            -- display lines as one long line
vim.o.wrapmargin = 1                          -- hard-wraps typed text 1 column before the window edge
vim.o.linebreak = true                        -- companion to wrap, don't split words
vim.o.scrolloff = 4                           -- minimal number of screen lines to keep above and below the cursor
vim.o.sidescrolloff = 4                       -- minimal number of screen columns either side of cursor if wrap is `false`
-- vim.o.guifont = "monospace:h17"               -- the font used in graphical neovim applications

-- vim.opt.guioptions:append('a')
-- https://vi.stackexchange.com/questions/33182/what-neovim-guis-have-gui-scrollbars-as-described-in-vim-under-h-gui-scrollbars


vim.o.whichwrap = "bs<>[]hl"                  -- which "horizontal" keys are allowed to travel to prev/next line
-- <> is   in normal and visual
-- [] is   in insert and replace
-- hl are also affecting how x works!
vim.o.whichwrap = "b[]"                       -- prefer the feel closer to original vi



vim.opt.iskeyword:append("-")


-- -- vim.opt.shortmess = "ilmnrx"                        -- flags to shorten vim messages, see :help 'shortmess'
-- vim.opt.shortmess:append "c"                           -- don't give |ins-completion-menu| messages
-- vim.opt.iskeyword:append "-"                           -- hyphenated words recognized by searches
-- vim.opt.formatoptions:remove({ "c", "r", "o" })        -- don't insert the current comment leader automatically for auto-wrapping comments using 'textwidth', hitting <Enter> in insert mode, or hitting 'o' or 'O' in normal mode.
-- vim.opt.runtimepath:remove("/usr/share/vim/vimfiles")  -- separate vim plugins from neovim in case vim still in use


vim.opt.formatoptions:remove({ "c", "r", "o" })        -- don't insert the current comment leader automatically for auto-wrapping comments using 'textwidth', hitting <Enter> in insert mode, or hitting 'o' or 'O' in normal mode.
vim.opt.formatoptions:append {'l', 'b'}
vim.opt.formatoptions:append 'w'
vim.opt.formatoptions:append 'q'
vim.opt.formatoptions:append 't'
vim.opt.formatoptions:append 'n'

--- lsp performance
vim.g.lsp_semantic_enabled = 0
vim.g.lsp_format_sync_timeout = 1000


-- context menu
-- context menu luaish -- vim.api.nvim_create_user_command('ToggleWrap', function()
-- context menu luaish -- 	  vim.opt.wrap = not vim.opt.wrap:get()
-- context menu luaish -- end, {})
-- context menu luaish -- vim.cmd('amenu PopUp.Toggle\\ Wrap :ToggleWrap<CR>')



-- vim.o.listchars = 'space:_,tab:⩺ '
-- vim.o.listchars = 'space:_,tab:⨡ '
-- vim.o.listchars = 'tab:⨡ '
-- vim.o.listchars = 'tab:⨽ '
-- vim.o.listchars = 'tab:┐ '
-- vim.o.listchars = 'space:,tab: '
-- vim.o.listchars = 'space:·,tab: '
-- vim.o.listchars = 'space:ˉ,tab: '
-- vim.o.listchars = 'space:ˉ,tab: '
-- vim.o.listchars = 'space:‾,tab: '
-- vim.o.listchars = 'space:_,tab: '

-- U+005F - LOW LINE: _
-- U+203E - OVERLINE: ‾
-- U+FF3F - FULLWIDTH LOW LINE: ＿
-- U+0332 - COMBINING LOW LINE: ′̲ (This combines with the character before it)

-- U+00B7 - MIDDLE DOT: ·
-- U+2022 - BULLET: •
-- U+2219 - BULLET OPERATOR: ∙
-- U+00B4 - ACUTE ACCENT: ́ (Slightly raised)
-- U+02D9 - DOT ABOVE: ˙ (Above)
-- U+02C9 - MODIFIER LETTER MACRON: ˉ (Above)
-- U+02D0 - MODIFIER LETTER TRIANGULAR COLON: ː (Above)
--vim.opt.showbreak = '\\      ' 
-- vim.opt.showbreak = '⦚      '
-- vim.opt.showbreak = '⧙      '
-- vim.opt.showbreak = '⧛      '
-- vim.opt.showbreak = '⧚      '
-- vim.opt.showbreak = '⧘      '
-- vim.opt.showbreak = '⬈      '
-- vim.opt.showbreak = '⬊      '
-- vim.opt.showbreak = '⬋      '
-- vim.opt.showbreak = '⬎      '
-- vim.opt.showbreak = '⬏      '
-- vim.opt.showbreak = '⬐      '
-- vim.opt.showbreak = '⬑      '
-- | 10214   | \u27e6  | ⟦     |
-- | 10215   | \u27e7  | ⟧     |
-- | 10216   | \u27e8  | ⟨     |
-- | 10217   | \u27e9  | ⟩     |
-- | 10218   | \u27ea  | ⟪     |
-- | 10219   | \u27eb  | ⟫     |
-- | 10220   | \u27ec  | ⟬     |
-- | 10221   | \u27ed  | ⟭     |
-- | 10222   | \u27ee  | ⟮     |
-- | 10223   | \u27ef  | ⟯     |

-- | 09252   | \u2424  | ␤     |
-- | 09226   | \u240a  | ␊     |
-- | 09773   | \u262d  | ☭     |
-- vim.opt.showbreak = '⤴      '
-- vim.opt.showbreak = '⤣      '
