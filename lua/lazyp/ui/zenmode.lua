-- distraction free editing
return {
	'folke/zen-mode.nvim',
	cmd = 'ZenMode',
	lazy = true,
	keys = { { '<leader>mz', '<cmd>ZenMode<cr>', { noremap = true, silent = true, desc = "UI: toggle zen mode" } } }
}
