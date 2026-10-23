-- Keys for lua/lazyp/git/neogit.lua.

---@param Maps genja.MapPlugin
return function(Maps)
	local spec_name = Maps.current_file()

	Maps:add_keys(spec_name, {
		{ '<leader>mg', '<cmd>Neogit<cr>', desc = 'UI: git status (Neogit)' },
		{ '<leader>mGl', '<cmd>Neogit log<cr>', desc = 'UI: git log (Neogit)' },
	})
end
