-- <F2> source, group `diag`: when the diagnostics limit (lua/genja/diag-limit.lua)
-- hides some in this buffer, one item that shows them all here; after that, one that
-- hides the excess again.

local M = {}

---@param ctx genja.f2.Ctx
---@param done fun(tasks: genja.f2.Task[])
function M.collect(ctx, done)
	local items = {}
	local limit = require('genja.diag-limit')
	local hidden = limit.hidden(ctx.bufnr)
	if hidden > 0 then
		table.insert(items, {
			group = 'diag',
			label = ('show all (%d hidden)'):format(hidden),
			action = function()
				limit.show_all(ctx.bufnr)
			end,
		})
	end
	local excess = limit.excess(ctx.bufnr)
	if excess > 0 then
		table.insert(items, {
			group = 'diag',
			label = ('hide excess (%d over %d per severity)'):format(excess, limit.global_limit()),
			action = function()
				limit.hide_excess(ctx.bufnr)
			end,
		})
	end
	done(items)
end

return M
