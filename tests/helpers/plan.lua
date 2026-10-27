-- `make plan` in tests/: which cases `make test` would run with the same D= and G=, which would
-- skip and why, and which the group leaves out for being slow. Runs no tests; nvim with the real
-- config, so `requires` (S:case meta, tests/helpers/timing.lua) is checked against it.
dofile('tests/helpers/real-config.lua').prepare()

-- mini.test and tests/helpers, as tests/minimal_init.lua sets them up for the runner
vim.opt.rtp:prepend(vim.fn.stdpath('data') .. '/lazy/mini.test')
package.path = vim.fn.getcwd() .. '/tests/?.lua;' .. package.path
require('mini.test').setup()
local H = require('helpers.timing')

local dir = vim.env.TEST_DIR
if dir == nil or dir == '' then
	dir = '*'
end
local cases = MiniTest.collect({
	find_files = function() return vim.fn.globpath('tests/' .. dir, 'test_*.lua', true, true) end,
})

---Why a case would skip, nil when it would run.
---@param req genja.tests.Requires|nil
---@return string|nil
local function skip_reason(req)
	if not req then
		return nil
	end
	if req.path and not vim.uv.fs_stat(req.path) then
		return req.path_fix or ('missing ' .. req.path)
	end
	if req.server and not vim.lsp.is_enabled(req.server) then
		return req.server .. ' not enabled'
	end
	if req.cmd and vim.fn.executable(req.cmd) == 0 then
		return req.cmd .. ' not installed'
	end
	return nil
end

local group = H.group()
local slow_out = group == '' or group == 'default' or group == 'fast'
local out = {}
local counts = { run = 0, skip = 0, slow = 0 }
-- estimates from the recorded averages; a case never timed (or not wrapped in S:case) is unknown
local ms = { run = 0, slow = 0, whole = 0 }
local unknown = { run = 0, slow = 0, whole = 0 }
for _, case in ipairs(cases) do
	-- plain cases get an id too, so their recorded times and slow flags count (as in make test)
	H.adopt(case)
	local meta = H.meta(case) --[[@as genja.tests.Meta]]
	local file_dir = vim.fs.basename(vim.fs.dirname(vim.fs.normalize(case.desc[1])))
	local name = table.concat(vim.list_slice(case.desc, 2), ' | ')
	local state = nil
	local reason = ''
	local why = skip_reason(meta and meta.requires)

	-- whole run (every case of D=, any group): the average capped at today's timeout; never timed:
	-- the full timeout for S:case() cases, unknown for plain ones (the default timeout would be a
	-- wild guess for a 50 ms unit test); a skip costs nothing
	if not why then
		local timeout = meta.timeout or H.TIMEOUT
		local avg = H.average(meta)
		if avg then
			ms.whole = ms.whole + math.min(avg, timeout)
		elseif meta.adopted then
			unknown.whole = unknown.whole + 1
		else
			ms.whole = ms.whole + timeout
		end
	end

	if H.keep(case) then
		state = (why and 'skip' or 'run')
		reason = why or ''
	elseif meta and slow_out and H.is_slow(meta) then
		-- other cases outside the group are not listed: G= asked for them to be left out
		state = 'slow'
		reason = 'found slow; G=gather runs it'
	end
	if state then
		counts[state] = counts[state] + 1
		table.insert(out, ('%-18s %-5s %-32s %s'):format(file_dir, state, name, reason))
	end
	-- a skip takes no time worth counting
	if state == 'run' or state == 'slow' then
		local avg = meta and H.average(meta)
		if avg then
			ms[state] = ms[state] + avg
		else
			unknown[state] = unknown[state] + 1
		end
	end
end

---@param total number ms
---@param n_unknown integer
---@return string
local function estimate(total, n_unknown)
	local s = math.floor(total / 1000 + 0.5)
	local text = ('~%d s'):format(s)
	if s >= 60 then
		text = ('~%d min %02d s'):format(math.floor(s / 60), s % 60)
	end
	if n_unknown > 0 then
		text = text .. (', plus %d not timed yet'):format(n_unknown)
	end
	return text
end

local shown_group = (group == '' and 'default' or group)
local shown_dir = (dir == '*' and 'all dirs' or dir)
table.insert(out, 1, ('%s, group %s'):format(shown_dir, shown_group))
table.insert(out, ('%d run, %d skip, %d left out as slow'):format(counts.run, counts.skip, counts.slow))
table.insert(out, 'time to run: ' .. estimate(ms.run, unknown.run))
if counts.slow > 0 then
	table.insert(out, 'time for the slow ones left out: ' .. estimate(ms.slow, unknown.slow))
end
table.insert(out, 'time for every test of any group: ' .. estimate(ms.whole, unknown.whole))
io.stdout:write(table.concat(out, '\n') .. '\n')
