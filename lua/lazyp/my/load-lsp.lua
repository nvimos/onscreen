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
		branch = 'v1.32.0',
		config = false, -- require('mason-lspconfig').setup({})
		priority = 71,
		lazy = true,
	},{
		'neovim/nvim-lspconfig',
		branch = 'v2.5.0', -- neovim 0.11 for later versions
		priority = 72,
		lazy = true,
		cmd = 'Mason',
		config = function(lp, opt)
			require('genja.lspm').setup_mason_lspconfig(lp, opt)
		end,

		dependencies = {
			"creativenull/efmls-configs-nvim",
			-- "windwp/nvim-autopairs",
			"williamboman/mason.nvim",
			"hrsh7th/nvim-cmp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-nvim-lsp",
		},
	},

	-- {
	-- 	'windwp/nvim-autopairs',
	-- 	event = "InsertEnter",
	-- 	config = true
	-- 	-- use opts = {} for passing setup options
	-- 	-- this is equivalent to setup({}) function
	-- }
}
