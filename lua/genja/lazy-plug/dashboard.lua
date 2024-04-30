-- local plugs = { {

return { {
	'nvimdev/dashboard-nvim',
	lazy = false,
	keys = {
		{ '<leader>jD', vim.cmd.Dashboard,  desc = 'Dashboard' },
	},
	event = 'VimEnter',
	config = function()
		require('dashboard').setup({
			theme = 'hyper',
			shortcut_type = 'letter' or 'number',
			disable_move = false,
			hide = { statusline = true, tabline = false, winbar = false, },
			config = {

				week_header = { enable = true, concat = '', append = { foo = '-bar-' } },
				packages = { enable = true },
				shortcut = {
					--[[ 🎩 💃  󰍉 ]]

					{ icon = '', key = '.', desc = 'find', action = 'Telescope find_files',      group = 'DevIconFavicon', icon_hl = 'DevIconsFish', },
					{ icon = '', key = '/', desc = 'dirs', action = 'lua Telescope_find_dirs()', group = 'DevIconFavicon', icon_hl = '@variable', },
					{ icon = '', key = 'o', desc = 'old',  action = 'Telescope oldfiles',    group = 'DevIconFavicon', icon_hl = '@variable', },

					-- { icon = ' ', key = '.', desc = '󰍉',   action = 'Telescope find_files',      group = 'Label', icon_hl = '@variable', },
					-- { icon = ' ', key = '/', desc = '',     action = 'lua Telescope_find_dirs()', group = 'Label', icon_hl = '@variable', },
					-- { icon = ' ', key = '/', desc = '<>',  action = 'lua Telescope oldfiles', group = 'Label', icon_hl = '@variable', },

					{            key = 'g', desc = 'git',    action = 'Git',                  group = 'Git', },
					{            key = 'm', desc = 'mason',  action = 'Mason',                group = 'DevIconMATE', },
					{            key = 'l', desc = 'lazy',   action = 'Lazy',                 group = 'String', },
					{            key = 't', desc = 'tele',   action = 'Telescope',            group = 'DiagnosticHint', },
					{            key = 'p', desc = 'lua',    action = 'Luapad',            group = '@property', },
					--{ icon = '', key = 'u' , desc = 'update',    action = 'Lazy update',          group = '@property' },
					-- { icon = ' ', key = 'a', desc = 'Apps',       action = 'Telescope app',        group = 'DiagnosticHint', },
					-- {              key = 'd', desc = 'dotfiles', action = 'Telescope dotfiles',   group = 'zNumber', },
				},

				--project = { enable = true, limit = 8, icon = 'your icon', label = '', action = 'Telescope find_files cwd=' },
				project = { enable = true, limit = 8, icon = " ",  icon_hl = 'Git',        group = 'DevIconHuff', label = 'Proyect    ' },
				mru =     { enable = true, limit = 7, icon = "  ", icon_hl = 'DevIconMd5', group = 'DevIconHuff', label = 'Recientes', cwd_only = false }, -- icon = 'your icon', 
				center = {
					{ action = "", label = "fooz" },
				},


				footer = { vim.fn.getcwd(), },
			},
		})
	end,
	dependencies = { {'nvim-tree/nvim-web-devicons'}}
} }


-- vim.list_extend(P or {}, plugs)
-- return P
