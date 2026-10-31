-- `make timings` in tests/: recorded case times, slowest last (tests/helpers/timing.lua).
-- Hides fast cases by average: V unset below 400 ms, V=1 below 50 ms, V=2 shows all.
local file = vim.fs.joinpath(vim.fn.stdpath('state'), 'genja-tests', 'timings.json')
if vim.fn.filereadable(file) == 0 then
	print('no timings yet: ' .. file)
	return
end

local MIN_MS = { [''] = 400, ['1'] = 50, ['2'] = 0 }
local verbose = os.getenv('TEST_VERBOSE') or ''
local min = MIN_MS[verbose] or 0

local data = vim.json.decode(table.concat(vim.fn.readfile(file), '\n'))
local rows = {}
local hidden = 0
for id, t in pairs(data) do
	if t.avg >= min then
		table.insert(rows, { id = id, avg = t.avg, last = t.last, n = t.n })
	else
		hidden = hidden + 1
	end
end
table.sort(rows, function(a, b) return a.avg < b.avg end)
for _, r in ipairs(rows) do
	print(('%8d %8d %4d  %s'):format(r.avg, r.last, r.n, r.id))
end
-- column names under the rows, next to the slowest ones
print(('%8s %8s %4s  %s'):format('avg-ms', 'last-ms', 'runs', 'case'))
if hidden > 0 then
	local more = 'V=2 shows all'
	if verbose == '' then
		more = 'V=1 shows down to 50 ms, V=2 all'
	end
	print(('%d cases under %d ms not shown; %s'):format(hidden, min, more))
end
print(file)
