-- `make test-gui` runs this in nvim-qt: test_state_gui.lua after UIEnter, report to
-- gui-report.txt (make prints it), then quit. The buffer reporter shows progress meanwhile.

local REPORT = 'gui-report.txt'

---@return string[] lines
---@return integer fails
local function report_lines()
	local lines = {}
	local fails = 0
	for _, case in ipairs(MiniTest.current.all_cases or {}) do
		local exec = case.exec or {}
		local state = exec.state or 'Not run'
		table.insert(lines, state .. ': ' .. table.concat(case.desc, ' | '))
		for _, fail in ipairs(exec.fails or {}) do
			fails = fails + 1
			for _, line in ipairs(vim.split(fail, '\n')) do
				table.insert(lines, '    ' .. line)
			end
		end
		for _, note in ipairs(exec.notes or {}) do
			table.insert(lines, '    note: ' .. note)
		end
	end
	return lines, fails
end

local buffer = MiniTest.gen_reporter.buffer()

local reporter = {
	start = buffer.start,
	update = buffer.update,
	finish = function()
		buffer.finish()
		local lines, fails = report_lines()
		vim.fn.writefile(lines, REPORT)
		if fails > 0 then
			vim.cmd('cquit 1')
		else
			vim.cmd('qall!')
		end
	end,
}

-- -c runs before nvim-qt answers Gui* calls
vim.api.nvim_create_autocmd('UIEnter', {
	once = true,
	callback = function()
		vim.defer_fn(function()
			MiniTest.run_file('test_state_gui.lua', { execute = { reporter = reporter } })
		end, 500)
	end,
})
