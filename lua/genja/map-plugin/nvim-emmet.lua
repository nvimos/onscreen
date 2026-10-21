-- Mappings for lua/lazyp/langs-comps/nvim-emmet.lua.

---@param Maps genja.MapPlugin
return function(Maps)
	local spec_name = Maps.current_file()

	Maps:add_mappings(spec_name, function(_)
		vim.keymap.set({ 'n', 'v' }, '<leader>xe', require('nvim-emmet').wrap_with_abbreviation)
	end)
end
