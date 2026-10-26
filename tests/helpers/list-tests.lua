-- `make list` in tests/: test dirs (D=) and the groups their cases carry (G=), with case counts.
-- `make list-sh` (env LIST_MODE=sh): the same as runnable `make test D=… G=…` lines, one G= each.
-- Collects the cases without running them; groups come from S:case() (tests/helpers/timing.lua).
local H = require('helpers.timing')

local cases = MiniTest.collect({
	find_files = function() return vim.fn.globpath('tests/*', 'test_*.lua', true, true) end,
})

---@type table<string, { n: integer, groups: table<string, integer> }>
local dirs = {}
for _, case in ipairs(cases) do
	local dir = vim.fs.basename(vim.fs.dirname(vim.fs.normalize(case.desc[1])))
	local d = dirs[dir]
	if not d then
		d = { n = 0, groups = {} }
		dirs[dir] = d
	end
	d.n = d.n + 1
	local meta = H.meta(case)
	if meta then
		for _, g in ipairs(meta.groups or {}) do
			d.groups[g] = (d.groups[g] or 0) + 1
		end
	end
end

local names = vim.tbl_keys(dirs)
table.sort(names)

-- groups every timing-aware dir accepts, besides its own (helpers.timing.keep)
local BUILTIN = { 'default', 'fast', 'slow', 'gather' }

local out = {}

-- `make list-sh` (LIST_MODE=sh): one runnable command per D= and single G= pair
if vim.env.LIST_MODE == 'sh' then
	for _, dir in ipairs(names) do
		local d = dirs[dir]
		table.insert(out, 'make test D=' .. dir)
		local groups = vim.tbl_keys(d.groups)
		table.sort(groups)
		-- dirs without S:case() run every case in any group: no G= worth listing
		if #groups > 0 then
			for _, g in ipairs(BUILTIN) do
				table.insert(out, 'make test D=' .. dir .. ' G=' .. g)
			end
			for _, g in ipairs(groups) do
				table.insert(out, 'make test D=' .. dir .. ' G=' .. g)
			end
		end
	end
	io.stdout:write(table.concat(out, '\n') .. '\n')
	return
end

table.insert(out, 'dirs (D=), groups (G=) with case counts')
table.insert(out, 'G= for every dir: ' .. table.concat(BUILTIN, ' '))
for _, dir in ipairs(names) do
	local d = dirs[dir]
	table.insert(out, ('%-18s %3d cases'):format(dir, d.n))
	local groups = vim.tbl_keys(d.groups)
	table.sort(groups)
	for _, g in ipairs(groups) do
		table.insert(out, ('    G=%-24s %3d'):format(g, d.groups[g]))
	end
end
io.stdout:write(table.concat(out, '\n') .. '\n')
