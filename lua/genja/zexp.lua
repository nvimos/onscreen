

-- vim.g.genja_log_level = 'trace' -- vim.env.GENJA_LOG
-- Log = require('genja.log').log
--
-- Log.fatal("fatal")
-- Log.error("error")
-- Log.info("info")
-- Log.warn("warn")
-- Log.trace("trace")


-- vim.g.genja_log_level = 'trace'
-- vim.g.genja_log_level = 'warn'
-- vim.g.genja_log_level = 'info'
-- vim.g.genja_log_level = 5
--
--
-- require('genja.log').reload()
-- require('genja.log').log.trace('trace')
-- require('genja.log').log.debug('debug')
-- require('genja.log').log.warn('warn')
-- require('genja.log').log.info('info')

-- ==========================================================
-- require('user')
--- Reload the entire configuration
local function reload_config()
    for name,_ in pairs(package.loaded) do
        if name:match('^user') then
            package.loaded[name] = nil
        end
    end
    -- require('user')
    -- Reload after/ directory
    local glob = vim.fn.stdpath('config') .. '/after/**/*.lua'
    local after_lua_filepaths = vim.fn.glob(glob, true, true)
    for _, filepath in ipairs(after_lua_filepaths) do
        dofile(filepath)
    end
    vim.notify("Nvim configuration reloaded!", vim.log.levels.INFO)
end

-- ==========================================================


-- local c = vim.fn.stdpath('config')
-- local ff = vim.fn.glob(c..'/**/*.lua', true, true)
-- local ff = vim.fn.glob(c..'/lua/genja/*.lua', true, true)
-- local m = vim.fn.fnamemodify
-- for _, e  in ipairs(ff) do
-- 	--print(e)
-- 	print( string.format('%s %4s %-20s',
-- 		m(e, ':p:h'), -- path head (dirname)
-- 		m(e, ':e'),   -- extension
-- 		m(e, ':t:r')  -- (path) tail , root only (no ext)
-- 	))
-- 	-- dofile(e)
-- end


-- local c = vim.fn.stdpath('config')
-- local ff = vim.fn.readdir(c..'/lua/genja/', 'v:val =~ "\\.lua$"')
-- print(vim.inspect(ff))
-- --for _, e in ipairs(ff) do print(e) end




-- Function to source a file with error handling
-- local function psource(file)
-- 	local status, err = pcall(vim.cmd, [[source ]]..file)
-- 	if not status then
-- 		print(string.format("psource(%s):\n%s", vim.inspect(err)))
-- 	end
-- end

-- 
-- vim.api.nvim_create_autocmd('BufWritePost', {
-- 	group = vim.api.nvim_create_augroup('conf-reload', { clear = true }),
-- 	pattern = vim.fn.readdir(vim.fn.stdpath('config')..'/lua/genja/', 'v:val =~ "\\.lua$"'), -- init.lua, opt.lua, ...
-- 	callback = function(ev)
-- 		local safeish = { [''] = false }
-- 		local _safeish =  {
-- 			'zexp.lua' ,
-- 			'map.lua' ,
-- 			'init-map.lua',
-- 			'opt.lua' ,
-- 			'alias.lua',
-- 			'auto.lua',
-- 			'winbar.lua',
-- 		}
-- 		for _, e in ipairs(_safeish) do safeish[e] = true end
-- 		local fname = vim.fn.fnamemodify(path, ':t')
-- 		if safeish[fname] then
-- 			if not vim.g.source_safeish then
-- 				return
-- 			end
-- 			local status, err = pcall(vim.cmd, [[source ]]..ev.match)
-- 			if not status then
-- 				print(string.format("psource(%s):\n%s", vim.inspect(err)))
-- 			end
-- 		end
-- 	end
-- })


---
-- Define the object prototype
local Object = {
	value = 0,
	new = function(self)
		local clone = {}
		for prop, fn in pairs(self) do if type(fn) ~= "function" then clone[prop] = fn end end
		return setmetatable(clone, {__index = self})
	end,
	printValue = function(self)
		print("Value:", self.value)
	end,
	setValue = function(self, value)
		self.value = value
	end
}
-- Create a new object
local obj1 = Object:new()
obj1 = obj1
---


-- -- Define a Lua function that takes arguments
-- local function my_function(arg1, arg2)
--     print("Argument 1:", arg1)
--     print("Argument 2:", arg2)
-- end
-- -- Create a custom command that calls the Lua function
-- vim.api.nvim_command("command! -nargs=+ MyFunction lua my_function(<f-args>)")


-- function Close_nerdtree_tabs()
    -- for _, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
		-- local wins = vim.api.nvim_tabpage_list_wins(tabpage)
		-- local win_count = #wins
        -- if win_count == 1 then
            -- local win = vim.api.nvim_tabpage_get_win(tabpage)
            -- local buf = vim.api.nvim_win_get_buf(win)
            -- local ft = vim.api.nvim_buf_get_option(buf, 'filetype')
            -- if ft == 'nerdtree' then
                -- vim.api.nvim_win_close(win, true)
            -- end
        -- end
    -- end
-- end

-- for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
-- 	local bufnr = buffer
-- 	local bufname = vim.api.nvim_buf_get_name(bufnr)
-- 	local buftype = vim.api.nvim_buf_get_option(bufnr, 'filetype')
-- 	-- print(string.format("buf-ft: «%10s» name: %s", buftype, vim.fs.normalize( bufname )))
-- end


-- -- local gg = vim.fn.glob([[Q:\audio-balmora\**\_*]])
-- local gg = {}
-- local pats = {
-- 	[[??-*]],
-- 	[[??-*/_*]],
-- 	[[??-*/*/_*]],
-- 	[[_*]]
-- }
-- local dirs = {
-- 	[[Q:\audio-balmora\musikkkk]],
-- 	[[Q:\audio-balmora\muzica]],
-- }
-- -- for _, d in pairs(dirs) do
-- -- 	for _, p in pairs(pats) do
-- -- 		vim.list_extend(gg, vim.fn.globpath( d, p, false, true))
-- -- 	end
-- -- end
-- -- for _, e in pairs(gg) do
-- -- 	--print(e)
-- -- end


