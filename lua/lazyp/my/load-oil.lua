-- vim: set foldmethod=marker foldlevel=0 foldnestmax=2 foldcolumn=2:

local aucmd = vim.api.nvim_create_autocmd
local augrp = vim.api.nvim_create_augroup
local UserComm = vim.api.nvim_create_user_command


F = require 'genja.fn-oil'

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


-- {{{ Undersort: move-category
F.MoveCat = function (afterFn, opts)
	local op = {
		afterFn = afterFn,
		movees = F.get_oil_entries(),
		pats = { -- {{{ patterns
			-- [[-*]],
			-- [[-*/_*]],
			-- [[-*/*/_*]],
			[[%d+%-*]],
			[[%d+%-*/_*]],
			[[%d+%-*/*/_*]],
			[[_*]],
			[[_*/_*]],
		}, -- }}}
		input = '',
		dirs = { -- {{{ dirs
			-- [[Q:\audio-balmora\musikkkk]],
			-- [[Q:\audio-balmora\muzica]],
			[[V:\]] -- cinema
		} -- }}}
	}
	op = vim.tbl_extend('force', op, opts or {})
	require('telescope').extensions.undersort.undersort(op)
end
-- }}}

local O = {} -- oil actions
O.vote_movielens       = { desc = "Oil: Rate on movielens", callback = F.rate_on_movielens }
O.open_explorer        = { desc = "Oil: Open dir in explorer", callback = F.open_in_explorer }
O.open_external        = { desc = "Oil: Open (shell)", callback = F.open_via_shell }
O.move_category        = { desc = "Oil: Move to _category", callback = F.move_to_cat }
O.move_category_delete = { desc = "Oil: Move to _delete", callback = F.move_to_cat_delete }
O.select_custom        = { desc = "Oil: Select (custom)", callback = F.select_custom }


-- Oil: dynamic file sorting {{{
MyOil = augrp('MyOil', { clear = true })
aucmd({ 'BufEnter' }, { group = MyOil, callback = F.dynamic_dir_sort, pattern = 'oil:///*', })
-- }}}

O.sort_name  = { desc = "Oil: Sort by name", callback = F.sort_by_name }
O.sort_mtime = { desc = "Oil: Sort by mtime", callback = F.sort_by_mtime }
O.sort_size  = { desc = "Oil: Sort by size", callback = F.sort_by_size }
O.cycle_sort = { desc = "Oil: Cycle sort mode", callback = F.cycle_sort_mode }
O.cycle_sort_opposite = { desc = "Oil: Cycle sort mode", callback = F.toggle_asc_desc }

-- {{{ kymaps
O.keymaps = {

	['gSa'] = O.sort_name, -- mnemonic: mp3 id3 tag %a% for album or %A% for artist
	['gSt'] = O.sort_mtime,
	['gSs'] = O.sort_size,
	['<F12>'] = O.cycle_sort,
	['<S-F12>'] = O.cycle_sort_opposite,
	['<F11>'] = O.cycle_sort_opposite,

	['ge'] = O.open_explorer,
	['gX'] = O.open_external,
	['<LocalLeader>x'] = O.open_external,
	['<LocalLeader>e'] = O.open_explorer,
	['<LocalLeader>,'] = O.vote_movielens,
	['<localleader>j'] = O.move_category,

	['ze'] = O.open_explorer,
	['za'] = O.open_external,
	['zr'] = O.vote_movielens,
	['zj'] = O.move_category,

	['<C-j>'] = O.move_category,
	['<C-q>'] = O.move_category_delete, -- on windows

	['}'] = { '3j', },
	['{'] = { '3k', },

	['se'] = O.open_explorer,
	['sa'] = O.open_external,
	['sr'] = O.vote_movielens,
	['ss'] = O.move_category,
	['sj'] = O.move_category,
	['<CR>'] = O.select_custom,
	['<cr>'] = O.select_custom,
}
-- }}}

return {
	{
		'stevearc/oil.nvim',
		dependencies = {
			"nvim-tree/nvim-web-devicons"
		},
		event = 'UIEnter',
		cmd = 'Oil',
		-- keymaps = {
		-- 	{ "gX", nil },
		-- 	{ '<LocalLeader>x', nil },
		-- 	{ '<LocalLeader>,', nil },
		-- 	{ '<localleader>j', nil },
		-- },
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

			keymaps = O.keymaps,
			win_options = {
				wrap = true,
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
				natural_order = false,
				case_insensitive = true,
				sort = {
					{ 'type', 'asc' },
					{ 'name', 'asc' },
				},
			},
		},
	}
}
