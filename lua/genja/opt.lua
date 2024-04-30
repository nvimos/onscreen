

vim.g.autoresource_enable = true -- genja-autoresource.lua



-- vim.api.nvim_set_function("Winbar", Winbar)

-- vim.o.winbar = 'COCK.'
-- vim.o.winbar = "%{%v:lua.require'genja.winbar'()%}"

-- function Winbar() return "WINBAR" end
--vim.o.winbar = "%{v:lua.Winbar()}" -- not expanded as statusline
vim.o.winbar = "%{%v:lua.Winbar()%}"

local function get_mode()
	local mode = vim.fn.mode()
	local mode_map = {
		n = "N",
		i = "I",
		v = "V",
		V = "V",
		[""] = "V",
		c = "C",
		t = "T",
		R = "R",
	}
	return mode_map[mode] or mode
end

-- Set statusline
--     
-- vim.o.statusline = ' %f %m%r%h%w%y [%{&fileencoding}] [%{&fileformat}]'


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




vim.opt.foldcolumn = '2'
vim.o.listchars = 'space:_,tab:>~'
vim.o.shiftwidth = 4

vim.o.backup = false
vim.o.swapfile = false
-- pcall(vim.opt.undodir, os.getenv("HOME") .. "/.vim/undodir")
vim.opt.undodir = (vim.fn.stdpath('config') .. '/undodir'):gsub([[\]], [[/]])
vim.opt.undofile = true


--vim.opt.showbreak = '\\      ' -- display this after wrapped
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
vim.opt.showbreak = '⬉      '


-- vim.o.ruler = true -- the cursor positon in statusline: line,col (Top|Bot)  %62
-- vim.o.rulerformat = ''

vim.o.fileencoding = "utf-8"
vim.o.ignorecase = true
vim.o.mouse = "a"
vim.o.showmode = false
vim.o.showtabline = 2 -- 0: never -- 1: iff >= 2 tabs -- 2: always


vim.o.cmdheight = 4
vim.o.cmdheight = 1

vim.o.smartcase = true
vim.o.smartindent = true
vim.o.splitbelow = true
vim.o.splitright = true

vim.o.timeoutlen = 300                        -- time to wait for a mapped sequence to complete (in milliseconds)
vim.o.updatetime = 300                        -- faster completion (4000ms default)

vim.o.expandtab = false                        -- convert tabs to spaces
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
vim.o.whichwrap = "bs<>[]hl"                  -- which "horizontal" keys are allowed to travel to prev/next line

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

