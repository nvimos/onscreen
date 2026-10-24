-- <F2> source, group `diagnostics`: when the diagnostics limit (lua/genja/diag-limit.lua)
-- hides some in this buffer, one item that shows them all here.

local M = {}

---@param ctx genja.f2.Ctx
---@param done fun(tasks: genja.f2.Task[])
function M.collect(ctx, done)
	local items = {}
	local limit = require('genja.diag-limit')
	local hidden = limit.hidden(ctx.bufnr)
	if hidden > 0 then
		table.insert(items, {
			group = 'diagnostics',
			label = ('show all (%d hidden)'):format(hidden),
			action = function()
				limit.show_all(ctx.bufnr)
			end,
		})
	end
	done(items)
end

return M
