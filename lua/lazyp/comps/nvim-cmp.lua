-- Plugins for completion. All configuration lives in lua/genja/completion/.
-- No config here: genja-completion011 (lua/genja/lazy-plug-spec.lua) calls
-- cmp.setup() through require('genja.comps').setup().
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
	},
}
