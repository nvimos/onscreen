lua << EOF
do
	vim.o.guifont        = 'Cascadia Code Light:h14:l'
	vim.o.errorfile = vim.fn.expand('~/Desktop/nvim.log')

	Safeload = require('genja.fn').Safeload
	if not Safeload('genja') then
		-- try a subset of the config if the whole thing breaks.
		vim.g.mapleader      = ' '
		vim.g.maplocalleader = ','
		Safeload 'genja.map-zero'
		Safeload 'genja.map-lsp'
		Safeload 'genja.map-telescope'
		Safeload 'genja.map-convoluted'
		Safeload 'genja.opt'
		Safeload 'genja.lazy'
		-- vim.cmd( 'redraw' )

		-- assumes vim9, installs plugins with vimplug
		-- vim.cmd('source ' .. vim.fn.stdpath('config') .. '/vimscript/vimrc.almalinux')
	else
		vim.notify('Safeload genja: ok')
	end
end
EOF
