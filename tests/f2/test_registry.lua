-- f2.add_tasks / add_task / remove_tasks: scope, merge, cond, validation.
-- Runs in a fresh child nvim per case, so the registry starts empty.

local C = require('helpers.child')
local eq = MiniTest.expect.equality

local child, T = C.fresh(C.NOTES .. [[
	_G.f2 = require('genja.f2')
	_G.registry = require('genja.f2.registry')
	-- sorted 'group: label' of what <F2> would list from added tasks
	_G.labels = function(bufnr, filetype)
		local ctx = { dir = '.', bufnr = bufnr or vim.api.nvim_get_current_buf(), filetype = filetype or '' }
		local out = {}
		for _, e in ipairs(registry.list(ctx)) do
			table.insert(out, e.task.group .. ': ' .. e.task.label)
		end
		table.sort(out)
		return out
	end
]])

local function labels(bufnr, filetype)
	return C.eval(child, 'labels(...)', { bufnr, filetype })
end

T['global task shows in every buffer'] = function()
	child.lua([[f2.add_tasks({ { group = 'demo', label = 'top', action = 'gg' } })]])
	eq(labels(), { 'demo: top' })
	local other = C.eval(child, 'vim.api.nvim_create_buf(true, false)')
	eq(labels(other), { 'demo: top' })
end

T['buffer task shows only in its buffer'] = function()
	child.lua([[f2.add_tasks({ { group = 'demo', label = 'top', action = 'gg' } }, { buffer = 0 })]])
	eq(labels(), { 'demo: top' })
	local other = C.eval(child, 'vim.api.nvim_create_buf(true, false)')
	eq(labels(other), {})
end

T['buffer tasks are dropped on BufWipeout'] = function()
	local buf = C.eval(child, 'vim.api.nvim_create_buf(true, false)')
	child.lua([[f2.add_tasks({ { group = 'demo', label = 'top', action = 'gg' } }, { buffer = ... })]], { buf })
	eq(labels(buf), { 'demo: top' })
	child.lua('vim.api.nvim_buf_delete(..., { force = true })', { buf })
	eq(C.eval(child, 'vim.tbl_count(labels(...))', { buf }), 0)
end

T['same group and label updates, new labels join the group'] = function()
	child.lua([[
		f2.add_tasks({ { group = 'demo', label = 'a', action = 'gg' } })
		f2.add_tasks({ { group = 'demo', label = 'a', action = 'G' }, { group = 'demo', label = 'b', action = 'G' } })
	]])
	eq(labels(), { 'demo: a', 'demo: b' })
	local action = child.lua([[
		for _, e in ipairs(registry.list({ dir = '.', bufnr = 0, filetype = '' })) do
			if e.task.label == 'a' then return e.task.action end
		end
	]])
	eq(action, 'G')
end

T['remove_tasks: one label, then the whole group'] = function()
	child.lua([[f2.add_tasks({
		{ group = 'demo', label = 'a', action = 'gg' },
		{ group = 'demo', label = 'b', action = 'gg' },
		{ group = 'keep', label = 'c', action = 'gg' },
	})]])
	child.lua([[f2.remove_tasks({ group = 'demo', label = 'a' })]])
	eq(labels(), { 'demo: b', 'keep: c' })
	child.lua([[f2.remove_tasks({ group = 'demo' })]])
	eq(labels(), { 'keep: c' })
end

T['remove_tasks without buffer leaves buffer tasks alone'] = function()
	child.lua([[
		f2.add_tasks({ { group = 'demo', label = 'global', action = 'gg' } })
		f2.add_tasks({ { group = 'demo', label = 'local', action = 'gg' } }, { buffer = 0 })
		f2.remove_tasks({ group = 'demo' })
	]])
	eq(labels(), { 'demo: local' })
	child.lua([[f2.remove_tasks({ group = 'demo', buffer = 0 })]])
	eq(labels(), {})
end

T['cond decides per <F2>'] = function()
	child.lua([[f2.add_tasks({ { group = 'demo', label = 'lua only', action = 'gg',
		cond = function(ctx) return ctx.filetype == 'lua' end } })]])
	eq(labels(nil, 'lua'), { 'demo: lua only' })
	eq(labels(nil, 'vim'), {})
end

T['cond error hides the task and notifies'] = function()
	child.lua([[f2.add_tasks({ { group = 'demo', label = 'broken', action = 'gg',
		cond = function() error('boom') end } })]])
	eq(labels(), {})
	eq(C.eval(child, '#notes'), 1)
	MiniTest.expect.no_equality(C.eval(child, 'notes[1]:find("boom")'), nil)
end

T['invalid tasks are skipped with a notification'] = function()
	child.lua([[f2.add_tasks({
		{ group = 'demo', action = 'gg' },                           -- no label
		{ group = 'demo', label = 'both', action = 'gg', cmd = 'x' }, -- action and cmd
		{ group = 'demo', label = 'none' },                          -- neither
		{ group = 'demo', label = 'ok', action = 'gg' },
	})]])
	eq(labels(), { 'demo: ok' })
	eq(C.eval(child, '#notes'), 3)
end

T['builder'] = MiniTest.new_set()

T['builder']['registers nothing before :add()'] = function()
	child.lua([[_G.b = f2.add_task('demo', 'top'):keys('gg')]])
	eq(labels(), {})
	child.lua('b:add()')
	eq(labels(), { 'demo: top' })
end

T['builder']['sets every field'] = function()
	local cond = child.lua([[
		local cond = function() return true end
		f2.add_task('demo', 'full'):cmd({ 'go', 'test' }):floaterm():cwd('/tmp'):order(3)
			:cond(cond):autoremove(2):merge('k'):add()
		local t = registry.list({ dir = '.', bufnr = 0, filetype = '' })[1].task
		return { t.group, t.label, t.cmd, t.runner, t.cwd, t.order, t.autoremove, t.merge, t.cond == cond }
	]])
	eq(cond, { 'demo', 'full', { 'go', 'test' }, 'floaterm', '/tmp', 3, 2, 'k', true })
end

T['builder'][':autoremove() without a code means true'] = function()
	local v = child.lua([[
		f2.add_task('demo', 'once'):keys('gg'):autoremove():add()
		return registry.list({ dir = '.', bufnr = 0, filetype = '' })[1].task.autoremove
	]])
	eq(v, true)
end

T['builder'][':buffer(0) scopes to the current buffer'] = function()
	child.lua([[f2.add_task('demo', 'top'):keys('gg'):buffer(0):add()]])
	local other = C.eval(child, 'vim.api.nvim_create_buf(true, false)')
	eq(labels(), { 'demo: top' })
	eq(labels(other), {})
end

return T
