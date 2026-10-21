-- Mappings for lua/lazyp/new/harpoon.lua.

---@param Maps genja.MapPlugin
return function(Maps)
	local spec_name = Maps.current_file()

	Maps:add_mappings(spec_name, function(_)
		local mark = require('harpoon.mark')
		local ui = require('harpoon.ui')

		vim.keymap.set('n', '<leader>ea', mark.toggle_file, { desc = 'harpoon mark on/off' })
		vim.keymap.set('n', '<leader>ej', function() ui.toggle_quick_menu() end, { desc = 'harpoon quickmenu' })

		-- vim.keymap.set('n', '<M-e>', function() ui.toggle_quick_menu() end, { desc = 'harpoon quickmenu' })
		-- vim.keymap.set('n', '<M-j>', function() ui.nav_file(1) end, { desc = 'harpoon 1' })
		-- vim.keymap.set('n', '<M-w>', function() ui.nav_file(2) end, { desc = 'harpoon 2' })
		-- vim.keymap.set('n', '<M-f>', function() ui.nav_file(3) end, { desc = 'harpoon 3' })
		-- vim.keymap.set('n', '<M-p>', function() ui.nav_file(4) end, { desc = 'harpoon 4' })
	end)
end
