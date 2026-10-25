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

T['display: group right-aligned to 6, two spaces, label'] = function()
	local display = require('genja.f2.picker').display
	eq(display('diag', 'Show all (2 hidden)'), '  diag  show all (2 hidden)')
	eq(display('claude', 'fix the tabline'), 'claude  fix the tabline')
	eq(display('md', 'glow preview'), '    md  glow preview')
end

T['display: a longer group is not cut'] = function()
	eq(require('genja.f2.picker').display('toolong', 'x'), 'toolong  x')
end

return T
