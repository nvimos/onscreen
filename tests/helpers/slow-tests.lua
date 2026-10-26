-- `make slow` in tests/: the cases found slow (left out of the default run), slowest first, with
-- their recorded average and cutoff (tests/helpers/timing.lua). Takes D=; runs no tests.
local H = require('helpers.timing')

local dir = vim.env.TEST_DIR
if dir == nil or dir == '' then
	dir = '*'
end
local cases = MiniTest.collect({
	find_files = function() return vim.fn.globpath('tests/' .. dir, 'test_*.lua', true, true) end,
})

---@param ms number
---@return string
local function seconds(ms)
	return ('%.1f s'):format(ms / 1000)
end

local rows = {}
for _, case in ipairs(cases) do
	H.adopt(case)
	local meta = H.meta(case) --[[@as genja.tests.Meta]]
	if H.is_slow(meta) then
		table.insert(rows, {
			name = table.concat(vim.list_slice(case.desc, 2), ' | '),
			dir = vim.fs.basename(vim.fs.dirname(vim.fs.normalize(case.desc[1]))),
			avg = H.average(meta) or 0,
			cutoff = meta.slow or H.SLOW,
		})
	end
end
table.sort(rows, function(a, b) return a.avg > b.avg end)

local out = {}
if #rows == 0 then
	table.insert(out, 'no case found slow')
else
	local total = 0
	-- name first, then the fixed-width columns
	table.insert(out, ('%-34s %8s %8s  %s'):format('case', 'average', 'cutoff', 'dir'))
	for _, r in ipairs(rows) do
		total = total + r.avg
		table.insert(out, ('%-34s %8s %8s  %s'):format(r.name, seconds(r.avg), seconds(r.cutoff), r.dir))
	end
	table.insert(out, ('%d slow, ~%d s together; make gather runs them'):format(#rows, math.floor(total / 1000 + 0.5)))
end
io.stdout:write(table.concat(out, '\n') .. '\n')
