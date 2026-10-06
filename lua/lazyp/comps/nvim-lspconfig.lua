-- vim.lsp.log.set_level("debug")
vim.lsp.log.set_level("warn")
-- vim.lsp.log.set_level("off")

-- Plugins for LSP.
-- All configuration lives in
-- lua/genja/lsp/ and
-- lua/genja/lang/
-- No config here: genja-completion011 (lua/genja/lazy-plug-spec.lua) runs the
-- LSP setup through require('genja.comps').setup().
return {
	{
		'neovim/nvim-lspconfig', -- only ships default server configs (lsp/*.lua)
		event = { 'BufReadPre', 'BufNewFile' },
		dependencies = {
			'hrsh7th/cmp-nvim-lsp', -- completion capabilities sent to every server
			'mason-org/mason.nvim', -- installs servers and tools
			'mason-org/mason-lspconfig.nvim', -- lspconfig name <-> mason package, enable on install
		},
	},

}
