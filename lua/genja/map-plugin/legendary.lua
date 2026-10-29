-- Keys for lua/lazyp/new/legendary.lua.

---@param Maps genja.MapPlugin
return function(Maps)
	local spec_name = Maps.current_file()

	Maps:add_keys(spec_name, {
		{ '<leader>jl', '<Cmd>Legendary<CR>', desc = 'Jump: legend (keymaps, commands, autocmds)' },
	})
end
