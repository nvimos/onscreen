-- Keys for lua/lazyp/langs-comps/codecompanion.lua.

---@param Maps genja.MapPlugin
return function(Maps)
	local spec_name = Maps.current_file()

	Maps:add_keys(spec_name, {
		{ '<leader>ac', '<cmd>CodeCompanionChat Toggle<cr>', desc = 'idea 19 companion: chat toggle' },
		{ '<leader>aa', '<cmd>CodeCompanionActions<cr>',     desc = 'idea 19 companion: action palette' },
		-- ':' (not <cmd>) so the visual range reaches the command
		{ '<leader>aa', ':CodeCompanionActions<cr>', mode = 'x', desc = 'idea 19 companion: action palette (selection)' },
	})
end
