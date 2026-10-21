-- Keys for lua/lazyp/my/mru.lua.

---@param Maps genja.MapPlugin
return function(Maps)
	local spec_name = Maps.current_file()

	Maps:add_keys(spec_name, {
		{ '<S-F1>', '<cmd>lua CheckAndRunMRU()<cr>', silent = true, desc = 'MRU: toggle' },
	})
end
