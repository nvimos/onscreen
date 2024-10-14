lua << EOF
do
	vim.o.errorfile = vim.fn.expand('~/Desktop/nvim.log')

	require('genja')
	Safeload = require('genja.fn').Safeload
	if not Safeload('genja') then
		-- try a subset of the config if the whole thing breaks.
		vim.g.mapleader      = ' '
		vim.g.maplocalleader = ','
		Safeload 'genja.map-zero'
		Safeload 'genja.map-lsp'
		Safeload 'genja.map-telescope'
		Safeload 'genja.map-convoluted'
		Safeload 'genja.lazy'
		vim.cmd( 'redraw' )
	else
		vim.notify('LOADED')
	end
end
EOF
