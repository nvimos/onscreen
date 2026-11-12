-- Hunk signs in the sign column, stage/reset/preview hunks, line blame.
-- Keys: lua/genja/map-plugin/gitsigns.lua, buffer-local via on_attach.

local Maps = require('genja.map-plugin')

---@type LazySpec
return {
	'lewis6991/gitsigns.nvim',
	event = 'VeryLazy', -- attaches to buffers already open at setup
	opts = {},
	config = function(_, opts)
		Maps:mappings(opts) -- sets opts.on_attach, so it runs before setup
		require('gitsigns').setup(opts)
	end,
}
