-- <F2> source, group `msgs`: file:line locations from :messages (Lua tracebacks,
-- Vim script errors), newest first, at most 10; picking one opens it (lua/genja/messages.lua).

local M = {}

local MAX = 10

---@param _ genja.f2.Ctx
---@param done fun(tasks: genja.f2.Task[])
function M.collect(_, done)
	local messages = require('genja.messages')
	local items = {}
	for i, loc in ipairs(messages.newest(MAX)) do
		table.insert(items, {
			group = 'msgs',
			label = vim.fn.fnamemodify(loc.filename, ':~:.') .. ':' .. loc.lnum,
			order = i,
			action = function()
				messages.open(loc)
			end,
		})
	end
	done(items)
end

return M
