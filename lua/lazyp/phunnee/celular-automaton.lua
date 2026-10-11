---@type LazySpec
return {
	'eandrju/cellular-automaton.nvim',
	cmd = 'CellularAutomaton',
	lazy = false,
	keys = {
		{ '<leader>fml-', '<cmd>CellularAutomaton make_it_rain<cr>', silent = true, desc = "fml-1" },
		{ '<leader>fml=', '<cmd>CellularAutomaton scramble<cr>',     silent = true, desc = "fml-2" }
	},
}
