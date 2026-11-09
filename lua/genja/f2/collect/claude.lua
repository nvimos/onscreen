-- <F2> source, group `claude`: one item per running claude terminal; <CR> shows it and jumps in.
-- Terminals come from plug-wip/genja-claudefterm.nvim; nothing runs until it is loaded.

local M = {}

---@param _ genja.f2.Ctx
---@param done fun(tasks: genja.f2.Task[])
function M.collect(_, done)
	local items = {}
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
			group = require('genja.f2.groups').claude,
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
