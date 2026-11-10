-- f2.open(): every source is asked, the picker opens once with all their items.

local C = require('helpers.child')
local eq = MiniTest.expect.equality

local child, T = C.fresh(C.NOTES .. [[
	-- every source answers nothing, unless a case replaces it; set before genja.f2 loads them
	local names = { 'adhoc', 'git', 'make', 'scripts', 'claude', 'gui', 'diag', 'messages', 'lang', 'lookup', 'view' }
	for _, name in ipairs(names) do
		package.loaded['genja.f2.collect.' .. name] = { collect = function(_, done) done({}) end }
	end
	_G.opened = {}
	package.loaded['genja.f2.picker'] = {
		GROUP_WIDTH = 14,
		entries = function(entries) table.insert(opened, #entries) end,
	}
	_G.source = function(name, collect)
		package.loaded['genja.f2.collect.' .. name] = { collect = collect }
	end
]])

local function open_and_wait()
	child.lua([[require('genja.f2').open()]])
	child.lua([[vim.wait(200, function() return false end)]])
	return C.eval(child, 'opened')
end

T['opens once with the items of every source'] = function()
	child.lua([[
		source('adhoc', function(_, done) done({ { group = 'adhoc', label = 'a' } }) end)
		source('git', function(_, done) vim.defer_fn(function() done({ { group = 'git', label = 'g' } }) end, 50) end)
	]])
	eq(open_and_wait(), { 2 })
end

T['a source that answers and then fails counts once'] = function()
	child.lua([[
		source('adhoc', function(_, done)
			done({ { group = 'adhoc', label = 'a' } })
			error('after the answer')
		end)
		source('git', function(_, done) vim.defer_fn(function() done({ { group = 'git', label = 'g' } }) end, 50) end)
	]])
	eq(open_and_wait(), { 2 })
end

T['nothing anywhere: no picker, a warning'] = function()
	eq(open_and_wait(), {})
	eq(C.eval(child, [[notes[#notes]:find('no context here', 1, true) ~= nil]]), true)
end

return T
