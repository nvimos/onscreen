-- https://github.com/nvim-telescope/telescope-live-grep-args.nvim
return {

	{  'nvim-telescope/telescope-symbols.nvim', event = 'VeryLazy', lazy = true }, -- UIEnter
	{
		'nvim-telescope/telescope.nvim',
		branch = '0.1.x',
		dependencies = {
			'nvim-lua/plenary.nvim',
			'LinArcX/telescope-env.nvim',
		},
		config = true
	},
}
