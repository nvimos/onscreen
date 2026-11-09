-- <F2> source, group `lookup`: the paste search provider switch (plug-wip/genja-paste-ai.nvim).
-- <CR> opens its provider picker: <CR> switches for the session, <M-s> also saves.

local M = {}

---@param _ genja.f2.Ctx
---@param done fun(tasks: genja.f2.Task[])
function M.collect(_, done)
	local ps = require('genja-paste-ai')
	done({ {
		group = require('genja.f2.groups').lookup,
		label = 'paste search provider (' .. ps.current() .. ')',
		action = function()
			ps.pick()
		end,
	} })
end

return M
