---@type LazySpec
return {
	dir = vim.fn.stdpath('config') .. '/plug-wip/genja-finder.nvim',
	dependencies = { 'nvim-telescope/telescope.nvim' },
	-- lazy (default), no trigger: loads on the first require('genja-finder'),
	-- i.e. <F1> / <S-F1> / <leader>jj from genja/map-telescope.lua

	---@type genja-finder.Opts
	opts = {
		exclude = { 'node_modules', 'vendor', 'dist' },
		exclude_files = { '*.min.js', '*.min.css' },
		attach = function(map) require('genja.fn.telemap').Telemap(map) end,
	},

	config = function(_, opts)
		require('genja-finder').setup(opts)
	end,
}
