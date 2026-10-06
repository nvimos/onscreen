return {
	'eandrju/cellular-automaton.nvim',
	cmd = 'CellularAutomaton',
	lazy = false,
	keys = {
		{ '<leader>fml-', '<cmd>CellularAutomaton make_it_rain<cr>', { noremap = true, silent = true, desc = "fml-1" } },
		{ '<leader>fml=', '<cmd>CellularAutomaton scramble<cr>',     { noremap = true, silent = true, desc = "fml-2" } }
	},
}
