local Maps = require('genja.map-plugin')

local Wip = require('genja.plug-wip')

---@type LazySpec
return {
	'tox2ik/genja-splitpad.nvim',
	dir = Wip.dir('genja-splitpad.nvim'),
	event = 'VeryLazy',
	enabled = false,
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
