-- Keys and mappings for lua/lazyp/langs-comps/copilot.lua.

---@param Maps genja.MapPlugin
return function(Maps)
	local spec_name = Maps.current_file()

	Maps:add_keys(spec_name, {
		{ '<leader>ap', '<cmd>Copilot panel<cr>',  desc = 'Copilot: panel of suggestions', silent = true },
		{ '<leader>as', '<cmd>Copilot status<cr>', desc = 'Copilot: status',               silent = true },
		{
			'<leader>at',
			function()
				-- :Copilot enable/disable act on all buffers.
				if vim.fn['copilot#Enabled']() == 1 then
					vim.cmd('Copilot disable')
				else
					vim.cmd('Copilot enable')
				end
				vim.cmd('Copilot status')
			end,
			desc = 'Copilot: toggle on/off',
			silent = true,
		},
	})

	Maps:add_mappings(spec_name, function(_)
		local km = vim.keymap.set
		km('i', '<M-f>',  'copilot#Accept("")',          { silent = true, desc = 'Copilot: accept', expr = true, replace_keycodes = false })
		km('i', '<M-w>',  '<Plug>(copilot-accept-word)', { silent = true, desc = 'Copilot: accept word' })
		km('i', '<M-j>',  '<Plug>(copilot-accept-line)', { silent = true, desc = 'Copilot: accept line' })
		km('i', '<M-]>',  '<Plug>(copilot-next)',        { silent = true, desc = 'Copilot: next suggestion' })
		km('i', '<M-[>',  '<Plug>(copilot-previous)',    { silent = true, desc = 'Copilot: previous suggestion' })
		km('i', '<C-]>',  '<Plug>(copilot-dismiss)',     { silent = true, desc = 'Copilot: dismiss' })
		km('i', '<M-\\>', '<Plug>(copilot-suggest)',     { silent = true, desc = 'Copilot: suggest now' })
	end)
end
