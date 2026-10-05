-- Plugins for LSP.
-- All configuration lives in
-- lua/genja/lsp/ and
-- lua/genja/lang/
return {


	{ 'mason-org/mason.nvim', },
	{ 'mason-org/mason-lspconfig.nvim', },
	{ 'hrsh7th/cmp-nvim-lsp', },




	{
		'neovim/nvim-lspconfig', -- only ships default server configs (lsp/*.lua)
		event = { 'BufReadPre', 'BufNewFile' },
		cmd = 'Mason',
		dependencies = {
			'mason-org/mason.nvim', -- installs servers and tools
			'mason-org/mason-lspconfig.nvim', -- lspconfig name <-> mason package, enable on install
			'hrsh7th/cmp-nvim-lsp', -- completion capabilities sent to every server
		},
		config = function()
			require('genja.lsp').setup()
		end,
	},
	{
		-- Makes lua_ls understand the Neovim runtime and the plugins a file requires.
		'folke/lazydev.nvim',
		ft = 'lua',
		opts = {
			library = {
				{ path = '${3rd}/luv/library', words = { 'vim%.uv' } },
			},
		},
	},
}
