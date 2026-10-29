-- Keys for lua/lazyp/new/ccc.lua.

---@param Maps genja.MapPlugin
return function(Maps)
	local spec_name = Maps.current_file()

	Maps:add_keys(spec_name, {
		{ '<leader>ic', '<Cmd>CccPick<CR>', desc = 'Insert: colour pick (or edit under cursor)' },
		{ '<leader>tc', '<Cmd>CccHighlighterToggle<CR>', desc = 'Toggle: colour highlight' },
	})
end
