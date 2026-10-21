-- Keys for lua/lazyp/ui/zenmode.lua.

---@param Maps genja.MapPlugin
return function(Maps)
	local spec_name = Maps.current_file()

	Maps:add_keys(spec_name, {
		{ '<leader>mz', '<cmd>ZenMode<cr>', silent = true, desc = 'UI: toggle zen mode' },
	})
end
