-- Keys for lua/lazyp/new/abdul-keymaps.lua.

---@param Maps genja.MapPlugin
return function(Maps)
	local spec_name = Maps.current_file()

	Maps:add_keys(spec_name, {
		{ '<leader>?', '<cmd>Keymaps<cr>', desc = 'Show Keymaps' },
	})
end
