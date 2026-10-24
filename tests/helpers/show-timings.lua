-- `make timings` in tests/: recorded case times, slowest first (tests/helpers/timing.lua).
local file = vim.fs.joinpath(vim.fn.stdpath('state'), 'genja-tests', 'timings.json')
if vim.fn.filereadable(file) == 0 then
	print('no timings yet: ' .. file)
	return
end
local data = vim.json.decode(table.concat(vim.fn.readfile(file), '\n'))
local rows = {}
for id, t in pairs(data) do
	table.insert(rows, { id = id, avg = t.avg, last = t.last, n = t.n })
end
table.sort(rows, function(a, b) return a.avg > b.avg end)
print(('%8s %8s %4s  %s'):format('avg ms', 'last ms', 'runs', 'case'))
for _, r in ipairs(rows) do
	print(('%8d %8d %4d  %s'):format(r.avg, r.last, r.n, r.id))
end
print(file)
