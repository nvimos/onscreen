-- Keys for lua/lazyp/term/toggleterm.lua.

---@param Maps genja.MapPlugin
return function(Maps)
	local spec_name = Maps.current_file()

	Maps:add_keys(spec_name, {
		-- No rhs: the first press loads the plugin; its opts.open_mapping takes over.
		{ [[<c-\>]], desc = 'Terminal: toggle' },
	})
end
