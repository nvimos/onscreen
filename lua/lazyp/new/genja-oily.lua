---@type LazySpec
return {
	dir = vim.fn.stdpath('config') .. '/plug-wip/genja-oily.nvim',
	dependencies = { 'stevearc/oil.nvim' },
	-- lazy (default), no trigger: loads on the first require('genja-oily'),
	-- i.e. oil's is_hidden_file and <LocalLeader>M in lua/lazyp/explorer/oil.lua

	---@type genja-oily.Opts
	opts = {
		filename = '.oily',
		hide_dotfiles = true,
	},

	config = function(_, opts)
		require('genja-oily').setup(opts)
	end,
}
