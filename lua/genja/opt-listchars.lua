-- vim.o.listchars = 'leadmultispace:>   ·,lead:>,multispace:· ,space:·,tab: '

-- how listchars look {{{
----....====++++
                                                -- multispace
												--[[ tabs
trailz                                               
	-tab
 ---space]]
-- }}}




-- {{{ folds (from vimrc.almalinux.vim)
vim.opt.foldopen:remove 'block'
vim.opt.foldcolumn = '3'                     -- fdc=2 ; overrides the '2' above
vim.opt.fillchars = 'fold:│'
vim.opt.fillchars = 'fold:·'

vim.opt.fillchars = vim.opt.fillchars + 'foldopen:▼'  -- folds
vim.opt.fillchars = vim.opt.fillchars + 'foldclose:▶' -- folds
vim.opt.fillchars = vim.opt.fillchars + 'foldsep:│'   -- folds

-- }}}


vim.opt.fillchars = vim.opt.fillchars + 'stl: '      -- statusline
vim.opt.fillchars = vim.opt.fillchars + 'stlnc:─'    -- statusline (non-current)
vim.opt.fillchars = vim.opt.fillchars + 'vert::'
vim.opt.fillchars = vim.opt.fillchars + 'vert:│'
vim.opt.fillchars = vim.opt.fillchars + 'diff: '     -- no dashes on the filler lines of a diff




-- vim.opt.listchars:append('space: ,multispace:·   ') -- multispace is distracting more than anything
vim.opt.listchars:append('space: ,multispace:    ')
vim.opt.listchars:append('lead: ,leadmultispace:·   ')
-- vim.opt.listchars:append('trail:󱁐,')
vim.opt.listchars:append('trail:_,')
vim.opt.listchars:append('trail: ,') -- not in terminal
vim.opt.listchars:append('extends:→,precedes:←')

if vim.fn.has('gui_running') == 1 then
    vim.opt.listchars:append('tab: ')
else
    vim.opt.listchars:append('tab:• ')
    vim.opt.listchars:append('tab:∘ ')
    vim.opt.listchars:append('tab:· ')
    vim.opt.listchars:append('tab:  ') -- todo: toggle visible-invisible
end

vim.o.list = true
-- }}}

vim.o.showbreak = '⬉      ' -- display after wrapped
vim.o.showbreak = '`      ' -- display after wrapped

-- {{{ tab replcement character
if vim.fn.has('gui_running') == 1 then
    vim.o.listchars = 'eol:`,tab: ' -- todo: make an easy-swap pluqin in telescope (myeasy-swap)
    vim.o.listchars = 'eol:󰭿,tab: '
    vim.o.listchars = 'tab: '
else
    -- vim.o.listchars = 'eol:`' -- toggle visible-invisible
    vim.o.listchars = 'eol: '
end

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
