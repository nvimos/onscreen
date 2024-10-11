local O = {} -- oil

F = require 'genja.fn-oil'



vim.api.nvim_create_autocmd("BufEnter", {
    group = vim.api.nvim_create_augroup("MyOil", { clear = true }),
	pattern = "oil:///*",
	callback = F.sort_by_mtime_in_certain_paths,
})

F.MoveCat = function (afterFn, opts)
	local op = {
		afterFn = afterFn,
		movees = F.get_oil_entries(),
		pats = {
			-- [[-*]],
			-- [[-*/_*]],
			-- [[-*/*/_*]],
			[[%d+%-*]],
			[[%d+%-*/_*]],
			[[%d+%-*/*/_*]],
			[[_*]],
			[[_*/_*]],
		},
		input = '',
		dirs = {
			-- [[Q:\audio-balmora\musikkkk]],
			-- [[Q:\audio-balmora\muzica]],
			[[V:\]] -- cinema
		}
	}
	op = vim.tbl_extend('force', op, opts or {})
	require('telescope').extensions.undersort.undersort(op)
end


O.vote_movielens       = { desc = "Oil: Rate on movielens", callback = F.rate_on_movielens }
O.open_explorer        = { desc = "Oil: Open dir in explorer", callback = F.open_in_explorer }
O.open_external        = { desc = "Oil: Open (shell)", callback = F.open_via_shell }
O.move_category        = { desc = "Oil: Move to _category", callback = F.move_to_cat }
O.move_category_delete = { desc = "Oil: Move to _delete", callback = F.move_to_cat_delete }
O.select_custom        = { desc = "Oil: Select (custom)", callback = F.select_custom }


O.sort_mtime = { desc = "Oil: Sort by mtime", callback = F.sort_by_mtime }
O.sort_size  = { desc = "Oil: Sort by size", callback = F.sort_by_size }


local UserComm = vim.api.nvim_create_user_command
UserComm('OilVlcRar', F.vlc_rar, { desc = 'open rar in vlc (extract to c:/tmp)' })
UserComm('OilCd2Entry', F.cd_to_entry, { desc = 'cd to entry' })

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

			keymaps = {
				['gSt'] = O.sort_mtime,
				['gSs'] = O.sort_size,

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
			},
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
