return {
	--[[
	You might not need lsp-zero…
	It's important that you set up the plugins in the following order:
		1. mason.nvim
		2. mason-lspconfig.nvim
		3. Setup servers via lspconfig
	--]]
	{
		'williamboman/mason.nvim',
		config = false, -- require('mason').setup({})
		priority = 70,
		lazy = true,
	},{
		'williamboman/mason-lspconfig.nvim',
		config = false, -- require('mason-lspconfig').setup({})
		priority = 71,
		lazy = true,
	},{
		'neovim/nvim-lspconfig',
		priority = 72,
		lazy = true,
		cmd = 'Mason',
		config = function(lp, opt)
			require('genja.lspm').setup_mason_lspconfig(lp, opt)
		end
	},
}
