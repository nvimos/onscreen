-- f2.add_task(group, label): builder for one task, registered by :add().
--   f2.add_task('go', 'tidy'):cmd({ 'go', 'mod', 'tidy' }):autoremove():buffer(0):add()
-- Each setter fills one genja.f2.Task field; registry.add validates on :add().

local registry = require('genja.f2.registry')

---@class genja.f2.Builder
---@field private task genja.f2.Task
---@field private opts {buffer?: integer}
local Builder = {}
Builder.__index = Builder

---@param group string
---@param label string
---@return genja.f2.Builder
local function new(group, label)
	return setmetatable({ task = { group = group, label = label }, opts = {} }, Builder)
end

---Normal-mode keys, with mappings (`<CR>` notation works).
---@param keys string
function Builder:keys(keys)
	self.task.action = keys
	return self
end

---Lua function; gets ctx; with autoremove, returning true removes the task.
---@param fn fun(ctx: genja.f2.Ctx): boolean?
function Builder:fn(fn)
	self.task.action = fn
	return self
end

---Shell command, run in overseer unless :floaterm().
---@param cmd string|string[]
function Builder:cmd(cmd)
	self.task.cmd = cmd
	return self
end

---Run the cmd in floaterm instead of overseer.
function Builder:floaterm()
	self.task.runner = 'floaterm'
	return self
end

---@param dir string
function Builder:cwd(dir)
	self.task.cwd = dir
	return self
end

---@param n integer within the group, lower first
function Builder:order(n)
	self.task.order = n
	return self
end

---@param fn fun(ctx: genja.f2.Ctx): boolean
function Builder:cond(fn)
	self.task.cond = fn
	return self
end

---Remove after a run; for cmd the exit code that removes it (default 0).
---@param code? integer
function Builder:autoremove(code)
	self.task.autoremove = (code == nil and true or code)
	return self
end

---@param key string marked tasks with the same key run as one cmd
function Builder:merge(key)
	self.task.merge = key
	return self
end

---Only in this buffer (0 = current).
---@param bufnr integer
function Builder:buffer(bufnr)
	self.opts.buffer = bufnr
	return self
end

---Register the task.
function Builder:add()
	registry.add({ self.task }, self.opts)
end

return { new = new }
