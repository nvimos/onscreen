-- Keys for lua/lazyp/langs/php-laravel.lua (laravel.nvim; blade-nav has none).
-- Laravel is a global set by laravel.nvim once it loads.

---@param Maps genja.MapPlugin
return function(Maps)
	local spec_name = Maps.current_file()

	Maps:add_keys(spec_name, {
		{ '<leader>ll', function() Laravel.pickers.laravel() end, desc = 'Laravel: picker' },
		{ '<leader>la', function() Laravel.pickers.artisan() end, desc = 'Laravel: artisan' },
		{ '<leader>lr', function() Laravel.pickers.routes() end,  desc = 'Laravel: routes' },
		{ '<leader>lm', function() Laravel.pickers.make() end,    desc = 'Laravel: make' },
		{
			'gf',
			function()
				if Laravel.app('gf').cursorOnResource() then
					return "<cmd>lua Laravel.commands.run('gf')<cr>"
				end
				return 'gf'
			end,
			expr = true,
			ft = { 'php', 'blade' },
			desc = 'Laravel: go to resource',
		},
	})
end
