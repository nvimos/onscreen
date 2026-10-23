-- <F2> source, group `make`: one item, `targets (N)  (<folder>)`, opening a sub-picker
-- over the targets of the Makefile above ctx.dir (includes too). <Tab> marks;
-- each chosen target runs as an overseer task.

local picker = require('genja.f2.picker')

local M = {}

local SRC = 'lua/genja/f2/make.lua: '

local function find_makefile(dir)
	local names = { 'GNUmakefile', 'makefile', 'Makefile' }
	return vim.fs.find(names, { upward = true, type = 'file', path = dir })[1]
end

-- targets from `make -rRpq` (database dump, runs no recipe), like overseer's make
-- provider: the "# Files" section, minus dot/special entries, pattern rules,
-- "# Not a target" entries and the makefiles themselves.
-- Also returns MAKEFILE_LIST: the main makefile and its includes, in read order.
local function parse_targets(stdout)
	local seen = {}
	local targets = {}
	local makefiles = {}
	local in_files = false
	local prev = ''
	for line in vim.gsplit(stdout, '\n', { plain = true }) do
		line = line:gsub('\r$', '')
		local list = line:match('^MAKEFILE_LIST :?= (.*)$')
		if list then
			makefiles = vim.split(vim.trim(list), '%s+', { trimempty = true })
		elseif vim.startswith(line, '# Files') then
			in_files = true
		elseif vim.startswith(line, '# Finished Make') then
			break
		elseif in_files and line:match('^[^%.#%s]') and not vim.startswith(prev, '# Not a target') then
			local target = line:match('^([^:=]+):')
			local is_makefile = target and (target:match('[Mm]akefile') or target:match('%.mk$'))
			if target and not target:find('%', 1, true) and not is_makefile and not seen[target] then
				seen[target] = true
				table.insert(targets, target)
			end
		end
		prev = line
	end
	return targets, makefiles
end

-- picker prefix for a makefile: Makefile.lazy.mk -> 'lazy', tools.mk -> 'tools',
-- the main Makefile -> '' (no prefix)
local function makefile_prefix(path)
	local name = vim.fs.basename(path):gsub('%.mk$', '')
	name = name:gsub('^[Mm]akefile[%.%-_]?', ''):gsub('^GNUmakefile[%.%-_]?', '')
	return name
end

-- target -> prefix of the makefile that defines it, by scanning the makefiles
-- for `target:` lines (first file wins). make -p names the file only for
-- targets with a recipe, so `all: sync` would have none.
local function target_prefixes(dir, makefiles)
	local prefixes = {}
	for _, file in ipairs(makefiles) do
		local path = vim.fs.joinpath(dir, file)
		if vim.fn.filereadable(path) == 1 then
			local prefix = makefile_prefix(file)
			for _, line in ipairs(vim.fn.readfile(path)) do
				local names = line:match('^([^%s:=#%.][^:=]*):')
				if names then
					for _, name in ipairs(vim.split(vim.trim(names), '%s+', { trimempty = true })) do
						if prefixes[name] == nil then
							prefixes[name] = prefix
						end
					end
				end
			end
		end
	end
	return prefixes
end

-- main Makefile's targets first, then by prefix, then by name (as `order`).
-- Label: `sync`, or `lazy: sync` for a target from Makefile.lazy.mk.
---@return genja.f2.Task[]
local function sorted_tasks(targets, prefixes, dir)
	local rows = {}
	for _, target in ipairs(targets) do
		table.insert(rows, { target = target, prefix = prefixes[target] or '' })
	end
	table.sort(rows, function(a, b)
		if a.prefix ~= b.prefix then
			return a.prefix < b.prefix -- '' sorts first
		end
		return a.target < b.target
	end)
	local tasks = {}
	for i, row in ipairs(rows) do
		local label = row.target
		if row.prefix ~= '' then
			label = row.prefix .. ': ' .. row.target
		end
		table.insert(tasks, { group = 'make', label = label, cmd = { 'make', row.target }, cwd = dir, order = i })
	end
	return tasks
end

---@param ctx genja.f2.Ctx
---@param done fun(tasks: genja.f2.Task[])
function M.collect(ctx, done)
	local makefile = find_makefile(ctx.dir)
	if not makefile then
		done({})
		return
	end
	if vim.fn.executable('make') == 0 then
		vim.notify(SRC .. 'found ' .. makefile .. ', but no make in nvim\'s PATH', vim.log.levels.WARN)
		done({})
		return
	end
	local dir = vim.fs.dirname(makefile)
	vim.system({ 'make', '-rRpq' }, { cwd = dir, text = true, env = { LANG = 'C' } }, vim.schedule_wrap(function(res)
		-- -q: exit 1 just means "something is out of date"
		if res.code ~= 0 and res.code ~= 1 then
			vim.notify(SRC .. 'make -rRpq failed: ' .. vim.trim(res.stderr or ''), vim.log.levels.ERROR)
			done({})
			return
		end
		local targets, makefiles = parse_targets(res.stdout or '')
		if #targets == 0 then
			vim.notify(SRC .. 'no targets in ' .. makefile, vim.log.levels.WARN)
			done({})
			return
		end
		local entries = {}
		local nothing = function() end -- targets aren't stored
		for _, task in ipairs(sorted_tasks(targets, target_prefixes(dir, makefiles), dir)) do
			table.insert(entries, { task = task, remove = nothing })
		end
		done({
			{
				group = 'make',
				-- folder name: shows which Makefile was found (e.g. ~/makefile from oil at ~)
				label = ('targets (%d)  (%s)'):format(#entries, vim.fs.basename(dir)),
				action = function(pick_ctx)
					picker.entries(entries, pick_ctx, { title = 'make targets: ' .. vim.fn.fnamemodify(dir, ':~') })
				end,
			},
		})
	end))
end

-- exposed for tests/f2
M._parse_targets = parse_targets
M._makefile_prefix = makefile_prefix
M._sorted_tasks = sorted_tasks

return M
