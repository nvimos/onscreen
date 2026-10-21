local Maps = require('genja.map-plugin')

---@type LazySpec
return {
	-- vim-floaterm is better?
	'akinsho/toggleterm.nvim',
	version = "*",
	cmd = {
		'ToggleTerm', 'ToggleTermToggleAll', 'TermExec', 'TermSelect', 'ToggleTermSetName',
		'ToggleTermSendCurrentLine', 'ToggleTermSendVisualLines', 'ToggleTermSendVisualSelection',
	},
	keys = Maps:keys(), -- first press loads it; open_mapping takes over
	---@type ToggleTermConfig
	opts = { -- lazy passes this to require('toggleterm').setup()
		open_mapping = [[<c-\>]],
		close_on_exit = false,
	},

}
