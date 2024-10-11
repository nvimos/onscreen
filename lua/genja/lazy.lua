-- This file declares new plugins, undergoing evaluation.
-- When confirmed as good enough, they can go to;
--
--     VIM/genja/lazy.lua
--     VIM/lua/lazyp/     (my configs)
--     VIM/lua/lazyo/     (other people's configs)
--
-- This file also bootstraps the lazy plugin manager.
-- The format for plugin declarations is explained in;
--
--     :help lazy.nvim-lazy.nvim-plugin-spec

(function(LazyData, Github)
	LazyData, Github = '' ..
		vim.fn.stdpath('data') .. '/lazy/lazy.nvim',
		'https://github.com/folke/lazy.nvim.git'
	if not vim.loop.fs_stat(LazyData) then
		vim.fn.system({
			'git', 'clone', '--filter=blob:none', '--branch=stable',
			Github, LazyData })
	end;
	vim.opt.rtp:prepend(LazyData) -- prenpend to runtime path (to autoload plugins?)
	vim.api.nvim_create_autocmd('FileType', {
		pattern = 'lazy',
		callback = function(ev)
			local mo = { noremap = true, silent = true }
			local bkm = vim.api.nvim_buf_set_keymap
			bkm(ev.buf, 'n', '<esc>', '<cmd>quit<cr>', mo)
			bkm(ev.buf, 'n', '<c-w>', '<cmd>quit<cr>', mo)
			bkm(ev.buf, 'n', 'q', '<cmd>quit<cr>', mo);
		end
	})
end)()

PluginSpec = {
	{ import = 'lazyp' },
	{ import = 'lazyo' } } -- lazy-plugin specs from (VIM/lua/lazy{p,o})

NewPlugins = {

	--[[ typical options
	{
		'foo/bar',
		cmd = 'MyPlug',
		keys = { { '<leader>XXX', '<plug>(bar)', desc = 'Do the doo' }, },
		lazy = true, -- depends on event ora keys ora cmd
		event = 'VimEnter',
		enabled = true,
		build = fun(LazyPlugin) or string or false or a list, of build commands See Building for more information.
		config = function()
			require('bar').setup {
				baz = false
			}
		end
	},
	]]

	-- https://github.com/kkalamarski/neovim-config/blob/main/lua/kkalamarski/plugins.lua



	{
		-- vim-floaterm is better?
		'akinsho/toggleterm.nvim',
		version = "*",
		opts = {},
		open_mapping = [[<c-\>]],
		config = function()
			require("toggleterm").setup {
				close_on_exit = false
			}
		end,

	},

	{
		-- run tasks from makefiles?
		'stevearc/overseer.nvim',
		opts = {},
		config = function()
			require('overseer').setup({
				templates = {
					'builtin',
					'user.run_script'
				},
			})
		end
	},
	{ 'stevearc/dressing.nvim' }, -- nicer prompts and dialogs
	{ 'voldikss/vim-floaterm' }, -- FloatermNew --name=foo bash
	{ 'jbyuki/quickmath.nvim' }, -- evaluate lua-math line by line

	-- cute / games

	-- maybe try at some point

	-- https://github.com/rockerBOO/awesome-neovim

	--[[
		2024-09
		https://github.com/psjay/buffer-closer.nvim
		https://github.com/realprogrammersusevim/md-to-html.nvim
		-
		{ 'jbyuki/ntangle.nvim.git' }
		{ 'jbyuki/monolithic.nvim' }
		{ 'jbyuki/carrot.nvim' }
		-
		https://github.com/stevearc/resession.nvim
		https://github.com/famiu/feline.nvim
		https://github.com/willothy/nvim-cokeline
		https://github.com/skywind3000/asyncrun.vim
		https://github.com/nvimdev/lspsaga.nvim
		https://github.com/debugloop/telescope-undo.nvim

		2024-08
		https://github.com/jose-elias-alvarez/null-ls.nvim/
		https://github.com/MaximilianLloyd/lazy-reload.nvim
		https://github.com/nanotee/zoxide.vim
		nvim-telescope/telescope-media-files.nvim
		https://github.com/skywind3000/asyncrun.vim

		2024-07
		{ 'theprimeagen/refactoring.nvim' },
		{ 'echasnovski/mini.files', version = '*' },
		{ Vonr/align.nvim },
		{ gopher.nvim },

	]]
}

for _, e in pairs(NewPlugins) do
	table.insert(PluginSpec, e)
end

require('lazy').setup({
	spec = PluginSpec,
	defaults = {
		lazy = false
	},
	-- install = { colorscheme = { "nightfox" } },
	install = { colorscheme = { "habamax" } },
	change_detection = {
		notify = false
	},
	dev = {
		---@type string | fun(plugin: LazyPlugin): string directory where you store your local plugin projects
		path = [[A:\workspace]],
	}
})


-------------

-- collection of modules for whatever...
-- { 'echasnovski/mini.nvim', version = '*' }, -- stable
-- { 'echasnovski/mini.nvim', version = false , -- main
