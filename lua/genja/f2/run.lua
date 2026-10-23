-- Run <F2> tasks: normal-mode keys, Lua functions, or commands in overseer
-- (default) or floaterm. Handles autoremove.

local M = {}

local SRC = 'lua/genja/f2/run.lua: '

---@param cmd string|string[]
---@return string
local function cmd_string(cmd)
	if type(cmd) == 'string' then
		return cmd
	end
	local parts = {}
	for _, arg in ipairs(cmd) do
		table.insert(parts, vim.fn.shellescape(arg))
	end
	return table.concat(parts, ' ')
end

---Run cmd as an overseer task.
---@param name string task name in the overseer list
---@param cmd string|string[]
---@param cwd string
---@param on_exit? fun(code: integer) called on the main loop
---@param opts? { quiet?: boolean } quiet: notify and open the task list only on failure; drop the task on success
function M.overseer(name, cmd, cwd, on_exit, opts)
	local overseer = require('overseer')
	local quiet = opts and opts.quiet
	local task_opts = { name = name, cmd = cmd, cwd = cwd }
	if quiet then
		-- overseer's 'default' components, with the notification limited to failures
		task_opts.components = {
			'on_exit_set_status',
			{ 'on_complete_notify', statuses = { 'FAILURE' } },
			{ 'on_complete_dispose', require_view = { 'SUCCESS', 'FAILURE' } },
		}
	end
	local task = overseer.new_task(task_opts)
	if on_exit then
		task:subscribe('on_exit', function(_, code)
			vim.schedule(function() on_exit(code) end)
			return true -- unsubscribe
		end)
	end
	if quiet then
		task:subscribe('on_complete', function(done_task, status)
			vim.schedule(function()
				if status == 'SUCCESS' then
					done_task:dispose()
				elseif status == 'FAILURE' then
					overseer.open({ enter = false })
				end
			end)
			return true -- unsubscribe
		end)
	end
	task:start()
	if not quiet then
		overseer.open({ enter = false })
	end
end

---Run cmd in a new floaterm; the exit code comes from TermClose.
---@param cmd string|string[]
---@param cwd string
---@param on_exit? fun(code: integer)
function M.floaterm(cmd, cwd, on_exit)
	-- floaterm splits its arguments on spaces
	vim.cmd('FloatermNew --cwd=' .. cwd:gsub(' ', '\\ ') .. ' ' .. cmd_string(cmd))
	local bufnr = vim.api.nvim_get_current_buf()
	if on_exit and vim.bo[bufnr].buftype == 'terminal' then
		vim.api.nvim_create_autocmd('TermClose', {
			buffer = bufnr,
			once = true,
			callback = function() on_exit(vim.v.event.status) end,
		})
	end
end

---Run a task. `remove` drops it from the registry (a no-op for source items).
--- function: removed when autoremove is set and it returns true
--- string:   normal-mode keys with mappings; removed after feeding if autoremove
--- cmd:      removed when the exit code equals autoremove (true = 0)
---@param task genja.f2.Task
---@param ctx genja.f2.Ctx
---@param remove fun()
function M.task(task, ctx, remove)
	local action = task.action
	if type(action) == 'function' then
		local ok, result = pcall(action, ctx)
		if not ok then
			vim.notify(SRC .. task.group .. ': ' .. task.label .. ': ' .. tostring(result), vim.log.levels.ERROR)
		elseif task.autoremove and result == true then
			remove()
		end
		return
	end
	if type(action) == 'string' then
		-- after telescope has left insert mode and closed its window
		vim.schedule(function()
			vim.api.nvim_feedkeys(vim.keycode(action), 'm', false)
		end)
		if task.autoremove then
			remove()
		end
		return
	end

	local remove_code = nil
	if task.autoremove == true then
		remove_code = 0
	elseif type(task.autoremove) == 'number' then
		remove_code = task.autoremove
	end
	local on_exit = nil
	if remove_code then
		on_exit = function(code)
			if code == remove_code then
				remove()
			end
		end
	end
	local cwd = task.cwd or ctx.dir
	if task.runner == 'floaterm' then
		M.floaterm(task.cmd, cwd, on_exit)
	else
		local name = task.cmd
		if type(name) == 'table' then
			name = table.concat(name, ' ') -- readable; shellescape quotes on Windows
		end
		M.overseer(name, task.cmd, cwd, on_exit)
	end
end

---Run the picked entries in order. Entries with the same `merge` key and cwd
---run as one command: the first cmd plus the last argument of each other cmd.
---@param entries genja.f2.Entry[]
---@param ctx genja.f2.Ctx
function M.entries(entries, ctx)
	local merged = {} ---@type table<string, {task: genja.f2.Task, removes: fun()[]}>
	local runs = {} ---@type {task: genja.f2.Task, removes: fun()[]}[]
	for _, entry in ipairs(entries) do
		local task = entry.task
		local key = nil
		if task.merge and type(task.cmd) == 'table' then
			key = task.merge .. '\0' .. (task.cwd or ctx.dir)
		end
		if key and merged[key] then
			table.insert(merged[key].task.cmd, task.cmd[#task.cmd])
			table.insert(merged[key].removes, entry.remove)
		else
			local item = { task = task, removes = { entry.remove } }
			if key then
				-- copy, so appending args leaves the original task alone
				item.task = vim.tbl_extend('force', {}, task, { cmd = vim.list_slice(task.cmd) })
				merged[key] = item
			end
			table.insert(runs, item)
		end
	end
	for _, item in ipairs(runs) do
		M.task(item.task, ctx, function()
			for _, remove in ipairs(item.removes) do
				remove()
			end
		end)
	end
end

return M
