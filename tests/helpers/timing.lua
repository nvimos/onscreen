-- Groups, timeouts and slowness for mini.test suites. require('helpers.timing') (tests/ is on
-- package.path, see tests/minimal_init.lua).
--
--   local H = require('helpers.timing')
--   local S = H.suite('comps011')
--   T['lua_ls attaches'] = S:case({ groups = { 'lsp' }, timeout = 15000, slow = 8000 }, function(c)
--   	-- c.timeout: this case's timeout in ms, for wait loops
--   end)
--
-- Group (env TEST_GROUP, `make test D=comps011 G=lsp`):
--   (unset), default   every case except those found slow
--   mason, lsp, ready, cmp, lint ... cases with that group (slow ones included)
--   fast               only cases not found slow
--   slow               only cases found slow
--   gather             every case, slow or not (its times get recorded, as on every run)
-- Cases without S:case() are timed by adopt() (run-tests.lua, plan.lua) under `<dir>/<case name>`
-- with the default timeout and cutoff; they have no groups, so they run in every named group.
--
-- Four separate settings: timeout (default 12 s, per case `timeout`) ends a case's waits;
-- slow cutoff (default 3 s, per case `slow`) decides what counts as slow. A case is slow when
-- its average is above its cutoff. The average is weighted: each new run counts M.WEIGHT (30%),
-- so a case that got faster drops off the slow list after a few runs. A case left out as slow
-- only gets new times from `make gather`, G=slow or a named group.
-- Timings: stdpath('state')/genja-tests/timings.json, throw-away; delete it to start over.
-- A timed-out case counts with its timeout as its time.

local M = {}

M.TIMEOUT = 12000
M.SLOW = 3000
-- share of the newest run in a case's average
M.WEIGHT = 0.3

local FILE = vim.fs.joinpath(vim.fn.stdpath('state'), 'genja-tests', 'timings.json')

---@class genja.tests.Requires
---@field server? string lspconfig name that must be enabled
---@field cmd? string executable that must be on PATH
---@field path? string file or folder that must exist
---@field path_fix? string shown instead of the path when it is missing, e.g. "run :ValeSync"

---@class genja.tests.Meta
---@field groups? string[]
---@field timeout? integer ms, default M.TIMEOUT
---@field slow? integer ms, default M.SLOW
---@field requires? genja.tests.Requires what the case skips without; read by `make plan`, the case still checks itself
---@field id string suite/case, set by S:case() or adopt()
---@field adopted? boolean a plain case timed by adopt(): no groups, timeout or cutoff of its own

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
	-- weighted: a case that got faster (or slower) shows it after a few runs, not dozens
	if t.n == 0 then
		t.avg = ms
	else
		t.avg = (1 - M.WEIGHT) * t.avg + M.WEIGHT * ms
	end
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

---Recorded average time of a case in ms; nil when it never ran. For `make plan`.
---@param meta genja.tests.Meta
---@return number|nil
function M.average(meta)
	local t = load()[meta.id]
	if not t then
		return nil
	end
	return t.avg
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
	if group == 'gather' then
		return true
	end
	if group == '' or group == 'default' or group == 'fast' then
		return not M.is_slow(meta)
	end
	if group == 'slow' then
		return M.is_slow(meta)
	end
	-- adopted cases (no groups of their own) run in every named group, as before they were timed
	if not meta.groups or #meta.groups == 0 then
		return true
	end
	return vim.tbl_contains(meta.groups, group)
end

---Time the running case under `id`, from now until it ends (failure included). Call first thing
---inside the case.
---@param id string
---@param timeout integer recorded time is capped at it
local function start_timer(id, timeout)
	-- a skip (missing server) says nothing about speed; MiniTest.skip throws a plain string
	local skipped = false
	local skip = MiniTest.skip
	MiniTest.skip = function(msg)
		skipped = true
		return skip(msg)
	end
	local t0 = vim.uv.hrtime()
	-- finally, not pcall: a failure keeps its own traceback (the test line, not this file)
	MiniTest.finally(function()
		local ms = (vim.uv.hrtime() - t0) / 1e6
		MiniTest.skip = skip
		if not skipped then
			M.record(id, math.min(ms, timeout))
		end
	end)
end

---Time a plain case (not made by S:case()): id `<dir>/<case name>`, default timeout and slow
---cutoff, no groups. Call on collected cases before filtering (run-tests.lua, plan.lua).
---@param case table mini.test case
function M.adopt(case)
	if registry[case.test] then
		return -- S:case() made it
	end
	local dir = vim.fs.basename(vim.fs.dirname(vim.fs.normalize(case.desc[1])))
	local full = { id = dir .. '/' .. table.concat(vim.list_slice(case.desc, 2), ' | '), groups = {}, adopted = true }
	local fn = case.test
	local function run(...)
		start_timer(full.id, M.TIMEOUT)
		return fn(...)
	end
	registry[run] = full
	case.test = run
end

---The meta S:case() registered for a case, nil for plain cases. For `make list`.
---@param case table mini.test case
---@return genja.tests.Meta|nil
function M.meta(case)
	return registry[case.test]
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
---@param meta { groups?: string[], timeout?: integer, slow?: integer, requires?: genja.tests.Requires, name: string }
---@param fn fun(c: { timeout: integer })
---@return function
function Suite:case(meta, fn)
	local full = vim.tbl_extend('force', {}, meta)
	full.id = self.name .. '/' .. meta.name
	local timeout = full.timeout or M.TIMEOUT
	local function run()
		start_timer(full.id, timeout)
		fn({ timeout = timeout })
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

-- {{{ last gather: when every case last ran

local GATHER_FILE = vim.fs.joinpath(vim.fn.stdpath('state'), 'genja-tests', 'last-gather')

---Record that a `make gather` run just finished.
function M.mark_gathered()
	vim.fn.mkdir(vim.fs.dirname(GATHER_FILE), 'p')
	vim.fn.writefile({ tostring(os.time()) }, GATHER_FILE)
end

---When `make gather` last finished, nil if never.
---@return integer|nil seconds since the epoch
function M.last_gathered()
	if vim.fn.filereadable(GATHER_FILE) == 0 then
		return nil
	end
	return tonumber(vim.fn.readfile(GATHER_FILE)[1])
end
-- }}}

-- {{{ failed cases: `make failed` reruns them

local FAILED_FILE = vim.fs.joinpath(vim.fn.stdpath('state'), 'genja-tests', 'failed.json')

---Ids of the cases that failed when they last ran.
---@return table<string, true>
function M.failed()
	if vim.fn.filereadable(FAILED_FILE) == 0 then
		return {}
	end
	local ok, data = pcall(vim.json.decode, table.concat(vim.fn.readfile(FAILED_FILE), '\n'))
	if not ok or type(data) ~= 'table' then
		return {}
	end
	local set = {}
	for _, id in ipairs(data) do
		set[id] = true
	end
	return set
end

---After a run: add the cases that failed, drop the ones that passed or skipped. Cases that did
---not run (other dirs, other groups) keep their last result.
---@param cases table[] mini.test cases of the run (MiniTest.current.all_cases)
function M.save_failed(cases)
	local set = M.failed()
	for _, case in ipairs(cases) do
		local meta = registry[case.test]
		local exec = case.exec
		if meta and type(exec) == 'table' and exec.fails then
			if #exec.fails > 0 then
				set[meta.id] = true
			else
				set[meta.id] = nil
			end
		end
	end
	local ids = vim.tbl_keys(set)
	table.sort(ids)
	vim.fn.mkdir(vim.fs.dirname(FAILED_FILE), 'p')
	vim.fn.writefile({ vim.json.encode(ids) }, FAILED_FILE)
end

---Is the env asking for the failed cases only (`make failed`)?
---@return boolean
function M.failed_only()
	return vim.env.TEST_FAILED ~= nil and vim.env.TEST_FAILED ~= ''
end
-- }}}

M.FILE = FILE

return M
