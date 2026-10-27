-- not used: 2026-10 (blink.cmp instead: lua/lazyp/langs-comps/blink-cmp.lua; tag before-blink-2026-w44
-- has the nvim-cmp setup of genja-completion011).
-- Plugins for completion. All configuration lived in lua/genja/completion/.
---@type LazySpec
return {
	{
		'hrsh7th/nvim-cmp',
		enabled = false,
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
