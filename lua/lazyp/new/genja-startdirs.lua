-- Start dirs (idea 36): plug-wip/genja-startdirs.nvim. Keys: lua/genja/map-plugin/genja-startdirs.lua.
-- The list: lua/genja/local/startdirs.txt (gitignored; example next to it), then opts.dirs.
-- Used by the mydirs picker, <leader>jd find, CycleDirs (lua/genja/fu.lua), oil ,s / ,S.
local Maps = require('genja.map-plugin')

---@type LazySpec
return {
	dir = vim.fn.stdpath('config') .. '/plug-wip/genja-startdirs.nvim',
	keys = Maps:keys(),
	cmd = { 'StartdirsEdit', 'StartdirsAdd', 'StartdirsRemove' },
	-- also loads on the first require('genja-startdirs')

	---@type genja-startdirs.Opts
	opts = {
		dirs = { '~', vim.fn.stdpath('config') },
		file = vim.fn.stdpath('config') .. '/lua/genja/local/startdirs.txt',
		add_group = 'added',
		groups = {
			windows = function() return vim.fn.has('win32') == 1 end,
			oni = true,
			fonv = false,
			openmw = false,
			movies = false,
		},
	},

	config = function(_, opts)
		require('genja-startdirs').setup(opts)
	end,
}
