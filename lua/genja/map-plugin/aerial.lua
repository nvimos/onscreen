-- Keys for lua/lazyp/ui/aerial.lua.
-- Usage: doc-wip/readme.idea13-dropbar-aerial.outer-key.md

---@param Maps genja.MapPlugin
return function(Maps)
	local spec_name = Maps.current_file()

	Maps:add_keys(spec_name, {
		-- ! keeps the cursor in the code
		{ '<c-s>',      '<cmd>AerialToggle!<cr>',   desc = 'UI: outline sidebar (aerial)' },
		{ '<leader>mo', '<cmd>AerialToggle!<cr>',   desc = 'UI: outline sidebar (aerial)' },
		{ '<leader>mO', '<cmd>AerialNavToggle<cr>', desc = 'UI: outline nav float (aerial)' },
		-- same two under their own prefix
		{ '<leader>oo', '<cmd>AerialToggle!<cr>',   desc = 'Outline: sidebar (aerial)' },
		{ '<leader>oO', '<cmd>AerialNavToggle<cr>', desc = 'Outline: nav float (aerial)' },
		-- extension loaded here, so [o ]o don't pull in telescope
		{ '<leader>ja', function()
			require('telescope').load_extension('aerial')
			vim.cmd('Telescope aerial')
		end, desc = 'Telescope: aerial symbols' },
		-- not { }: those stay paragraph motions; [a ]a are nvim's arglist maps
		{ '[o', '<cmd>AerialPrev<cr>', desc = 'Outline: previous symbol' },
		{ ']o', '<cmd>AerialNext<cr>', desc = 'Outline: next symbol' },
	})
end
