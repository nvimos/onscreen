-- vim: fdm=marker foldlevel=0

vim.g.dosbatch_colons_comment = true --  2026-10: what is this for

-- plugin settings {{{

-- netrw {{{

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

-- }}}

-- }}}

-- {{{ file encoding, format
vim.o.fileencoding = "utf-8"
-- }}}

-- shada: what is saved between sessions {{{
--   %27    buffer list, up to 27 buffers (only when nvim starts without file args)
--   '133   marks for the last 133 files
--   <50    at most 50 lines per register
--   /202   search history entries
--   :9801  command-line history entries (capped by 'history', default 10000)
--   <9950  repeats <, overrides <50 above: 9950 lines per register
--   s16    skip items larger than 16 KiB
--   h      no 'hlsearch' highlight when the shada is loaded
--   ra:    no marks for paths starting with a: (removable drive)
--   r:b    no marks for paths starting with ':b' (likely meant rb:)
--   r/tmp  no marks for paths starting with /tmp
vim.opt.shada = [[%27,'133,<50,/202,:9801,<9950,s16,h,ra:,r:b,r/tmp]]
-- }}}

-- {{{ output, reporting
vim.opt.shortmess = 'fnxlmS'
-- 'f' -- (3 of 5) not (file 3 of 5)              ; no-op since nvim 0.10, always on
-- 'n' -- [New] not [New File]                    ; no-op since nvim 0.10, always on
-- 'x' -- [unix] not [unix format]                ; no-op since nvim 0.10, always on
-- 'l' -- 999L, 888B not 999 lines, 888 bytes
-- 'm' -- [+] not [Modified]
-- 'S' -- no search count [1/5]

---@diagnostic disable-next-line: param-type-mismatch
vim.opt.shortmess:append('IF') -- no intro screen (charity nag); genja/ext/intro.lua draws one without it
-- }}}

-- {{{ modeline
vim.o.modeline = true
vim.o.modelines = 2
-- }}}

-- {{{ swapile, backup, undodir
vim.o.backupcopy = "yes" -- copy to backup location first, overwrite the original file directly -- ntfs symlink workaround
vim.o.backup = false
vim.o.swapfile = false
vim.opt.undodir = (vim.fn.stdpath('data') .. '/undodir'):gsub([[\]], [[/]])
vim.opt.undofile = true
-- }}}

-- {{{ meh
-- vim.o.ruler = true -- the cursor positon in statusline: line,col (Top|Bot)  %62
-- vim.o.rulerformat = ''
-- }}}

-- search case sensitivity {{{
vim.o.ignorecase = true -- case insensitive search by default
vim.o.smartcase = true
-- }}}

-- statusline, tabline {{{
vim.o.showmode = false
vim.o.showtabline = 2 -- 0: never -- 1: iff >= 2 tabs -- 2: always
-- }}}

-- ui, layout, behavior {{{

vim.opt.sessionoptions:remove('terminal') -- dont save terminals in sessions (prefer to restart apps manually e.g. claudefterm); s:/save: keep idle shells (lua/genja/ext/term.lua mksession)

vim.o.laststatus = 3 -- only one status line even with several windows

vim.opt.inccommand = 'nosplit' -- show interactive substitutions incrementally in the buffer.

vim.o.shiftwidth = 4

vim.opt.hidden = true -- keep buffers loaded with state, undo info

vim.o.mouse = "a"
vim.o.cmdheight = 2 -- :cmd «box» height
vim.o.splitbelow = true -- new (focused) window below current 
vim.o.splitright = true -- new (focused) window right of current


vim.o.number         = false -- set numbered lines
vim.o.relativenumber = false -- set relative numbered lines
vim.o.numberwidth    = 3     -- set number column width to 2 {default 4}

vim.o.cursorline = false -- highlight the current line

vim.o.signcolumn = "yes" -- always show the sign column, otherwise it would shift the text each time

vim.o.wrap       = false -- display lines as one long line
-- }}}

-- diff, plain look {{{

-- The diffview panels and layout are in lua/lazyp/git/diffview.lua; the filler
-- line character is in opt-listchars.lua. Don't combine `linematch:100` with `inline:`.
vim.opt.diffopt:append('algorithm:histogram')
-- }}}

-- edit and input behavior, navigation {{{

vim.o.updatetime = 200 -- ms to wait for macro to complete e.g. <leader>mGc

vim.o.smartindent = true

vim.o.expandtab  = false -- convert tabs to spaces, if true
vim.o.shiftwidth = 4     -- the number of spaces inserted for each indentation
vim.o.tabstop    = 4     -- insert 2 spaces for a tab

vim.o.wrapmargin    = 1    -- hard-wraps typed text 1 column before the window edge
vim.o.linebreak     = true -- companion to wrap, don't split words
vim.o.scrolloff     = 4    -- minimal number of screen lines to keep above and below the cursor
vim.o.sidescrolloff = 4    -- minimal number of screen columns either side of cursor if wrap is `false`

vim.o.whichwrap = "bs<>[]hl"                  -- which "horizontal" keys are allowed to travel to prev/next line
-- <> is   in normal and visual
-- [] is   in insert and replace
-- hl are also affecting how x works!
vim.o.whichwrap = "b[]"                       -- prefer the feel closer to original vi


vim.opt.iskeyword:append("-") -- hyphenated words recognized by searches

-- }}}

-- {{{ editing formatoptions
-- no comment on newline {{{
vim.opt.formatoptions:remove 'c' -- no auto-wrap of comments at 'textwidth'
vim.opt.formatoptions:remove 'r' -- no comment leader after <Enter> in insert mode
vim.opt.formatoptions:remove 'o' -- no comment leader after o / O
-- }}}


-- {{{
vim.opt.formatoptions:append 'l' -- do not break too long lines
vim.opt.formatoptions:append 'b' -- wrap only at blanks typed in this insert
vim.opt.formatoptions:append 'w' -- trailing space means the paragraph continues
vim.opt.formatoptions:append 'q' -- allow gq on comments
vim.opt.formatoptions:append 't' -- auto-wrap text at 'textwidth'
vim.opt.formatoptions:append 'n' -- recognise numbered lists when formatting
-- }}}


-- {{{ performance
-- {{{ performance : lsp
-- vim.g.lsp_semantic_enabled = 0
-- vim.g.lsp_format_sync_timeout = 1000


-- }}}

vim.opt.synmaxcol = 1020

-- }}}


-- -- vim.opt.shortmess = "ilmnrx"                        -- flags to shorten vim messages, see :help 'shortmess'
-- vim.opt.shortmess:append "c"                           -- don't give |ins-completion-menu| messages
-- vim.opt.formatoptions:remove({ "c", "r", "o" })        -- don't insert the current comment leader automatically for auto-wrapping comments using 'textwidth', hitting <Enter> in insert mode, or hitting 'o' or 'O' in normal mode.
-- vim.opt.runtimepath:remove("/usr/share/vim/vimfiles")  -- separate vim plugins from neovim in case vim still in use
