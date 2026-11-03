-- `make test` in tests/: runs tests/<dir>/test_*.lua, cases filtered by group (tests/helpers/timing.lua).
-- Dir, group and verbosity come as env TEST_DIR, TEST_GROUP, TEST_VERBOSE (make's D=, G=, V=), so
-- no Lua passes through the shell's quoting. Unset dir: every dir. TEST_FAILED: `make failed`.
local H = require('helpers.timing')

local dir = vim.env.TEST_DIR
if dir == nil or dir == '' then
	dir = '*'
end

-- verbose: one result row per case (file | case name) instead of one per file
local depth = 1
if vim.env.TEST_VERBOSE ~= nil and vim.env.TEST_VERBOSE ~= '' then
	depth = 2
end

-- `make failed` (env TEST_FAILED): only the cases that failed last time, whatever their group
local failed = nil
if H.failed_only() then
	failed = H.failed()
end

local group = H.group()
-- what the group left out for being slow, for the line after the summary
local left_out = { n = 0, ms = 0 }

---One line after mini.test's summary: what this run left out as slow, and how old the last full
---run is. Empty when nothing was left out.
---@return string
local function slow_line()
	if left_out.n == 0 then
		return ''
	end
	local s = math.floor(left_out.ms / 1000 + 0.5)
	local line = ('%d left out as slow (~%d s; make slow lists them)'):format(left_out.n, s)
	local last = H.last_gathered()
	if last then
		local days = math.floor((os.time() - last) / 86400)
		if days == 0 then
			line = line .. '; last gather today'
		else
			line = line .. ('; last gather %d days ago'):format(days)
		end
	else
		line = line .. '; never gathered (make gather)'
	end
	return line .. '\n'
end

-- when the run ends: write the times (plain cases have no post_once that would; comps011's does)
-- and which cases failed, for `make failed`; then mini.test's summary, the slow line, and quit
-- with mini.test's exit code (the reporter's own quit would come before the slow line)
local reporter = MiniTest.gen_reporter.stdout({ group_depth = depth, quit_on_finish = false })
local stdout_finish = reporter.finish

-- mini.test prints a passing case's note as bold green `NOTE in tests/<file> | <case>: <msg>`;
-- make it bold yellow `NOTE <file> <case>: <msg>`, shorter on the line.
-- Its reporter looks up io.stdout on each write, so a proxy for the summary is enough.
local GREEN_NOTE = '\27%[1;32mNOTE\27%[0m in tests/([^\n]-) | '
local YELLOW_NOTE = '\27[1;33mNOTE\27[0m %1 '
local function finish(...)
    local real = io.stdout
    io.stdout = {
        write = function(_, text)
            return real:write((text:gsub(GREEN_NOTE, YELLOW_NOTE)))
        end,
    }
    local ok, err = pcall(stdout_finish, ...)
    io.stdout = real
    if not ok then
        error(err)
    end
end

reporter.finish = function(...)
	local cases = MiniTest.current.all_cases or {}
	H.save()
	H.save_failed(cases)
	if group == 'gather' and dir == '*' and not failed then
		H.mark_gathered()
	end
	finish(...)
	io.stdout:write(slow_line())
	local code = 0
	for _, case in ipairs(cases) do
		if type(case.exec) == 'table' and #(case.exec.fails or {}) > 0 then
			code = 1
		end
	end
	vim.cmd(('silent! %dcquit'):format(code))
end

local slow_out = group == '' or group == 'default' or group == 'fast'

MiniTest.run({
	collect = {
		find_files = function() return vim.fn.globpath('tests/' .. dir, 'test_*.lua', true, true) end,
		-- time every case, not only those made by S:case(); then filter by group
		filter_cases = function(case)
			H.adopt(case)
			local meta = H.meta(case) --[[@as genja.tests.Meta]]
			if failed then
				return failed[meta.id] == true
			end
			local keep = H.keep(case)
			if not keep and slow_out then
				left_out.n = left_out.n + 1
				left_out.ms = left_out.ms + (H.average(meta) or 0)
			end
			return keep
		end,
	},
	execute = {
		reporter = reporter,
	},
})
