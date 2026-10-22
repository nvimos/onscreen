-- git commit popup in oil's dir; the popup lives in plug-wip/genja-commit.nvim

local M = {}

M.git_commit = function()
	local dir = require('oil').get_current_dir()
	if not dir then
		return
	end
	require('genja-commit').open(dir)
end

return M
