-- local plugs = { {

return { {
	'nvimdev/dashboard-nvim',
	enabled = false,
	lazy = false,
	keys = {
		{ '<leader>jD', vim.cmd.Dashboard,  desc = 'Dashboard' },
	},
	event = 'VimEnter',
	config = function()

		vim.api.nvim_create_autocmd({'UIEnter'}, {
			group = vim.api.nvim_create_augroup('rename-dashboard', { clear = true }),
			callback = function(ev)
				if 'dashboard' == vim.bo[ev.buf].filetype then
					vim.api.nvim_buf_set_name(ev.buf, 'Dashboard')
				end
			end,
		})
		--
		require('dashboard').setup({
			buffer_name = 'Dashi',
			theme = 'hooper', -- based on hyper
			shortcut_type = 'letter' or 'number',
			disable_move = false,
			hide = { statusline = false, tabline = false, winbar = false, },
			config = {

				week_header = { enable = true, concat = '', append = { '' } },

				packages = { enable = true },
				shortcut = {
					{ icon = '', key = '.', desc = 'goto', action = 'Telescope mydirs', group = 'DevIconFavicon', icon_hl = '@variable', },
					{ icon = '', key = 'o', desc = 'old',  action = 'Telescope oldfiles',        group = 'DevIconFavicon', icon_hl = '@variable', },
					{            key = 't', desc = 'tele', action = 'Telescope',                 group = 'DevIconFavicon', },
					{            key = 'g', desc = 'git',    action = 'Git',                  group = 'Git', },
					{            key = 'm', desc = 'mason',  action = 'Mason',                group = 'String', },
					{            key = 'l', desc = 'lazy',   action = 'Lazy',                 group = 'String', },
					{            key = 'p', desc = 'lua',    action = 'Luapad',               group = 'DevIconMATE', },
				},
				project = { enable = true, limit = 8, icon = " ",  icon_hl = 'Git',        group = 'DevIconHuff', label = 'Proyect    ' },
				mru =     { enable = true, limit = 7, icon = "  ", icon_hl = 'DevIconMd5', group = 'DevIconHuff', label = 'Recientes', cwd_only = false }, -- icon = 'your icon',
				center = { { action = "", label = "fooz" }, },
				footer = { "f00t3R", },
			},
		})
	end,
	dependencies = { {'nvim-tree/nvim-web-devicons'}}
} }


-- vim.list_extend(P or {}, plugs)
-- return P


-- 2024-08
-- require('dashboard').setup({
-- 	buffer_name = 'Dashi',
-- 	theme = 'hooper', -- based on hyper
-- 	shortcut_type = 'letter' or 'number',
-- 	disable_move = false,
-- 	hide = { statusline = false, tabline = false, winbar = false, },
-- 	config = {
--
-- 		week_header = { enable = true, concat = '', append = { '' } },
--
-- 		packages = { enable = true },
-- 		shortcut = {
-- 			--[[ 🎩 💃  󰍉 ]]
--
-- 			-- { icon = '', key = '.', desc = 'find', action = 'Telescope find_files',      group = 'DevIconFavicon', icon_hl = 'DevIconsFish', },
-- 			-- { icon = '', key = '/', desc = 'dirs', action = 'lua Telescope_find_dirs()', group = 'DevIconFavicon', icon_hl = '@variable', },
-- 			{ icon = '', key = '.', desc = 'goto', action = 'Telescope mydirs', group = 'DevIconFavicon', icon_hl = '@variable', },
--
-- 			{ icon = '', key = 'o', desc = 'old',  action = 'Telescope oldfiles',        group = 'DevIconFavicon', icon_hl = '@variable', },
-- 			{            key = 't', desc = 'tele', action = 'Telescope',                 group = 'DevIconFavicon', },
--
-- 			-- { icon = ' ', key = '.', desc = '󰍉',   action = 'Telescope find_files',      group = 'Label', icon_hl = '@variable', },
-- 			-- { icon = ' ', key = '/', desc = '',     action = 'lua Telescope_find_dirs()', group = 'Label', icon_hl = '@variable', },
-- 			-- { icon = ' ', key = '/', desc = '<>',  action = 'lua Telescope oldfiles', group = 'Label', icon_hl = '@variable', },
--
-- 			{            key = 'g', desc = 'git',    action = 'Git',                  group = 'Git', },
-- 			{            key = 'm', desc = 'mason',  action = 'Mason',                group = 'String', },
-- 			{            key = 'l', desc = 'lazy',   action = 'Lazy',                 group = 'String', },
-- 			{            key = 'p', desc = 'lua',    action = 'Luapad',               group = 'DevIconMATE', },
-- 			--{ icon = '', key = 'u' , desc = 'update',    action = 'Lazy update',          group = '@property' },
-- 			-- { icon = ' ', key = 'a', desc = 'Apps',       action = 'Telescope app',        group = 'DiagnosticHint', },
-- 			-- {              key = 'd', desc = 'dotfiles', action = 'Telescope dotfiles',   group = 'zNumber', },
-- 		},
--
-- 		--project = { enable = true, limit = 8, icon = 'your icon', label = '', action = 'Telescope find_files cwd=' },
-- 		project = { enable = true, limit = 8, icon = " ",  icon_hl = 'Git',        group = 'DevIconHuff', label = 'Proyect    ' },
-- 		mru =     { enable = true, limit = 7, icon = "  ", icon_hl = 'DevIconMd5', group = 'DevIconHuff', label = 'Recientes', cwd_only = false }, -- icon = 'your icon',
-- 		center = {
-- 			{ action = "", label = "fooz" },
-- 		},
--
--
-- 		-- footer = { vim.fn.getcwd(), },
-- 		footer = { "f00t3R", },
-- 	},
-- })
