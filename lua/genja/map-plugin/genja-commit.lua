-- Keys for lua/lazyp/new/genja-commit.lua. In oil: ggc / <LocalLeader>c (lua/genja/map-oil.lua).

---Repo to commit in: oil's dir, else the buffer's file dir, else the cwd.
---@return string
local function commit_dir()
	if vim.bo.filetype == 'oil' then
		local dir = require('oil').get_current_dir()
		if dir then
			return dir
		end
	end
	local name = vim.api.nvim_buf_get_name(0)
	if vim.bo.buftype == '' and name ~= '' then
		return vim.fs.dirname(name)
	end
	return vim.fn.getcwd()
end

---@param Maps genja.MapPlugin
return function(Maps)
	local spec_name = Maps.current_file()

    Maps:add_keys(spec_name, {
        { '<leader>mGc', function() require('genja-commit').open(commit_dir()) end, desc = 'UI: git commit popup (genja-commit)' }, 
    })
end
