-- Keys for lua/lazyp/phunnee/celular-automaton.lua.

---@param Maps genja.MapPlugin
return function(Maps)
	local spec_name = Maps.current_file()

	Maps:add_keys(spec_name, {
		{ '<leader>fml-', '<cmd>CellularAutomaton make_it_rain<cr>', silent = true, desc = 'fml-1' },
		{ '<leader>fml=', '<cmd>CellularAutomaton scramble<cr>',     silent = true, desc = 'fml-2' },
	})
end
