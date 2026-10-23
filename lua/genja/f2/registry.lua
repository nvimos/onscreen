-- Tasks added with f2.add_tasks(): global, or scoped to one buffer (dropped
-- on BufWipeout). Keyed by group + label: adding the same pair again updates it.

local M = {}

local SRC = 'lua/genja/f2/registry.lua: '

---@type table<string, genja.f2.Task>
local global = {}
---@type table<integer, table<string, genja.f2.Task>>
local buffers = {}

vim.api.nvim_create_autocmd('BufWipeout', {
	group = vim.api.nvim_create_augroup('genja.f2.registry', { clear = true }),
	desc = '<F2>: drop the tasks of a wiped buffer',
	callback = function(args)
		buffers[args.buf] = nil
	end,
})

---@param task genja.f2.Task
---@return string
local function key(task)
	return task.group .. '\0' .. task.label
end

---@param buffer? integer 0 = current
---@return integer?
local function resolve(buffer)
	if buffer == 0 then
		return vim.api.nvim_get_current_buf()
	end
	return buffer
end

---@param task genja.f2.Task
---@return string? problem
local function invalid(task)
	if type(task.label) ~= 'string' or type(task.group) ~= 'string' then
		return 'needs label and group'
	end
	if (task.action == nil) == (task.cmd == nil) then
		return 'needs either action or cmd'
	end
	return nil
end

---@param tasks genja.f2.Task[]
---@param opts? {buffer?: integer}
function M.add(tasks, opts)
	local store = global
	local buf = resolve(opts and opts.buffer)
	if buf then
		buffers[buf] = buffers[buf] or {}
		store = buffers[buf]
	end
	for _, task in ipairs(tasks) do
		local problem = invalid(task)
		if problem then
			vim.notify(SRC .. 'skipped task ' .. vim.inspect(task.label) .. ': ' .. problem, vim.log.levels.WARN)
		else
			store[key(task)] = task
		end
	end
end

---Remove a group, or one task of it. buffer nil: global tasks only.
---@param filter {group: string, label?: string, buffer?: integer}
function M.remove(filter)
	local store = global
	local buf = resolve(filter.buffer)
	if buf then
		store = buffers[buf] or {}
	end
	for k, task in pairs(store) do
		if task.group == filter.group and (filter.label == nil or task.label == filter.label) then
			store[k] = nil
		end
	end
end

---@class genja.f2.Entry
---@field task genja.f2.Task
---@field remove fun()

---Global tasks plus the ones of ctx.bufnr whose cond passes (errors hide the task).
---@param ctx genja.f2.Ctx
---@return genja.f2.Entry[]
function M.list(ctx)
	local entries = {}
	local function collect(store)
		for k, task in pairs(store) do
			local show = true
			if task.cond then
				local ok, result = pcall(task.cond, ctx)
				if not ok then
					vim.notify(SRC .. task.group .. ': ' .. task.label .. ': cond failed: ' .. tostring(result), vim.log.levels.WARN)
				end
				show = ok and result == true
			end
			if show then
				table.insert(entries, { task = task, remove = function() store[k] = nil end })
			end
		end
	end
	collect(global)
	collect(buffers[ctx.bufnr] or {})
	return entries
end

return M
