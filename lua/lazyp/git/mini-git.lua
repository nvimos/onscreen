-- :Git command (output in a split, completion), and the commit/log of the
-- line under the cursor. Takes over :Git from fugitive.
-- Upstream moved from echasnovski/mini-git to nvim-mini/mini-git.

local Maps = require('genja.map-plugin')

---@type LazySpec
return {
	'nvim-mini/mini-git',
	main = 'mini.git',
	event = 'VeryLazy', -- tracks buffers for b:minigit_summary
	opts = {},
	config = function(_, opts)
		require('mini.git').setup(opts)
		Maps:mappings(opts)
	end,
}
