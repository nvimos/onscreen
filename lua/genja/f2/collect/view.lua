-- <F2> source, group `view`: switches for how the current window looks.
--   colorcolumn on|off   lua/genja/ext/colorcolumn.lua, also <leader>tC

local groups = require('genja.f2.groups')

local M = {}

---@param _ genja.f2.Ctx
---@param done fun(tasks: genja.f2.Task[])
function M.collect(_, done)
	local cc = require('genja.ext.colorcolumn')
	local label = 'colorcolumn on'
	if cc.is_on() then
		label = 'colorcolumn off (' .. vim.wo.colorcolumn .. ')'
	end
	done({ { group = groups.view, label = label, action = cc.toggle } })
end

return M
