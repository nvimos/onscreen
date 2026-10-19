-- f2 git.lua: parsing `git status --porcelain=v1 -z`.
-- Pure function; runs in the test process.

local eq = MiniTest.expect.equality
local git = require('genja.f2.git')

local function z(...)
	return table.concat({ ... }, '\0') .. '\0'
end

local function parsed(stdout)
	local out = {}
	for _, f in ipairs(git._parse_status(stdout)) do
		table.insert(out, f.xy .. '|' .. f.path)
	end
	return out
end

local T = MiniTest.new_set()

T['keeps unstaged and untracked, sorted by path'] = function()
	eq(parsed(z(' M lua/b.lua', '?? a.txt', ' D gone.lua')), { '??|a.txt', ' D|gone.lua', ' M|lua/b.lua' })
end

T['drops staged-only files'] = function()
	eq(parsed(z('M  staged.lua', 'A  new.lua', ' M work.lua')), { ' M|work.lua' })
end

T['keeps staged files with more unstaged changes'] = function()
	eq(parsed(z('MM both.lua')), { 'MM|both.lua' })
end

T['renames: skips the original path'] = function()
	eq(parsed(z('RM new.lua', 'old.lua', '?? x.txt')), { 'RM|new.lua', '??|x.txt' })
	eq(parsed(z('R  moved.lua', 'orig.lua')), {}) -- staged-only rename
end

T['paths with spaces'] = function()
	eq(parsed(z('?? my file.txt')), { '??|my file.txt' })
end

T['empty output'] = function()
	eq(parsed(''), {})
end

return T
