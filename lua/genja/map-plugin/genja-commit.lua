-- Keys for lua/lazyp/new/genja-commit.lua. Oil's keys for it: lua/genja/map-oil.lua.

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
	local function commit_popup() require('genja-commit').open(commit_dir()) end

	local spec_name = Maps.current_file()
	-- todo: add function Maps:keys_for_plug that avoids having to look up filename via maps.current_file (just one stack deeper)
	Maps:add_keys(spec_name, {
		{ '<leader>mGc', commit_popup, desc = 'UI: Git commit modal' },
		{ '<leader>gcm', commit_popup, desc = 'UI: Git commit modal' },
		{ '<leader>C', commit_popup, desc = 'UI: Git commit modal' },
	})
end
