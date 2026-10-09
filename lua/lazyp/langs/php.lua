-- PHP plugins on top of genja's LSP setup (plug-wip/genja-completion011.nvim/lua/genja/lang/php.lua).

---Is the directory Neovim started in a Laravel project?
local function laravel()
	return vim.uv.fs_stat('artisan') ~= nil
end

return {
	-- Tests: run the nearest test, a file or the suite, with results inline.
	{
		'nvim-neotest/neotest',
		ft = 'php',
		dependencies = {
			'nvim-neotest/nvim-nio',
			'nvim-lua/plenary.nvim',
			'nvim-treesitter/nvim-treesitter',
			'olimorris/neotest-phpunit',
			'V13Axel/neotest-pest',
		},
		keys = {
			{ '<leader>Tr', function() require('neotest').run.run() end, desc = 'Test: nearest' },
			{ '<leader>Tf', function() require('neotest').run.run(vim.fn.expand('%')) end, desc = 'Test: file' },
			{ '<leader>Ts', function() require('neotest').summary.toggle() end, desc = 'Test: summary' },
			{ '<leader>To', function() require('neotest').output.open({ enter = true }) end, desc = 'Test: output' },
		},
		config = function()
			require('neotest').setup({
				adapters = {
					require('neotest-pest'),
					-- Pest projects also have phpunit; leave those to neotest-pest.
					require('neotest-phpunit')({ root_ignore_files = { 'tests/Pest.php' } }),
				},
			})
		end,
	},

	-- Laravel: artisan, routes and make pickers; gf on views, routes, config keys.
	-- Only loads when Neovim starts in a Laravel project (artisan in the cwd).
	{
		'adalessa/laravel.nvim',
		cond = laravel,
		ft = { 'php', 'blade' },
		dependencies = {
			'MunifTanjim/nui.nvim',
			'nvim-lua/plenary.nvim',
			'nvim-neotest/nvim-nio',
		},
		keys = {
			{ '<leader>ll', function() Laravel.pickers.laravel() end, desc = 'Laravel: picker' },
			{ '<leader>la', function() Laravel.pickers.artisan() end, desc = 'Laravel: artisan' },
			{ '<leader>lr', function() Laravel.pickers.routes() end, desc = 'Laravel: routes' },
			{ '<leader>lm', function() Laravel.pickers.make() end, desc = 'Laravel: make' },
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
		},
		opts = {
			features = { pickers = { provider = 'telescope' } },
		},
	},

	-- Blade: gf on @include, @extends and <x-component> opens the view.
	{
		'ricardoramirezr/blade-nav.nvim',
		cond = laravel,
		ft = { 'blade', 'php' },
		dependencies = { 'hrsh7th/nvim-cmp' },
		opts = {},
	},
}
