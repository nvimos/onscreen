-- Keys for lua/lazyp/debug/dap-php.lua.

---@param Maps genja.MapPlugin
return function(Maps)
	local spec_name = Maps.current_file()

	Maps:add_keys(spec_name, {
		{ '<leader>db', function() require('dap').toggle_breakpoint() end, desc = 'Debug: toggle breakpoint' },
		{ '<leader>dc', function() require('dap').continue() end,          desc = 'Debug: start / continue' },
		{ '<leader>do', function() require('dap').step_over() end,         desc = 'Debug: step over' },
		{ '<leader>di', function() require('dap').step_into() end,         desc = 'Debug: step into' },
		{ '<leader>dx', function() require('dap').terminate() end,         desc = 'Debug: stop' },
		{ '<leader>du', function() require('dapui').toggle() end,          desc = 'Debug: toggle UI' },
	})
end
