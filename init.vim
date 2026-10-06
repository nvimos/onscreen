lua << EOF
do
	if not string.find(vim.env.PATH, 'a:\\bin', 1, true) then
		vim.env.PATH = 'a:\\bin;' .. vim.env.PATH
	end

	vim.o.errorfile = vim.fn.expand('~/Desktop/nvim.log')

	Safeload = require('genja.api').Safeload
	Safeload('lazy-boot')

	if not Safeload('genja') then
		-- try a subset of the config if the whole thing breaks.
		vim.g.mapleader      = ' '
		vim.g.maplocalleader = ','
		Safeload 'genja.map-zero'
		Safeload 'genja.map-lsp'
		Safeload 'genja.map-telescope'
		Safeload 'genja.map-convoluted'
		Safeload 'genja.opt'
		-- vim.cmd( 'redraw' )

		-- assumes vim9, installs plugins with vimplug
		-- vim.cmd('source ' .. vim.fn.stdpath('config') .. '/lua/genja/vimrc.almalinux.vim')

	else
		vim.notify('Safeload genja: ok')
	end

	vim.o.guifont = 'Cascadia Code:h14:l'
end
EOF
