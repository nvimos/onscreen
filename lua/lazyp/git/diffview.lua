-- Side-by-side diffs and file history in a tab.
-- Fork of sindrets/diffview.nvim (no updates since 2024-06); same module and commands.

local Maps = require('genja.map-plugin')

---@type LazySpec
return {
	'dlyongemallo/diffview.nvim',
	cmd = {
		'DiffviewOpen', 'DiffviewClose', 'DiffviewToggleFiles', 'DiffviewFocusFiles',
		'DiffviewRefresh', 'DiffviewFileHistory',
	},
	keys = Maps:keys(),
	opts = {},
}
