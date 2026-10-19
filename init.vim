""" Genja Nvim config loader
"""
""" stdpath('config') + nvim\init.vim
"""
"""

highlight Normal guibg=#000000 guifg=#FFFFFF

let mapleader = "\<Space>"
let maplocalleader = ","

if has('nvim') == 1 | lua << EOF
do
local Safeload = require('genja.api').Safeload

vim.o.errorfile = vim.fn.expand('~/Desktop/nvim.log')  -- log to a visible path
vim.g.genja_enable_autoresource = true                 -- reload configs after save
Safeload('lazy-boot')                                  -- lazy plugin manager

if not Safeload('genja') then                          -- nvim profile
	--                                                 -- try a subset if all of genja doesn't load
	-- vim.g.mapleader      = ' '
	-- vim.g.maplocalleader = ','
	Safeload 'genja.map-zero'        -- stable-ish maps
	Safeload 'genja.map-lsp'         -- code navigation maps
	Safeload 'genja.map-telescope'   -- make telescope easier to use
	Safeload 'genja.map-convoluted'  -- esoteric keymaps
	Safeload 'genja.opt'             -- vim config options
	vim.cmd('source '                -- load legacy one-file config for vim9 and earlier
	.. vim.fn.stdpath('config')
	.. '/lua/genja/vimrc.almalinux.vim')
	end

	vim.o.guifont = 'Cascadia Code:h14:l'
	vim.cmd('source ' .. vim.fn.stdpath('config') .. '/ginit.vim')
	end
EOF
endif
