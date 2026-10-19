-- f2 adhoc.lua: when `go mod init` is offered. Uses temp dirs; needs `go`
-- on PATH (cases skip without it). Fresh child nvim per case.

local child = MiniTest.new_child_neovim()
local eq = MiniTest.expect.equality

-- MiniTest.skip() only ends the function it is called in, so check per case
local function needs_go(case)
	return function()
		if vim.fn.executable('go') == 0 then
			MiniTest.skip('go not on PATH')
		end
		case()
	end
end

local T = MiniTest.new_set({
	hooks = {
		pre_case = function()
			child.restart({ '-u', 'tests/minimal_init.lua' })
			child.lua([[
				_G.adhoc = require('genja.f2.adhoc')
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
		end,
		post_once = child.stop,
	},
})

T['offered for a go buffer without go.mod'] = needs_go(function()
	local got = child.lua([[return labels('go')]])
	eq(#got, 1)
	MiniTest.expect.no_equality(got[1]:find('^adhoc: go mod init f2go  %('), nil)
end)

T['not offered when go.mod exists'] = needs_go(function()
	child.lua([[vim.fn.writefile({ 'module f2go' }, dir .. '/go.mod')]])
	eq(child.lua([[return labels('go')]]), {})
end)

T['not offered when go.work exists above'] = needs_go(function()
	child.lua([[
		local sub = dir .. '/sub'
		vim.fn.mkdir(sub, 'p')
		vim.fn.writefile({ 'go 1.23' }, dir .. '/go.work')
		_G.dir = sub
	]])
	eq(child.lua([[return labels('go')]]), {})
end)

T['not offered for other filetypes'] = needs_go(function()
	eq(child.lua([[return labels('lua')]]), {})
end)

T['oil: offered only when the dir has .go files'] = needs_go(function()
	eq(child.lua([[return labels('oil')]]), {})
	child.lua([[vim.fn.writefile({ 'package main' }, dir .. '/main.go')]])
	eq(#child.lua([[return labels('oil')]]), 1)
end)

T['not offered with GO111MODULE=off'] = needs_go(function()
	child.lua([[vim.env.GO111MODULE = 'off']])
	eq(child.lua([[return labels('go')]]), {})
end)

return T
