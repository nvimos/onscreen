""" Genja Nvim config loader
"""
""" stdpath('config') + nvim\init.vim
"""
"""


highlight Normal guibg=#1E1E2E guifg=#CDD6F4  " Catppuccin Mocha
highlight Normal guibg=#1A1B26 guifg=#C0CAF5  " Tokyo Night
highlight Normal guibg=#0D1117 guifg=#E6EDF3  " GitHub Dark

highlight Normal guibg=#0D1117  guifg=#C0CAF5 ctermbg=233 ctermfg=153 " Tokyo Night GitHub Dark
colorscheme lunaperche

" source <sfile>:h/lua/genja/hilite.vim


let maplocalleader = ","
let mapleader      = "\<Space>"
"let &guifont       = "Cascadia Code:h12:l" " set guifont=
let &guifont       = "JetBrainsMono NFM:h12" " set guifont=

let &errorfile = expand('~/Desktop/nvim.log')    " log to a visible path
let g:genja_enable_autoresource = v:true         " reload configs after save

if has('nvim') == 1 | lua << EOF
do
	local Safeload = require('genja.api').Safeload
	Safeload('lazy-boot')                                  -- lazy plugin manager
	if not Safeload('genja') then                          -- nvim profile
		Safeload 'genja.map-zero'        -- stable-ish maps
		Safeload 'genja.map-lsp'         -- code navigation maps
		Safeload 'genja.map-telescope'   -- make telescope easier to use
		Safeload 'genja.map-convoluted'  -- esoteric keymaps
		Safeload 'genja.opt'             -- vim config options
		vim.cmd('source '.. vim.fn.stdpath('config') .. '/lua/genja/vimrc.almalinux.vim')
	end
end
EOF
else
    " legacy one-file config for vim9 and earlier
	source <sfile>:h/lua/genja/vimrc.almalinux.vim
endif

" source <sfile>:h'/ginit.vim'
