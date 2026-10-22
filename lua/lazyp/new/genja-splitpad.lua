local Maps = require('genja.map-plugin')

---@type LazySpec
return {
	dir = vim.fn.stdpath('config') .. '/plug-wip/genja-splitpad.nvim',
	event = 'VeryLazy',
	keys = Maps:keys(),

	---@type genja-splitpad.Opts
	opts = {
		enabled = true,
		min_width = 10,
		exclude_ft = { 'oil', 'help' },
		exclude_bt = { 'terminal', 'prompt', 'quickfix', 'help' },
		eob_darken = 0.85,
	},

	config = function(_, opts)
		require('genja-splitpad').setup(opts)
	end,
}
