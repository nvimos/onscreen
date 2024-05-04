-- local plugs = { {

return { {
	'nvimdev/dashboard-nvim',
	lazy = false,
	keys = {
		{ '<leader>jD', vim.cmd.Dashboard,  desc = 'Dashboard' },
	},
	event = 'VimEnter',
	config = function()

		-- vim.g.da = "nyet"
		-- vim.api.nvim_create_autocmd({'BufFilePost', 'BufNew', 'FileType', 'UIEnter',}, {
		-- 	group = vim.api.nvim_create_augroup('rename-dashboard', { clear = true }),
		-- 	callback = function(ev)  --  buf, event, file, group, id, match
		-- 		vim.g.da = "ft:" .. vim.bo[ev.buf].filetype
		-- 		vim.g.da = ev
		-- 		local b = vim.bo[ev.buf]
		-- 		local bname = vim.api.nvim_buf_get_name(ev.buf)
		-- 		print("DASH2", bname, "--", vim.bo[ev.buf].filetype)
		-- 		if "dashboard" == vim.bo[ev.buf].filetype then
		-- 			print("DASH", bname)
		-- 			vim.api.nvim_buf_set_name(ev.buf, "Dashboard")
		-- 			-- print(vim.inspect(vim.bo[ev.buf]))
		-- 		end
		-- 		-- if vim.fn.argc() == 0 and vim.api.nvim_buf_get_name(0) == '' then
		-- 		-- require('dashboard'):instance()
		-- 		-- end
		-- 		-- vim.cmd("MRU")
		-- 	end,
		-- })
	
		--
		--vim.api.nvim_create_autocmd({'FileType'}, {
		vim.api.nvim_create_autocmd({'UIEnter'}, {
			group = vim.api.nvim_create_augroup('rename-dashboard', { clear = true }),
			callback = function(ev)
				if "dashboard" == vim.bo[ev.buf].filetype then
					vim.api.nvim_buf_set_name(ev.buf, "Dashboard")
				end
			end,
		})
		--
		require('dashboard').setup({
			theme = 'hyper',
			shortcut_type = 'letter' or 'number',
			disable_move = false,
			hide = { statusline = false, tabline = false, winbar = false, },
			config = {

				week_header = { enable = true, concat = '', append = { foo = '-bar-' } },
				packages = { enable = true },
				shortcut = {
					--[[ 🎩 💃  󰍉 ]]

					{ icon = '', key = '.', desc = 'find', action = 'Telescope find_files',      group = 'DevIconFavicon', icon_hl = 'DevIconsFish', },
					{ icon = '', key = '/', desc = 'dirs', action = 'lua Telescope_find_dirs()', group = 'DevIconFavicon', icon_hl = '@variable', },
					{ icon = '', key = 'o', desc = 'old',  action = 'Telescope oldfiles',        group = 'DevIconFavicon', icon_hl = '@variable', },
					{            key = 't', desc = 'tele', action = 'Telescope',                 group = 'DevIconFavicon', },

					-- { icon = ' ', key = '.', desc = '󰍉',   action = 'Telescope find_files',      group = 'Label', icon_hl = '@variable', },
					-- { icon = ' ', key = '/', desc = '',     action = 'lua Telescope_find_dirs()', group = 'Label', icon_hl = '@variable', },
					-- { icon = ' ', key = '/', desc = '<>',  action = 'lua Telescope oldfiles', group = 'Label', icon_hl = '@variable', },

					{            key = 'g', desc = 'git',    action = 'Git',                  group = 'Git', },
					{            key = 'm', desc = 'mason',  action = 'Mason',                group = 'String', },
					{            key = 'l', desc = 'lazy',   action = 'Lazy',                 group = 'String', },
					{            key = 'p', desc = 'lua',    action = 'Luapad',               group = 'DevIconMATE', },
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
