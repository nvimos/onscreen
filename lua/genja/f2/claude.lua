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
		table.insert(items, {
			group = 'claude',
			label = term.label .. '  (' .. vim.fn.fnamemodify(term.root, ':~') .. ')',
			order = i,
			action = function()
				claude.show(term.name)
			end,
		})
	end
	done(items)
end

return M
