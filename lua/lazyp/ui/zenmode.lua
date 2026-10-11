-- distraction free editing
---@type LazySpec
return {
	'folke/zen-mode.nvim',
	cmd = 'ZenMode',
	lazy = true,
	keys = { { '<leader>mz', '<cmd>ZenMode<cr>', silent = true, desc = "UI: toggle zen mode" } },
	---@type ZenOptions
	opts = {},
}
