-- <leader>tC colorcolumn toggle (lua/genja/ext/colorcolumn.lua) and its <F2> item (f2/collect/view.lua).

local C = require('helpers.child')
local eq = MiniTest.expect.equality

local child, T = C.fresh(C.NOTES .. [[
	_G.cc = require('genja.ext.colorcolumn')
	-- label of the <F2> view item
	_G.view_label = function()
		local label
		require('genja.f2.collect.view').collect({}, function(tasks) label = tasks[1].label end)
		return label
	end
]])

T['off remembers the columns, on brings them back'] = function()
	child.lua([[vim.wo.colorcolumn = '4,8,80']])
	child.lua([[cc.toggle()]])
	eq(child.wo.colorcolumn, '')
	child.lua([[cc.toggle()]])
	eq(child.wo.colorcolumn, '4,8,80')
end

T['on without earlier columns: 80'] = function()
	child.lua([[cc.toggle()]])
	eq(child.wo.colorcolumn, '80')
end

T['the F2 item says what it will do'] = function()
	eq(C.eval(child, 'view_label()'), 'colorcolumn on')
	child.lua([[vim.wo.colorcolumn = '80']])
	eq(C.eval(child, 'view_label()'), 'colorcolumn off (80)')
end

return T
