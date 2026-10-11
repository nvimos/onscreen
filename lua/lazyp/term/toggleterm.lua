return {
	-- vim-floaterm is better?
	'akinsho/toggleterm.nvim',
	version = "*",
	opts = {},
	open_mapping = [[<c-\>]],
	config = function()
		require("toggleterm").setup {
			close_on_exit = false
		}
	end,

}
