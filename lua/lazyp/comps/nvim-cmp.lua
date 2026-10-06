-- Plugins for completion. All configuration lives in lua/genja/completion/.
return {
	{
		'hrsh7th/nvim-cmp',
		event = { 'InsertEnter', 'CmdlineEnter' },
		dependencies = {
			'hrsh7th/cmp-nvim-lsp', -- language servers
			'hrsh7th/cmp-path', -- file names
			'hrsh7th/cmp-buffer', -- words in the buffer
			'hrsh7th/cmp-cmdline', -- : commands and :help topics
			'onsails/lspkind.nvim', -- kind icons
		},
		config = function()
			Safeload = require('genja.api').Safeload
			Safeload('genja.lsp', function(mod)
				-- require('genja.completion').setup()
				mod.setup()
			end)
		end,
	},
}
