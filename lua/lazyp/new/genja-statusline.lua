return {
	dir = vim.fn.stdpath('config') .. './plug-wip/genja-statusline.nvim',

	opts = {
		statusline = true,
		tabline = true,
		winbar = true,
	},
	lazy = false,

	config = function (_, opts)
		require('genja-statusline').setup()
		vim.notify('herr herr')
		opts = opts
	end
}
