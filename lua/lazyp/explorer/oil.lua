-- vim: set foldmethod=marker foldlevel=0 foldnestmax=2 foldcolumn=2:

local aucmd = vim.api.nvim_create_autocmd
local augrp = vim.api.nvim_create_augroup
local UserComm = vim.api.nvim_create_user_command


local F = require 'genja.oil'

UserComm('OilVlcRar', F.vlc_rar, { desc = 'Oil: open rar in vlc (extract to c:/tmp)' })
UserComm('OilCd2Entry', F.cd_to_entry, { desc = 'Oil: cd to entry' })

-- Sugar syntax autogroups experiment {{{
--- local
---      MyAutos = {}
---      MyAutos.__index = MyAutos
---      MyAutos.__call = function(groupName)
---      	local inst = setmetatable({}, MyAutos)
---      	inst.gr = augrp(groupName, { clear = true })
---      	return inst end
---      function MyAutos:acom(fn) fn(self, self.gr) end
---      Oilgroup = MyAutos('MyOil')
---      Oilgroup.acom(function(gr)
---      	aucmd('BufEnter', {   group = gr,
---      	                    pattern = 'oil:///*',
---      					   callback = F.sort_by_mtime_in_certain_paths })
---      end)
--- }}}

-- Oil: dynamic file sorting {{{
local MyOil = augrp('MyOil', { clear = true })
aucmd({ 'BufEnter' }, { group = MyOil, callback = F.dynamic_dir_sort, pattern = 'oil:///*', })
-- E211 workaround (oil #762): drop buffers of files oil is about to delete
aucmd('User', { group = MyOil, pattern = 'OilActionsPre', callback = F.forget_deleted_buffers })
-- }}}

---@type LazySpec
return {
	{
		'stevearc/oil.nvim',
		dependencies = {
			"nvim-tree/nvim-web-devicons"
		},
		event = { 'UIEnter' },
		cmd = 'Oil',
		---@type oil.SetupOpts
		opts = {

			skip_confirm_for_simple_edits = true,

			float = {
				-- Padding around the floating window
				padding = 4,
				max_width = 0,
				max_height = 0,
				border = "rounded",
				win_options = {
					winblend = 0,
				},
				-- This is the config that will be passed to nvim_open_win.
				-- Change values here to customize the layout
				override = function(conf)
					return conf
				end,
			},

			keymaps = require('genja.map-oil').keymaps,
			win_options = {
				wrap = false,
				signcolumn = "yes",
				cursorcolumn = false,
				foldcolumn = "2",
				spell = false,
				list = false,
				conceallevel = 3,
				concealcursor = "nvic",
			},
			default_file_explorer = true, -- use oil instead of netrw
			columns = {
				{ "size", },
				{ "icon", add_padding = false },
			},


			view_options = {
				-- dotfiles + the nearest .oily up the tree (plug-wip/genja-oily.nvim)
				is_hidden_file = function(name, bufnr) return require("genja-oily").is_hidden_file(name, bufnr) end,
				natural_order = false,
				case_insensitive = true,
				sort = {
					{ 'type', 'asc' },
					{ 'name', 'asc' },
				},
			},

		},

		config = function(_, opts)
			require('oil').setup(opts)
			-- oil sets loaded_netrw, which stops netrw's autoload (E117 netrw#Lexplore);
			-- :e <dir> stays with oil, since oil clears netrw's FileExplorer autocmds
			vim.g.loaded_netrw = nil
		end,

		init = function()
			-- arg-1 is a dir -> load oil
			if vim.fn.argc() == 1 then
				local stat = vim.loop.fs_stat(vim.fn.argv(0))
				if stat and stat.type == "directory" then
					require("lazy").load({ plugins = { "oil.nvim" } })
				end
			end

			-- Open a folder -> load oil
			vim.api.nvim_create_autocmd("BufReadPre", {
				desc = "Lazy load oil.nvim when opening a directory buffer",
				callback = function(ev)
					if vim.fn.isdirectory(ev.match) == 1 then
						-- Load the plugin immediately before Neovim processes the directory buffer
						require("lazy").load({ plugins = { "oil.nvim" } })
					end
				end,
			})
		end,


	},

	-- oil's which-key groups, appended to the main spec's opts.spec (opts_extend)
	{
		'folke/which-key.nvim',
		optional = true,
		opts = { spec = require('genja.map-oil').which_key },
	},
}
