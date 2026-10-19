-- f2 init.lua sorting: group_order, unknown groups A-Z, order, label.
-- Pure function; runs in the test process.

local eq = MiniTest.expect.equality
local f2 = require('genja.f2')

local function sorted(tasks)
	local entries = {}
	for _, t in ipairs(tasks) do
		table.insert(entries, { task = t })
	end
	f2._sort(entries)
	local out = {}
	for _, e in ipairs(entries) do
		table.insert(out, e.task.group .. ': ' .. e.task.label)
	end
	return out
end

local default_order = vim.deepcopy(f2.group_order)

local T = MiniTest.new_set({
	hooks = {
		post_case = function() f2.group_order = vim.deepcopy(default_order) end,
	},
})

T['groups follow group_order, others after it A-Z'] = function()
	eq(sorted({
		{ group = 'zeta', label = 'x' },
		{ group = 'make', label = 'x' },
		{ group = 'alpha', label = 'x' },
		{ group = 'adhoc', label = 'x' },
		{ group = 'git', label = 'x' },
	}), { 'adhoc: x', 'git: x', 'make: x', 'alpha: x', 'zeta: x' })
end

T['order within a group, missing order counts as 0'] = function()
	eq(sorted({
		{ group = 'make', label = 'c', order = 2 },
		{ group = 'make', label = 'b' },
		{ group = 'make', label = 'a', order = 1 },
	}), { 'make: b', 'make: a', 'make: c' })
end

T['same order sorts by label'] = function()
	eq(sorted({
		{ group = 'demo', label = 'go to top' },
		{ group = 'demo', label = 'go to bottom' },
	}), { 'demo: go to bottom', 'demo: go to top' })
end

T['caller can replace group_order'] = function()
	f2.group_order = { 'test', 'make' }
	eq(sorted({
		{ group = 'make', label = 'x' },
		{ group = 'adhoc', label = 'x' },
		{ group = 'test', label = 'x' },
	}), { 'test: x', 'make: x', 'adhoc: x' })
end

return T
