-- colorcolumn on/off for the current window: off remembers the columns, on brings them back
-- (80 when there were none). Key in map-zero.lua, F2 item in the view group.

local SRC = 'lua/genja/ext/colorcolumn.lua: '

local M = {}

local DEFAULT = '80'

---@return boolean
function M.is_on()
	return vim.wo.colorcolumn ~= ''
end

function M.toggle()
	if M.is_on() then
		vim.w.genja_colorcolumn = vim.wo.colorcolumn
		vim.wo.colorcolumn = ''
		vim.notify(SRC .. 'colorcolumn off')
		return
	end
	local columns = vim.w.genja_colorcolumn
	if not columns or columns == '' then
		columns = DEFAULT
	end
	vim.wo.colorcolumn = columns
	vim.notify(SRC .. 'colorcolumn ' .. columns)
end

return M
