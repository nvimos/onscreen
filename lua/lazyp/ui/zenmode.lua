-- distraction free editing
local Maps = require('genja.map-plugin')

---@type LazySpec
return {
	'folke/zen-mode.nvim',
	cmd = 'ZenMode',
	lazy = true,
	keys = Maps:keys(),
	---@type ZenOptions
	opts = {},
}
