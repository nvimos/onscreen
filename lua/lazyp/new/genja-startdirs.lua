-- Start dirs (idea 36): plug-wip/genja-startdirs.nvim. Keys: lua/genja/map-plugin/genja-startdirs.lua.
-- The list: lua/genja/local/startdirs.txt (gitignored; example next to it), then opts.dirs.
-- :Mydirs opens the mydirs picker, :Mydirs reset deletes the usage counts.
-- Used by the mydirs picker, the start dirs find, CycleDirs (lua/genja/fu.lua) and oil (lua/genja/map-oil.lua).
local SRC = 'lua/lazyp/new/genja-startdirs.lua: '
local Maps = require('genja.map-plugin')

local Wip = require('genja.plug-wip')

---@type LazySpec
return {
	'tox2ik/genja-startdirs.nvim',
	dir = Wip.dir('genja-startdirs.nvim'),
	keys = Maps:keys(),
	cmd = { 'StartdirsEdit', 'StartdirsAdd', 'StartdirsRemove', 'Mydirs' },
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
		-- here, not in the plugin: the picker is the config's telescope extension
		vim.api.nvim_create_user_command('Mydirs', function(o)
			if o.args == 'reset' then
				require('genja-startdirs').reset_usage()
				return
			end
			if o.args ~= '' then
				vim.notify(SRC .. 'unknown argument: ' .. o.args, vim.log.levels.WARN)
				return
			end
			vim.cmd('Telescope mydirs')
		end, {
			nargs = '?',
			complete = function() return { 'reset' } end,
			desc = 'Dirs: start dirs picker (reset: delete the usage counts)',
		})
	end,
}
