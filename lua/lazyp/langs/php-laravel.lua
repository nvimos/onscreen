-- Laravel and Blade, on top of genja's PHP LSP setup (plug-wip/genja-completion011.nvim/lua/genja/lang/php.lua).
-- Both load only when Neovim starts in a Laravel project (artisan in the cwd).

local Maps = require('genja.map-plugin')

---Is the directory Neovim started in a Laravel project?
local function laravel()
	return vim.uv.fs_stat('artisan') ~= nil
end

---@type LazySpec
return {
	-- Laravel: artisan, routes and make pickers; gf on views, routes, config keys.
	{
		'adalessa/laravel.nvim',
		cond = laravel,
		ft = { 'php', 'blade' },
		dependencies = {
			'MunifTanjim/nui.nvim',
			'nvim-lua/plenary.nvim',
			'nvim-neotest/nvim-nio',
		},
		keys = Maps:keys(),
		opts = {
			features = { pickers = { provider = 'telescope' } },
		},
	},

	-- Blade: gf on @include, @extends and <x-component> opens the view.
	{
		'ricardoramirezr/blade-nav.nvim',
		cond = laravel,
		ft = { 'blade', 'php' },
		opts = {},
		config = function(_, opts)
			require('blade-nav').setup(opts)
			-- its own blink.cmp source: <x- components, route(' names
			local ok, blink = pcall(require, 'blink.cmp')
			if ok then
				blink.add_source_provider('blade-nav', { name = 'blade-nav', module = 'blade-nav.integrations.blink' })
				blink.add_filetype_source('blade', 'blade-nav')
				blink.add_filetype_source('php', 'blade-nav')
			end
		end,
	},
}
