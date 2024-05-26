-- https://github.com/nvim-telescope/telescope-live-grep-args.nvim

vim.api.nvim_create_autocmd({'UIEnter'} , {
	group = vim.api.nvim_create_augroup('Plugins', { clear = false }),
	callback = function(_)
		local ok, ts = pcall(require, 'telescope')
		if not ok then
			error 'cannot load nvim-telescope/telescope.nvim'
		else
			ts.load_extension 'mycolors'
			ts.load_extension 'undersort'
		end

	end, })


return {
	{
		'nvim-telescope/telescope.nvim',
		branch = '0.1.x',
		dependencies = {
			'nvim-lua/plenary.nvim',
			'LinArcX/telescope-env.nvim',
		},
		config = true
	},


	{  'nvim-telescope/telescope-symbols.nvim', event = 'VeryLazy', lazy = true }, -- UIEnter
	{  'barrett-ruth/telescope-http.nvim', event = 'VeryLazy', lazy = true,
		cmd = 'Telescope http list',
		config = function()
			-- require('telescope').setup({
			-- 	extensions = { http = {
			-- 		open_url = 'xdg-open %s' -- UNIX
			-- 		-- open_url = 'open %s' -- OSX
			-- 		-- open_url = 'start %s' -- Windows
			-- 	}}})
			require('telescope').load_extension 'http'
		end },
}
