highlight Normal guibg=#000000 guifg=#FFFFFF

lua << EOF
do
	local Safeload = require('genja.api').Safeload

	-- env
	vim.env.SSH_AUTH_SOCK = vim.fn.expand("~/.ssh/agent.sock")
	if not string.find(vim.env.PATH, 'a:\\bin', 1, true) then
		vim.env.PATH = 'a:\\bin;' .. vim.env.PATH
	end

	vim.o.errorfile = vim.fn.expand('~/Desktop/nvim.log')

	-- lazy plugin manager
	Safeload('lazy-boot')

	-- nvim profile
	if not Safeload('genja') then
		-- try a subset if all of genja doesn't load
		vim.g.mapleader      = ' '
		vim.g.maplocalleader = ','
		Safeload 'genja.map-zero'
		Safeload 'genja.map-lsp'
		Safeload 'genja.map-telescope'
		Safeload 'genja.map-convoluted'
		Safeload 'genja.opt'
		-- vim.cmd( 'redraw' )

		-- fail: alma solid assumes vim9, installs plugins with vimplug
		--       maybe set an env SKIP_PLUGINS and skip those parts
		-- vim.cmd('source ' .. vim.fn.stdpath('config') .. '/lua/genja/vimrc.almalinux.vim')

	else
		-- vim.notify('Safeload genja: ok')
	end

	vim.o.guifont = 'Cascadia Code:h14:l'
end
EOF
