-- small helpers for the oil modules: visual range, cursor entry, cd

local G = require('genja.oil.globals')

local M = {}

-- first and last line of the visual selection, in buffer order
---@return integer start
---@return integer stop
function M.visual_line_range()
	local vis, cur = vim.fn.line("v"), vim.fn.line(".")
	local start, stop = vis, cur
	if cur < vis then
		start, stop = cur, vis
	end
	return start, stop
end

-- oil entry under the cursor, the listed dir and the entry's full path;
-- nil when the buffer is not an oil dir or the line has no entry
---@return oil.Entry|nil entry
---@return string|nil dir
---@return string|nil path
M.oil_entry_dir_path = function()
	local entry = require('oil').get_cursor_entry()
	local dir = require('oil').get_current_dir()
	if not entry or not dir then
		return nil, nil, nil
	end
	local path = G.JoinPaths(dir, entry.name)
	return entry, dir, path
end

-- :cd to the entry under the cursor, or to its dir when it is a file
M.cd_to_entry = function()
	local _, _, path = M.oil_entry_dir_path()
	if not path then
		return
	end
	if not G.IsDir(path) then
		path = G.Dirname(path)
	end
	vim.cmd('cd ' .. path)
end

return M
