-- x: close the quickfix or location list
local function close_list()
	local info = vim.fn.getwininfo(vim.api.nvim_get_current_win())[1]
	if info.loclist == 1 then
		vim.cmd.lclose()
	else
		vim.cmd.cclose()
	end
end

vim.keymap.set('n', 'x', close_list, { buffer = true, silent = true, desc = 'Quickfix: close list' })

-- left click on an entry opens it: the global <LeftMouse> map in lua/genja/map-zero.lua
-- (a buffer-local map here would miss the first click, which only focuses the list from another window)
