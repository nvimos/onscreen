-- vim.lsp.log.set_level("debug")
vim.lsp.log.set_level("warn")
-- vim.lsp.log.set_level("off")

-- Plugins for LSP.
-- All configuration lives in
-- lua/genja/lsp/ and
-- lua/genja/lang/
return {
	{
		'neovim/nvim-lspconfig', -- only ships default server configs (lsp/*.lua)
		event = { 'BufReadPre', 'BufNewFile' },
		cmd = 'Mason',
		dependencies = {
			'hrsh7th/cmp-nvim-lsp', -- completion capabilities sent to every server
			'mason-org/mason.nvim', -- installs servers and tools
			'mason-org/mason-lspconfig.nvim', -- lspconfig name <-> mason package, enable on install
		},
		config = function()
			Safeload = require('genja.api').Safeload
			Safeload('genja.lsp', function(mod)
				-- require('genja.lsp').setup()
				mod.setup()
			end)
		end,
	},

}
