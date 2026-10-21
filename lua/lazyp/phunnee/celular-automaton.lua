local Maps = require('genja.map-plugin')

---@type LazySpec
return {
	'eandrju/cellular-automaton.nvim',
	cmd = 'CellularAutomaton',
	lazy = false,
	keys = Maps:keys(),
}
