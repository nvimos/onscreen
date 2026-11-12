-- Recent files (idea 35): plug-wip/genja-recent.nvim records views and edits, ranks by frecency.
-- Picker: lua/genja/ext/recent.lua, key in lua/genja/map-telescope.lua; telescope oldfiles stays too.

local Wip = require('genja.plug-wip')

---@type LazySpec
return {
	'tox2ik/genja-recent.nvim',
	dir = Wip.dir('genja-recent.nvim'),
	event = 'VeryLazy', -- records from then on; setup() records the buffer already shown

	---@type genja-recent.Opts
	opts = {
		edit_weight = 2,
		skip_patterns = { '/%.git/' },
		skip_dirs = { vim.uv.os_tmpdir(), vim.fn.stdpath('data') },
	},

	config = function(_, opts)
		require('genja-recent').setup(opts)
	end,
}
