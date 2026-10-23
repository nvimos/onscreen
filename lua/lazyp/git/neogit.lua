-- Git status UI: stage, commit, push, log, rebase. Opens in a tab.
-- Diffs from its status buffer open in diffview (`d` on a file).

local Maps = require('genja.map-plugin')

---@type LazySpec
return {
	'NeogitOrg/neogit',
	dependencies = {
		'nvim-lua/plenary.nvim',
		'dlyongemallo/diffview.nvim',
		'nvim-telescope/telescope.nvim',
	},
	cmd = 'Neogit',
	keys = Maps:keys(),
	opts = {
		integrations = {
			diffview = true,
			telescope = true,
		},
	},
}
