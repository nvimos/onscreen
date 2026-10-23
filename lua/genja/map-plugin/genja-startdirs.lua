-- Keys for lua/lazyp/new/genja-startdirs.lua. Oil's ,s / ,S are in lua/genja/map-oil.lua.

local function sd() return require('genja-startdirs') end

--- Oil's dir, the file's dir, else :pwd.
---@return string
local function current_dir()
	if vim.bo.filetype == 'oil' then
		local dir = require('oil').get_current_dir()
		if dir then
			return dir
		end
	end
	local name = vim.api.nvim_buf_get_name(0)
	if name ~= '' and vim.bo.buftype == '' then
		return vim.fs.dirname(name)
	end
	return vim.fn.getcwd()
end

local function add() sd().add(current_dir()) end
local function remove() sd().remove(current_dir()) end
local function edit() sd().edit() end
local function picker() vim.cmd('Telescope mydirs') end

---@param n integer
---@return fun()
local function jump(n)
	return function() sd().jump(n) end
end

---@param Maps genja.MapPlugin
return function(Maps)
	local spec_name = Maps.current_file()

	Maps:add_keys(spec_name, {
		{ '<leader>sa', add, desc = 'Dirs: add current dir to start dirs' },
		{ '<leader>sr', remove, desc = 'Dirs: remove current dir from start dirs' },
		{ '<leader>se', edit, desc = 'Dirs: edit start dirs file' },
		{ '<leader>sp', picker, desc = 'Dirs: start dirs picker (most used first)' },
		{ '<leader>jA', add, desc = 'Dirs: add current dir to start dirs' },
		{ '<leader>je', edit, desc = 'Dirs: edit start dirs file' },
		{ '<leader>jD', picker, desc = 'Dirs: start dirs picker (most used first)' },
		{ '<M-1>', jump(1), desc = 'Dirs: start dir 1' },
		{ '<M-2>', jump(2), desc = 'Dirs: start dir 2' },
		{ '<M-3>', jump(3), desc = 'Dirs: start dir 3' },
		{ '<M-4>', jump(4), desc = 'Dirs: start dir 4' },
	})
end
