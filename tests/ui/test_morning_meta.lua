-- :Morning's Todo section: open Backlog.md tasks of the meta checkout (lua/genja/ext/morning.lua),
-- in progress first, then needs test, then to do; done and dropped ones left out.

local C = require('helpers.child')
local eq = MiniTest.expect.equality

local child, T = C.fresh(C.TMP .. [[
	vim.fn.mkdir(tmp .. '/backlog/tasks', 'p')
	_G.task = function(n, status, title)
		vim.fn.writefile({ '---', 'id: TASK-' .. n, "title: '" .. title .. "'", 'status: ' .. status, '---', '' },
			tmp .. '/backlog/tasks/task-' .. n .. ' - x.md')
	end
	vim.g.genja_meta_dir = tmp
	-- the Todo lines of the morning page
	_G.todo_lines = function()
		vim.cmd('Morning')
		local out, on = {}, false
		for _, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
			if line:find('^## Todo') then
				on = true
			elseif line:find('^## ') then
				on = false
			elseif on and line ~= '' then
				table.insert(out, vim.trim(line))
			end
		end
		return out
	end
	require('genja.ext.morning')
	vim.cmd.runtime('plugin/morning.lua')
]])

T['open tasks by status; done and dropped left out'] = function()
	child.lua([[
		task(1, 'To Do', 'b to do')
		task(2, 'Done', 'finished')
		task(3, 'Needs Test', 'try me')
		task(4, 'In Progress', 'busy')
		task(5, 'Dropped', 'nope')
		task(6, 'To Do', 'a to do')
	]])
	eq(C.eval(child, 'todo_lines()'), {
		'In Progress busy',
		'Needs Test  try me',
		'To Do       a to do',
		'To Do       b to do',
	})
end

T['no meta checkout: an empty section, no error'] = function()
	child.lua([[vim.g.genja_meta_dir = tmp .. '/missing']])
	eq(C.eval(child, 'todo_lines()'), {})
end

return T
