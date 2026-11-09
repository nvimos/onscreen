-- <F2> source, group `claude`: one item per running claude terminal; <CR> shows it and jumps in.
-- Terminals come from plug-wip/genja-claudefterm.nvim; nothing runs until it is loaded.
-- Group `AI`: `claude` runs :Ct (lua/genja/auto-alias.vim, `:ClaudeFterm -1`): claude for the
-- project of the current buffer, in the current window instead of a split; the same toggle as typing :Ct.

local groups = require('genja.f2.groups')

local M = {}

---@return genja.f2.Task
local function start_task()
	return {
		group = groups.ai,
		label = 'claude',
		action = function()
			-- after the picker is gone, so :Ct sees the buffer F2 was opened from
			vim.schedule(function() vim.cmd('Ct') end)
		end,
	}
end

---@param _ genja.f2.Ctx
---@param done fun(tasks: genja.f2.Task[])
function M.collect(_, done)
	local items = { start_task() }
	-- not loaded: no terminal can run, and <F2> shouldn't load it
	if not package.loaded['genja-claudefterm'] then
		done(items)
		return
	end
	local claude = require('genja-claudefterm')
	for i, term in ipairs(claude.running()) do
		-- 'claude-ft «fix tabline»' -> 'fix tabline'; no title yet: the root's name
		local title = term.label:match('«(.*)»')
		if not title or title == '' then
			title = vim.fs.basename(term.root)
		end
		table.insert(items, {
			group = groups.claude,
			label = title,
			order = i,
			action = function()
				claude.show(term.name)
			end,
		})
	end
	done(items)
end

return M
