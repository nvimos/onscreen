-- <F2> source, group `gui`: in a GUI, one item that opens the GuiFuncs picker, like mylunsj's.

local M = {}

---@param _ genja.f2.Ctx
---@param done fun(tasks: genja.f2.Task[])
function M.collect(_, done)
	local items = {}
	if vim.fn.has('gui_running') == 1 then
		table.insert(items, {
			group = 'gui',
			label = 'funcs frame full scroll',
			action = function()
				require('telescope._extensions.mylunsj.gui-funcs').show_picker()
			end,
		})
	end
	done(items)
end

return M
