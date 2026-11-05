-- Keys for lua/lazyp/debug/dap-php.lua.

---@param Maps genja.MapPlugin
return function(Maps)
	local spec_name = Maps.current_file()

	Maps:add_keys(spec_name, {
		{ '<leader>db', function() require('dap').toggle_breakpoint() end, desc = 'Debug: toggle breakpoint' },
		{ '<leader>dc', function()
			require('genja.ext.debug-ddev').check(vim.api.nvim_get_current_buf())
			require('dap').continue()
			require('genja.ext.debug-fkeys').arm()
		end, desc = 'Debug: start / continue' },
		{ '<leader>do', function() require('dap').step_over() end,         desc = 'Debug: step over' },
		{ '<leader>di', function() require('dap').step_into() end,         desc = 'Debug: step into' },
		{ '<leader>dx', function() require('dap').terminate() end,         desc = 'Debug: stop' },
		{ '<leader>du', function() require('dapui').toggle() end,          desc = 'Debug: toggle UI' },
		{ '<leader>dK', function() require('dap.ui.widgets').hover() end,  desc = 'Debug: hover value' },
		-- true: open the quickfix list; rejected breakpoints show the adapter's message.
		{ '<leader>dl', function() require('dap').list_breakpoints(true) end, desc = 'Debug: list breakpoints (quickfix)' },
		{ '<leader>dB', function()
			require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))
		end, desc = 'Debug: breakpoint with condition' },
		{ '<leader>dp', function()
			require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message ({expr} interpolates): '))
		end, desc = 'Debug: log point (prints, no stop)' },
	})
end
