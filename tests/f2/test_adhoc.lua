-- f2 adhoc.lua: when `go mod init` is offered. Uses temp dirs; needs `go`
-- on PATH (cases skip without it). Fresh child nvim per case.

local C = require('helpers.child')
local eq = MiniTest.expect.equality

local function needs_go(case)
	return C.needs('go', case)
end

local child, T = C.fresh([[
	_G.adhoc = require('genja.f2.collect.adhoc')
	_G.dir = vim.fs.normalize(vim.fn.tempname()) .. '/f2go'
	vim.fn.mkdir(dir, 'p')
	-- labels adhoc offers for ctx; collect calls done synchronously
	_G.labels = function(filetype)
		local out
		adhoc.collect({ dir = dir, bufnr = 0, filetype = filetype }, function(tasks)
			out = {}
			for _, t in ipairs(tasks) do
				table.insert(out, t.group .. ': ' .. t.label)
			end
		end)
		return out
	end
]])

T['offered for a go buffer without go.mod'] = needs_go(function()
	local got = C.eval(child, [[labels('go')]])
	eq(#got, 1)
	eq(got[1], 'adhoc: go mod init f2go')
end)

T['not offered when go.mod exists'] = needs_go(function()
	child.lua([[vim.fn.writefile({ 'module f2go' }, dir .. '/go.mod')]])
	eq(C.eval(child, [[labels('go')]]), {})
end)

T['not offered when go.work exists above'] = needs_go(function()
	child.lua([[
		local sub = dir .. '/sub'
		vim.fn.mkdir(sub, 'p')
		vim.fn.writefile({ 'go 1.23' }, dir .. '/go.work')
		_G.dir = sub
	]])
	eq(C.eval(child, [[labels('go')]]), {})
end)

T['not offered for other filetypes'] = needs_go(function()
	eq(C.eval(child, [[labels('lua')]]), {})
end)

T['oil: offered only when the dir has .go files'] = needs_go(function()
	eq(C.eval(child, [[labels('oil')]]), {})
	child.lua([[vim.fn.writefile({ 'package main' }, dir .. '/main.go')]])
	eq(#C.eval(child, [[labels('oil')]]), 1)
end)

T['not offered with GO111MODULE=off'] = needs_go(function()
	child.lua([[vim.env.GO111MODULE = 'off']])
	eq(C.eval(child, [[labels('go')]]), {})
end)

return T
