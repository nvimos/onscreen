-- <F2>: context picker (idea #18). One telescope dropdown with `group: label`
-- items from the sources below and from f2.add_tasks(); runs the chosen one.
-- Sources (one file each, ask the current buffer on every <F2>):
--   adhoc  one-off fixes, e.g. `go mod init` for a .go file without go.mod
--   git    oil only: `add (N files)`, a sub-picker of changed files to add
--   make   `targets (N)`, a sub-picker of the Makefile targets above the dir
--   claude one item per running claude terminal (genja-claudefterm): show it
-- Order: groups by M.group_order (others after it, A-Z), then `order`, then label.

---@class genja.f2.Ctx
---@field dir string where to look: oil's dir, the file's dir, else :pwd
---@field bufnr integer
---@field filetype string

---@class genja.f2.Task
---@field label string
---@field group string shown as the prefix `group: `
---@field action? string|fun(ctx: genja.f2.Ctx): boolean? string: normal-mode keys (with mappings)
---@field cmd? string|string[] instead of action: a command to run
---@field runner? 'overseer'|'floaterm' for cmd; default overseer
---@field cwd? string for cmd; default ctx.dir
---@field order? integer within the group, lower first; default 0
---@field cond? fun(ctx: genja.f2.Ctx): boolean checked on every <F2>
---@field autoremove? boolean|integer remove after a run: function returned true, keys ran, cmd exit code (true = 0)
---@field merge? string marked tasks with the same key (and cwd) run as one cmd: first cmd + last arg of the others

---@class genja.f2.Source
---@field collect fun(ctx: genja.f2.Ctx, done: fun(tasks: genja.f2.Task[]))

local registry = require('genja.f2.registry')
local picker = require('genja.f2.picker')

local M = {}

local SRC = 'lua/genja/f2/init.lua: '

---Group order in the picker; callers may replace it.
M.group_order = { 'adhoc', 'git', 'make', 'oil', 'claude' }

---Add tasks; same group + label updates the earlier one.
---opts.buffer: only for that buffer (0 = current), dropped when it is wiped.
M.add_tasks = registry.add

---Remove a group or one task: { group = ..., label? = ..., buffer? = ... }.
M.remove_tasks = registry.remove

---Builder for one task; nothing is registered until :add().
---  f2.add_task('demo', 'go to top'):keys('gg'):buffer(0):add()
M.add_task = require('genja.f2.builder').new

---@type genja.f2.Source[]
local sources = {
	require('genja.f2.adhoc'),
	require('genja.f2.git'),
	require('genja.f2.make'),
	require('genja.f2.claude'),
}

-- Normalized (forward slashes, no trailing slash): vim.fs.find takes the path
-- as is, and oil gives 'C:\...\nvim\'.
local function start_dir()
	local dir = vim.fn.getcwd()
	local name = vim.api.nvim_buf_get_name(0)
	if vim.bo.filetype == 'oil' then
		dir = require('oil').get_current_dir() or dir
	elseif name ~= '' and vim.bo.buftype == '' then
		dir = vim.fs.dirname(name)
	end
	return vim.fs.normalize(dir)
end

---@param entries genja.f2.Entry[]
local function sort(entries)
	local rank = {}
	for i, group in ipairs(M.group_order) do
		rank[group] = i
	end
	local last = #M.group_order + 1
	table.sort(entries, function(a, b)
		local ta, tb = a.task, b.task
		if ta.group ~= tb.group then
			local ra, rb = rank[ta.group] or last, rank[tb.group] or last
			if ra ~= rb then
				return ra < rb
			end
			return ta.group < tb.group
		end
		local oa, ob = ta.order or 0, tb.order or 0
		if oa ~= ob then
			return oa < ob
		end
		return ta.label < tb.label
	end)
end

function M.open()
	---@type genja.f2.Ctx
	local ctx = { dir = start_dir(), bufnr = vim.api.nvim_get_current_buf(), filetype = vim.bo.filetype }
	local results = {}
	local pending = #sources
	for i, source in ipairs(sources) do
		local done = vim.schedule_wrap(function(tasks)
			results[i] = tasks
			pending = pending - 1
			if pending > 0 then
				return
			end
			local entries = registry.list(ctx)
			local nothing = function() end -- source items aren't stored
			for j = 1, #sources do
				for _, task in ipairs(results[j] or {}) do
					table.insert(entries, { task = task, remove = nothing })
				end
			end
			if #entries == 0 then
				vim.notify(SRC .. 'no context here (' .. ctx.dir .. ')', vim.log.levels.WARN)
				return
			end
			sort(entries)
			picker.entries(entries, ctx, { title = 'eff-two: ' .. vim.fn.fnamemodify(ctx.dir, ':~'), show_group = true })
		end)
		-- a failing source counts as empty, so the others still show
		local ok, err = pcall(source.collect, ctx, done)
		if not ok then
			vim.notify(SRC .. 'source ' .. i .. ' failed: ' .. tostring(err), vim.log.levels.ERROR)
			done({})
		end
	end
end

-- exposed for tests/f2
M._sort = sort

-- Drops the cached f2 modules; the next <F2> loads them fresh. Tasks added
-- with f2.add_tasks() are lost with the registry.
vim.api.nvim_create_user_command('DevReloadF2', function()
	package.loaded['genja.f2'] = nil
	package.loaded['genja.f2.adhoc'] = nil
	package.loaded['genja.f2.builder'] = nil
	package.loaded['genja.f2.git'] = nil
	package.loaded['genja.f2.make'] = nil
	package.loaded['genja.f2.picker'] = nil
	package.loaded['genja.f2.registry'] = nil
	package.loaded['genja.f2.run'] = nil
	package.loaded['genja-finder.telemap'] = nil
	vim.notify(SRC .. 'f2 modules unloaded, next <F2> reloads them')
end, { desc = 'f2: unload the context picker modules' })

return M
