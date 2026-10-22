-- Keys for lua/lazyp/new/genja-splitpad.lua.

---@param Maps genja.MapPlugin
return function(Maps)
	local spec_name = Maps.current_file()

	Maps:add_keys(spec_name, {
		{ '<leader>tp', function() require('genja-splitpad').toggle() end, desc = 'Toggle: split padding' },
	})
end
