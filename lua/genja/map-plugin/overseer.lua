-- Keys for lua/lazyp/maybe/overseer.lua.

---@param Maps genja.MapPlugin
return function(Maps)
	local spec_name = Maps.current_file()

	Maps:add_keys(spec_name, {
		{ '<leader>mxo', '<cmd>OverseerClose<cr>', silent = true, desc = 'UI: close overseer' },
	})
end
