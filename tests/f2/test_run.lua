-- f2 run.lua: keys / function / cmd, autoremove, merge. overseer, floaterm
-- and nvim_feedkeys are stubbed in the child; nothing is really run.

local child = MiniTest.new_child_neovim()
local eq = MiniTest.expect.equality

local T = MiniTest.new_set({
	hooks = {
		pre_case = function()
			child.restart({ '-u', 'tests/minimal_init.lua' })
			child.lua([[
				_G.notes = {}
				vim.notify = function(msg) table.insert(_G.notes, msg) end
				_G.run = require('genja.f2.run')
				_G.calls = {}
				run.overseer = function(name, cmd, cwd, on_exit)
					table.insert(calls, { runner = 'overseer', name = name, cmd = cmd, cwd = cwd, on_exit = on_exit })
				end
				run.floaterm = function(cmd, cwd, on_exit)
					table.insert(calls, { runner = 'floaterm', cmd = cmd, cwd = cwd, on_exit = on_exit })
				end
				_G.removed = 0
				_G.remove = function() removed = removed + 1 end
				_G.ctx = { dir = 'C:/work', bufnr = 0, filetype = '' }
			]])
		end,
		post_once = child.stop,
	},
})

T['keys'] = MiniTest.new_set()

T['keys']['are fed with mappings, after a schedule'] = function()
	local fed = child.lua([[
		_G.fed = nil
		vim.api.nvim_feedkeys = function(keys, mode) _G.fed = { keys, mode } end
		run.task({ group = 'g', label = 'l', action = '<Cmd>echo<CR>' }, ctx, remove)
		vim.wait(500, function() return _G.fed ~= nil end)
		return _G.fed
	]])
	eq(fed, { child.lua([[return vim.keycode('<Cmd>echo<CR>')]]), 'm' })
	eq(child.lua('return removed'), 0)
end

T['keys']['with autoremove are removed after feeding'] = function()
	child.lua([[
		vim.api.nvim_feedkeys = function() end
		run.task({ group = 'g', label = 'l', action = 'gg', autoremove = true }, ctx, remove)
	]])
	eq(child.lua('return removed'), 1)
end

T['function'] = MiniTest.new_set()

T['function']['gets ctx'] = function()
	local dir = child.lua([[
		local got
		run.task({ group = 'g', label = 'l', action = function(c) got = c.dir end }, ctx, remove)
		return got
	]])
	eq(dir, 'C:/work')
end

T['function']['returning true with autoremove is removed'] = function()
	child.lua([[run.task({ group = 'g', label = 'l', autoremove = true, action = function() return true end }, ctx, remove)]])
	eq(child.lua('return removed'), 1)
end

T['function']['returning false with autoremove stays'] = function()
	child.lua([[run.task({ group = 'g', label = 'l', autoremove = true, action = function() return false end }, ctx, remove)]])
	eq(child.lua('return removed'), 0)
end

T['function']['returning true without autoremove stays'] = function()
	child.lua([[run.task({ group = 'g', label = 'l', action = function() return true end }, ctx, remove)]])
	eq(child.lua('return removed'), 0)
end

T['function']['error notifies and stays'] = function()
	child.lua([[run.task({ group = 'g', label = 'l', autoremove = true, action = function() error('boom') end }, ctx, remove)]])
	eq(child.lua('return removed'), 0)
	eq(child.lua('return #notes'), 1)
end

T['cmd'] = MiniTest.new_set()

T['cmd']['runs in overseer with a plain name and ctx.dir as cwd'] = function()
	local call = child.lua([[
		run.task({ group = 'g', label = 'l', cmd = { 'git', 'add', '--', 'a b.txt' } }, ctx, remove)
		local c = calls[1]
		return { #calls, c.runner, c.name, c.cwd, c.on_exit == nil }
	]])
	eq(call, { 1, 'overseer', 'git add -- a b.txt', 'C:/work', true })
end

T['cmd']['cwd overrides ctx.dir'] = function()
	eq(child.lua([[
		run.task({ group = 'g', label = 'l', cmd = 'make', cwd = 'D:/x' }, ctx, remove)
		return calls[1].cwd
	]]), 'D:/x')
end

T['cmd']['runner floaterm'] = function()
	eq(child.lua([[
		run.task({ group = 'g', label = 'l', cmd = 'go test', runner = 'floaterm' }, ctx, remove)
		return calls[1].runner
	]]), 'floaterm')
end

T['cmd']['autoremove = true removes on exit 0 only'] = function()
	child.lua([[run.task({ group = 'g', label = 'l', cmd = 'x', autoremove = true }, ctx, remove)]])
	child.lua('calls[1].on_exit(1)')
	eq(child.lua('return removed'), 0)
	child.lua('calls[1].on_exit(0)')
	eq(child.lua('return removed'), 1)
end

T['cmd']['autoremove = 2 removes on exit 2 only'] = function()
	child.lua([[run.task({ group = 'g', label = 'l', cmd = 'x', autoremove = 2 }, ctx, remove)]])
	child.lua('calls[1].on_exit(0)')
	eq(child.lua('return removed'), 0)
	child.lua('calls[1].on_exit(2)')
	eq(child.lua('return removed'), 1)
end

T['entries'] = MiniTest.new_set()

T['entries']['run in the given order'] = function()
	local names = child.lua([[
		run.entries({
			{ task = { group = 'g', label = '1', cmd = { 'b' } }, remove = remove },
			{ task = { group = 'g', label = '2', cmd = { 'a' } }, remove = remove },
		}, ctx)
		return { calls[1].name, calls[2].name }
	]])
	eq(names, { 'b', 'a' })
end

T['entries']['same merge key and cwd run as one cmd'] = function()
	local r = child.lua([[
		local t1 = { group = 'git', label = 'a', cmd = { 'git', 'add', '--', 'a' }, merge = 'git add' }
		local t2 = { group = 'git', label = 'b', cmd = { 'git', 'add', '--', 'b' }, merge = 'git add' }
		run.entries({ { task = t1, remove = remove }, { task = t2, remove = remove } }, ctx)
		return { #calls, calls[1].cmd, t1.cmd }
	]])
	eq(r, { 1, { 'git', 'add', '--', 'a', 'b' }, { 'git', 'add', '--', 'a' } }) -- t1 left as is
end

T['entries']['merged autoremove removes every merged task'] = function()
	child.lua([[
		local t1 = { group = 'git', label = 'a', cmd = { 'x', 'a' }, merge = 'k', autoremove = true }
		local t2 = { group = 'git', label = 'b', cmd = { 'x', 'b' }, merge = 'k' }
		run.entries({ { task = t1, remove = remove }, { task = t2, remove = remove } }, ctx)
		calls[1].on_exit(0)
	]])
	eq(child.lua('return removed'), 2)
end

T['entries']['different cwd is not merged'] = function()
	eq(child.lua([[
		local t1 = { group = 'git', label = 'a', cmd = { 'x', 'a' }, merge = 'k', cwd = 'C:/one' }
		local t2 = { group = 'git', label = 'b', cmd = { 'x', 'b' }, merge = 'k', cwd = 'C:/two' }
		run.entries({ { task = t1, remove = remove }, { task = t2, remove = remove } }, ctx)
		return #calls
	]]), 2)
end

return T
