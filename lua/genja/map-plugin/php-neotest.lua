-- Keys for lua/lazyp/langs/php-neotest.lua.

---@param Maps genja.MapPlugin
return function(Maps)
	local spec_name = Maps.current_file()

	Maps:add_keys(spec_name, {
		{ '<leader>Tr', function() require('neotest').run.run() end,                      desc = 'Test: nearest' },
		{ '<leader>Tf', function() require('neotest').run.run(vim.fn.expand('%')) end,    desc = 'Test: file' },
		{ '<leader>Ts', function() require('neotest').summary.toggle() end,               desc = 'Test: summary' },
		{ '<leader>To', function() require('neotest').output.open({ enter = true }) end, desc = 'Test: output' },
	})
end
