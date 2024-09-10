-- This file installs new plugins, undergoing evaluation.
-- When confirmed as good enough, they can go to;
--
--     VIM/genja/lazy.lua
--     VIM/lua/lazyp/
--
-- This file also bootstraps the lazy plugin manager.

(function(LazyData)
	LazyData = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
	if not vim.loop.fs_stat(LazyData) then
		vim.fn.system({'git', 'clone', '--filter=blob:none', '--branch=stable',
			'https://github.com/folke/lazy.nvim.git', LazyData})
		end; vim.opt.rtp:prepend(LazyData) end)()

-- :help lazy.nvim-lazy.nvim-plugin-spec
PluginSpec = {{import = 'lazyp'}, {import = 'lazyo'}} -- lazy plugin specs from (VIM/lua/lazy{p,o})

NewPlugins = {

	{ 'voldikss/vim-floaterm' },

	--[[ debian unstable ]]
	--[[ debian testing ]]
	--[[ debian stable ]]

	--[[ cute / games ]]

	--[[ maybe try at some point ]]

	-- { 'theprimeagen/refactoring.nvim' },
	-- { 'github/copilot.vim' },
	-- { 'echasnovski/mini.files', version = '*' },

	-- { Vonr/align.nvim },
	-- { gopher.nvim },

	-- 2024-09
	-- https://github.com/stevearc/resession.nvim
	-- https://github.com/famiu/feline.nvim
	-- https://github.com/willothy/nvim-cokeline
	-- https://github.com/skywind3000/asyncrun.vim
	-- https://github.com/nvimdev/lspsaga.nvim
	-- https://github.com/debugloop/telescope-undo.nvim

	-- 2024-08
	-- https://github.com/jose-elias-alvarez/null-ls.nvim/
	-- https://github.com/MaximilianLloyd/lazy-reload.nvim
	-- https://github.com/nanotee/zoxide.vim
	-- nvim-telescope/telescope-media-files.nvim
	-- https://github.com/skywind3000/asyncrun.vim

}

table.foreach(NewPlugins, function(i, e) table.insert(PluginSpec, e) end)

require("lazy").setup(PluginSpec, {
	dev = {
		---@type string | fun(plugin: LazyPlugin): string directory where you store your local plugin projects
		path = [[A:\workspace]],
	}
})


-------------

-- collection of modules for whatever...
-- { 'echasnovski/mini.nvim', version = '*' }, -- stable
-- { 'echasnovski/mini.nvim', version = false , -- main
