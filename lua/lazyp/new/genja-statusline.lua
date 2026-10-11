---@type LazySpec
return {
	dir = vim.fn.stdpath('config') .. '/plug-wip/genja-statusline.nvim',

	---@type genja-statusline.Opts
	opts = {
		statusline = true,
		tabline = true,
		winbar = true,
	},
	lazy = false,

	config = function(_, opts)
		require('genja-statusline').setup(opts)
	end
}
