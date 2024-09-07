-- This file has new plugins undergoing evaluation.
-- When confirmed as good enough, they can go to
--
-- VIM/genja/lazy.lua
-- VIM/lua/lazyp/

(function(lazypath)
	lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
	if not vim.loop.fs_stat(lazypath) then
		local repo = 'https://github.com/folke/lazy.nvim.git'
		vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=stable', repo, lazypath })
	end
	vim.opt.rtp:prepend(lazypath)
end)()

-- :help lazy.nvim-lazy.nvim-plugin-spec
PluginSpec = {
	-- { import = 'genja.lazy-plug' },   -- custom lazy-plugin-specs
	-- { import = 'pluginz' },           -- plugin LPSs from other people on github

	{ import = 'lazyp' },           -- lazy plugin specs (VIM/lua/lazyp)

	--[[ debian stable ]]
	--[[ debian testing ]]
	--[[ debian unstable ]]


	--[[ cute / games ]]

	--[[ maybe try at some point ]]

	-- 'theprimeagen/refactoring.nvim',
	-- 'github/copilot.vim',
	-- { 'echasnovski/mini.files', version = '*' },

	-- Vonr/align.nvim
	-- { 'echasnovski/mini.nvim', version = '*' },
	-- gopher.nvim
	-- https://github.com/jose-elias-alvarez/null-ls.nvim/

	-- https://github.com/MaximilianLloyd/lazy-reload.nvim

	-- https://github.com/nanotee/zoxide.vim

	-- nvim-telescope/telescope-media-files.nvim

}

-- local lazy_plugin_spec = { import = "genja.lazy" }
-- table.insert(PluginSpec, lazy_plugin_spec)
--  require("lazy").setup(lazy_plugin_spec, { })

-- table.insert(PluginSpec, { import = "genja.lazy-plug" })
-- table.insert(PluginSpec, { import = 'pluginz' })

require("lazy").setup(PluginSpec, {
	dev = {
		---@type string | fun(plugin: LazyPlugin): string directory where you store your local plugin projects
		path = [[A:\workspace]],
	}
})

