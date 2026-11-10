
-- the own extensions (mycolors, mydirs, mylunsj, undersort) load on UIEnter in lua/genja/auto.lua


---@type LazySpec
return {
	{
		'nvim-telescope/telescope.nvim',
		-- branch = '0.1.x',
		dependencies = {
			'nvim-lua/plenary.nvim',
			-- 'LinArcX/telescope-env.nvim', repo gone
		},
		config = true
	},



	{ 'nvim-telescope/telescope-symbols.nvim', event = 'VeryLazy', lazy = true }, -- UIEnter
	-- {  'barrett-ruth/telescope-http.nvim', event = 'VeryLazy', lazy = true,
	-- 	cmd = 'Telescope http list',
	-- 	config = function()
	-- 		-- require('telescope').setup({
	-- 		-- 	extensions = { http = {
	-- 		-- 		open_url = 'xdg-open %s' -- UNIX
	-- 		-- 		-- open_url = 'open %s' -- OSX
	-- 		-- 		-- open_url = 'start %s' -- Windows
	-- 		-- 	}}})
	-- 		require('telescope').load_extension 'http'
	-- 	end },
}
