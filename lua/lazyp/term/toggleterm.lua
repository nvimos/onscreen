---@type LazySpec
return {
	-- vim-floaterm is better?
	'akinsho/toggleterm.nvim',
	version = "*",
	cmd = {
		'ToggleTerm', 'ToggleTermToggleAll', 'TermExec', 'TermSelect', 'ToggleTermSetName',
		'ToggleTermSendCurrentLine', 'ToggleTermSendVisualLines', 'ToggleTermSendVisualSelection',
	},
	keys = { { [[<c-\>]], desc = 'Terminal: toggle' } }, -- first press loads it; open_mapping takes over
	---@type ToggleTermConfig
	opts = { -- lazy passes this to require('toggleterm').setup()
		open_mapping = [[<c-\>]],
		close_on_exit = false,
	},

}
