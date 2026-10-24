-- Claude Code in a floaterm, one per project (idea 19): plug-wip/genja-claudefterm.nvim.
-- Keys: plugin/claude-fterm.lua; genja-ask's claudefterm target calls send().

---@type LazySpec
return {
	dir = vim.fn.stdpath('config') .. '/plug-wip/genja-claudefterm.nvim',
	cmd = 'ClaudeFterm', -- the keys and genja-ask load it through require('genja-claudefterm')

	opts = {
		-- every start uses these, also when <leader>pc or the ask popup starts claude first
		term = { title = 'claude', wintype = 'vsplit', position = 'botright', width = 0.45, autoclose = 'smart', cmd = 'claude' },
	},

	config = function(_, opts)
		require('genja-claudefterm').setup(opts)
	end,
}
