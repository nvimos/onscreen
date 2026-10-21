-- Keys for lua/lazyp/my/vim-easy-align.lua.

---@param Maps genja.MapPlugin
return function(Maps)
	local spec_name = Maps.current_file()

	Maps:add_keys(spec_name, {
		-- Start interactive EasyAlign in visual mode (e.g. vipga)          -- nmap ga <Plug>(EasyAlign)
		-- Start interactive EasyAlign for a motion/text object (e.g. gaip) -- xmap ga <Plug>(EasyAlign)
		{ 'ga', '<plug>(EasyAlign)', mode = { 'n', 'x', }, desc = 'EasyAlign', silent = true },
	})
end
