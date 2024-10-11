-- config in: ../../after/plugin/cmp-after.lua
return {
	{ 'L3MON4D3/LuaSnip',       priority = 79 },

	-- completion engine
	{ 'hrsh7th/nvim-cmp',       priority = 80 },
--    'hrsh7th/cmp-nvim-lsp-signature-help'

	-- sources for nvim-cmp
	{ 'hrsh7th/cmp-nvim-lsp', priority = 81 },
	{ 'hrsh7th/cmp-cmdline',  priority = 81 },
	{ 'hrsh7th/cmp-buffer',   priority = 81 },
	{ 'hrsh7th/cmp-path',     priority = 81 },
	{ 'petertriho/cmp-git',   priority = 81 },


	{ 'onsails/lspkind.nvim', },
}
