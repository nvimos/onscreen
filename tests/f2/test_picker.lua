-- f2 picker.lua: what the list shows for a label (picker.clean).

local eq = MiniTest.expect.equality
local clean = require('genja.f2.picker').clean

local T = MiniTest.new_set()

T['lower case, single spaces'] = function()
	eq(clean('Funcs:  Frame,  Full'), 'funcs: frame, full')
end

T['drops guillemets, quotes, backticks, brackets and !'] = function()
	eq(clean('claude-ft «Fix the Tabline»'), 'claude-ft fix the tabline')
	eq(clean([[it's "done" `now`!]]), 'its done now')
	eq(clean('checklist [ ] toggle'), 'checklist toggle')
end

T['keeps colons and parens'] = function()
	eq(clean('git: add (3 files)'), 'git: add (3 files)')
end

return T
