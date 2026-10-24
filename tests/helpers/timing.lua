-- Groups, timeouts and slowness for mini.test suites. require('helpers.timing') (tests/ is on
-- package.path, see tests/minimal_init.lua).
--
--   local H = require('helpers.timing')
--   local S = H.suite('comps011')
--   T['lua_ls attaches'] = S:case({ groups = { 'lsp' }, timeout = 15000, slow = 8000 }, function(c)
--   	-- c.timeout: this case's timeout in ms, for wait loops
--   end)
--
-- Group (env TEST_GROUP, `make dir D=comps011 G=lsp`):
--   (unset), default   every case except those found slow
--   lsp, cmp, lint ... cases with that group (slow ones included)
--   fast               only cases not found slow
--   slow               only cases found slow
--   gather             every case, slow or not: refreshes the timings
--   all                every case
-- Cases without S:case() always run.
--
-- Four separate settings: timeout (default 12 s, per case `timeout`) ends a case's waits;
-- slow cutoff (default 3 s, per case `slow`) decides what counts as slow. A case is slow when
-- its average time over all recorded runs is above its cutoff, so fast runs later unflag it.
-- Timings: stdpath('state')/genja-tests/timings.json, throw-away; delete it to start over.
-- A timed-out case counts with its timeout as its time.

local M = {}

M.TIMEOUT = 12000
M.SLOW = 3000

local FILE = vim.fs.joinpath(vim.fn.stdpath('state'), 'genja-tests', 'timings.json')

---@class genja.tests.Meta
---@field groups? string[]
---@field timeout? integer ms, default M.TIMEOUT
---@field slow? integer ms, default M.SLOW
---@field id string suite/case, set by S:case()

---@type table<function, genja.tests.Meta>
local registry = {}

---@type table<string, { n: integer, avg: number, last: number }>|nil
local timings = nil

---@return table<string, { n: integer, avg: number, last: number }>
local function load()
	if timings then
		return timings
	end
	timings = {}
	if vim.fn.filereadable(FILE) == 1 then
		local ok, data = pcall(vim.json.decode, table.concat(vim.fn.readfile(FILE), '\n'))
		if ok and type(data) == 'table' then
			timings = data
		end
	end
	return timings
end

---Write the timings (after a suite; each suite calls it from its post_once).
function M.save()
	if not timings then
		return
	end
	vim.fn.mkdir(vim.fs.dirname(FILE), 'p')
	vim.fn.writefile({ vim.json.encode(timings) }, FILE)
end

---Add one run's time for `id` to its running average.
---@param id string
---@param ms number
function M.record(id, ms)
	local all = load()
	local t = all[id] or { n = 0, avg = 0, last = 0 }
	t.avg = (t.avg * t.n + ms) / (t.n + 1)
	t.n = t.n + 1
	t.last = ms
	all[id] = t
end

---Is the case slow by its recorded average?
---@param meta genja.tests.Meta
---@return boolean
function M.is_slow(meta)
	local t = load()[meta.id]
	if not t then
		return false -- never run: not known to be slow
	end
	return t.avg > (meta.slow or M.SLOW)
end

---The group asked for: env TEST_GROUP, '' for the default.
---@return string
function M.group()
	return vim.env.TEST_GROUP or ''
end

---Should this case run in the asked group? For collect.filter_cases.
---@param case table mini.test case (case.test is the function S:case() returned)
---@return boolean
function M.keep(case)
	local meta = registry[case.test]
	if not meta then
		return true
	end
	local group = M.group()
	if group == 'all' or group == 'gather' then
		return true
	end
	if group == '' or group == 'default' or group == 'fast' then
		return not M.is_slow(meta)
	end
	if group == 'slow' then
		return M.is_slow(meta)
	end
	return vim.tbl_contains(meta.groups or {}, group)
end

---@class genja.tests.Suite
---@field name string
local Suite = {}
Suite.__index = Suite

---@param name string prefix for the timing ids
---@return genja.tests.Suite
function M.suite(name)
	return setmetatable({ name = name }, Suite)
end

---Wrap a case: registers its groups and times it. `fn` gets { timeout = ms }.
---@param meta { groups?: string[], timeout?: integer, slow?: integer, name: string }
---@param fn fun(c: { timeout: integer })
---@return function
function Suite:case(meta, fn)
	local full = vim.tbl_extend('force', {}, meta)
	full.id = self.name .. '/' .. meta.name
	local timeout = full.timeout or M.TIMEOUT
	local function run()
		-- a skip (missing server) says nothing about speed; MiniTest.skip throws a plain string
		local skipped = false
		local skip = MiniTest.skip
		MiniTest.skip = function(msg)
			skipped = true
			return skip(msg)
		end
		local t0 = vim.uv.hrtime()
		local ok, err = pcall(fn, { timeout = timeout })
		local ms = (vim.uv.hrtime() - t0) / 1e6
		MiniTest.skip = skip
		if not skipped then
			M.record(full.id, math.min(ms, timeout))
		end
		if not ok then
			error(err, 0)
		end
	end
	registry[run] = full
	return run
end

---Poll `check` until it returns a truthy value or `timeout` ms pass.
---@param check fun(): any
---@param timeout integer
---@param step? integer ms between polls, default 100
---@return any last value
function M.wait(check, timeout, step)
	local stop = vim.uv.hrtime() + timeout * 1e6
	local got = check()
	while not got and vim.uv.hrtime() < stop do
		vim.uv.sleep(step or 100)
		got = check()
	end
	return got
end

M.FILE = FILE

return M
