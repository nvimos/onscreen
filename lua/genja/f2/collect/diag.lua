-- <F2> source, group `diag`: when the diagnostics limit (lua/genja/ext/diag-limit.lua)
-- hides some in this buffer, one item that shows them all here; after that, one that
-- hides the excess again. With diagnostics in the buffer: switch the virtual text column
-- (lua/genja/ext/diag-align.lua).

local groups = require('genja.f2.groups')

local M = {}

---@param ctx genja.f2.Ctx
---@param done fun(tasks: genja.f2.Task[])
function M.collect(ctx, done)
	local items = {}
	local limit = require('genja.ext.diag-limit')
	local hidden = limit.hidden(ctx.bufnr)
	if hidden > 0 then
		table.insert(items, {
			group = groups.diag,
			label = ('show all (%d hidden)'):format(hidden),
			action = function()
				limit.show_all(ctx.bufnr)
			end,
		})
	end
	local excess = limit.excess(ctx.bufnr)
	if excess > 0 then
		table.insert(items, {
			group = groups.diag,
			label = ('hide excess (%d over %d per severity)'):format(excess, limit.global_limit()),
			action = function()
				limit.hide_excess(ctx.bufnr)
			end,
		})
	end
	if #vim.diagnostic.get(ctx.bufnr) > 0 then
		local align = require('genja.ext.diag-align')
		local label = 'align: one column per paragraph'
		if align.enabled() then
			label = 'align: at the end of each line'
		end
		table.insert(items, { group = groups.diag, label = label, action = align.toggle })
	end
	done(items)
end

return M
