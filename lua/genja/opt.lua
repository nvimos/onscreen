

-- [[ ftplugins ]]

vim.g.dosbatch_colons_comment = true


--[[ plugin settings ]]--
vim.g.genja_enable_autoresource = true -- genja-autoresource.lua
vim.g.genja_enable_autoresource = false



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

vim.g.netrw_localmovecmd = (function() if vim.fn.has('Windows') then return 'move'; else return 'mv'; end end)()


--[[ status bars , lines ]]--
require 'genja.winbar' -- Winbar()
require 'genja.statusline' -- Statusline()
-- %{} not expanded as statusline
-- %{%} expanded as statusline
vim.o.winbar = "%{%v:lua.Winbar()%}"
vim.o.statusline = '%{%v:lua.Statusline()%}'

vim.o.laststatus = 3 -- 3: global 2: one for each 1: if more than one 0: never


--[[ vim options ]]--

vim.opt.foldcolumn = '2'
vim.opt.hidden = true

vim.o.modeline = true
vim.o.modelines = 2

-- vim.o.listchars = 'leadmultispace:>   ·,lead:>,multispace:· ,space:·,tab: '


vim.o.showbreak = '⬉      ' -- display after wrapped
vim.o.showbreak = '`      ' -- display after wrapped
vim.o.listchars = 'eol:`,tab: ' -- todo: make an easy-swap pluqin in telescope (myeasy-swap)
vim.o.listchars = 'eol:󰭿,tab: '
vim.o.listchars = 'tab: '
---- how it looks....
----....====++++
                                                -- multispace
												--[[ tabs
z                                               
	-tab
 ---space]]
vim.opt.listchars:append('space: ,multispace:·   ')
vim.opt.listchars:append('lead: ,leadmultispace:·   ')
-- vim.opt.listchars:append('trail:󱁐,')
vim.opt.listchars:append('trail:_,')
vim.opt.listchars:append('extends:→,precedes:←')
vim.opt.listchars:append('tab: ')



vim.o.list = true



vim.o.shiftwidth = 4

vim.o.backup = false
vim.o.swapfile = false
-- pcall(vim.opt.undodir, os.getenv("HOME") .. "/.vim/undodir")
vim.opt.undodir = (vim.fn.stdpath('config') .. '/undodir'):gsub([[\]], [[/]])
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

vim.o.expandtab = false                       -- convert tabs to spaces, if true
vim.o.shiftwidth = 4                          -- the number of spaces inserted for each indentation
vim.o.tabstop = 4                             -- insert 2 spaces for a tab

vim.o.cursorline = false                       -- highlight the current line

vim.o.number = false                           -- set numbered lines
vim.o.relativenumber = false                  -- set relative numbered lines
vim.o.numberwidth = 3                         -- set number column width to 2 {default 4}

vim.o.signcolumn = "yes"                      -- always show the sign column, otherwise it would shift the text each time
vim.o.wrap = false                            -- display lines as one long line
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
