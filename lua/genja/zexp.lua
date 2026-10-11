



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
-- local function reload_config()
--     for name,_ in pairs(package.loaded) do
--         if name:match('^user') then
--             package.loaded[name] = nil
--         end
--     end
--     -- require('user')
--     -- Reload after/ directory
--     local glob = vim.fn.stdpath('config') .. '/after/**/*.lua'
--     local after_lua_filepaths = vim.fn.glob(glob, true, true)
--     for _, filepath in ipairs(after_lua_filepaths) do
--         dofile(filepath)
--     end
--     vim.notify("Nvim configuration reloaded!", vim.log.levels.INFO)
-- end

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


--======================================
-- -- Define the object prototype
-- local Object = {
-- 	value = 0,
-- 	new = function(self)
-- 		local clone = {}
-- 		for prop, fn in pairs(self) do if type(fn) ~= "function" then clone[prop] = fn end end
-- 		return setmetatable(clone, {__index = self})
-- 	end,
-- 	printValue = function(self)
-- 		print("Value:", self.value)
-- 	end,
-- 	setValue = function(self, value)
-- 		self.value = value
-- 	end
-- }
-- -- Create a new object
-- local obj1 = Object:new()
-- obj1 = obj1
-- ---
--======================================


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



-- local curl = require('plenary.curl')
-- local function make_request()
--   -- local url = 'https://movielens.org/explore?q=cakez'
--   local url = 'https://movielens.org/explore'
--   local response = curl.get(url, {
-- 	  query = { q = 'cakez' },
-- 	  raw = { '--max-redirs', '0'}
--   })
--   local file, err = io.open("C:\\tmp\\curl-out.html", "w")
--   if file then
-- 	  file:write(response.body)
-- 	  file:close()
--   end
--   if response.status == 200 then
-- 	print("Status: ", response.status, "Body: ", #response.body)
-- 	-- print("Headers: ", vim.inspect(response.headers))
--   else
--     print("HTTP request failed with status: ", response.status)
--   end
-- end
-- make_request()




-- recent folders
-- --
-- -- %AppData%\Microsoft\Windows\Recent\
-- local pat = vim.env.AppData .. '\\Microsoft\\Windows\\Recent\\*'
-- local res = vim.fn.glob(pat, false, true)
-- -- print( res[60] )
-- -- print( pat )
-- local n = 0
-- for _, lnk in ipairs(res) do
-- 	if n < 80 then
-- 		local h = io.popen([[A:\\bin\\lnk-target.bat ]] .. '"'  .. lnk .. '"' )
-- 		local o = h:read('*a')
-- 		h:close()
-- 		o = o:gsub('%s*$', '') -- trim trailing spaces
-- 		if o ~= '' then
-- 			if not string.match(o, 'pr0n') then
-- 				if IsDir(o
-- 					print('dir', e:match('pr0n'),  o)
-- 				end
-- 				n = n + 1
-- 			end
-- 		end
-- 	end
-- end


-- -- command! Lazygit :FloatermNew 
-- -- --height=0.96 --width=0.94 --wintype=
-- -- require("toggleterm").exec("lazygit")
-- local Terminal  = require('toggleterm.terminal').Terminal
-- local lazygit = Terminal:new({
--     close_on_exit = true,
-- 	display_name = 'Lazygit',
-- 	cmd = 'lazygit',
-- 	hidden = true,
-- 	dir = 'git_dir',
-- 	ection = 'float',
-- 	float_opts = {
-- 		width = 94,
-- 		height = 94,
-- 	},
-- 	-- border = 'single' | 'double' | 'shadow' | 'curved' | ... other options supported by win open
-- 	border = 'single',
-- 
-- 	-- on_close = function(term)
-- 		-- vim.cmd("startinsert!")
-- 	-- end,
-- 	-- on_open = function(term)
-- 	-- 	vim.api.nvim_set_current_win(term.window)
-- 	-- 	vim.api.nvim_set_current_buf(term.bufnr)
-- 	-- 	vim.cmd('startinsert!')
-- 	-- 	-- vim.api.nvim_buf_set_keymap(term.bufnr, 'n', 'q', '<cmd>close<CR>', {noremap = true, silent = true})
-- 	-- 	-- vim.api.nvim_buf_set_keymap(term.bufnr, 'n', 'q', '<cmd>close<CR>', {noremap = true, silent = true})
-- 	-- 	-- vim.api.nvim_buf_set_keymap(term.bufnr, 'i', '<esc>', '<cmd>close<CR>', {noremap = true, silent = true})
-- 	-- end,
-- 	on_open = function(term)
-- 		vim.cmd("startinsert!")  -- Automatically enter insert mode after opening
-- 		vim.api.nvim_set_current_win(term.window)  -- Focus the terminal window
-- 	end
-- })
-- lazygit:toggle()

--[[

    Terminal:new {
      cmd = string -- command to execute when creating the terminal e.g. 'top'
      display_name = string -- the name of the terminal
      direction = string -- the layout for the terminal, same as the main config options
      dir = string -- the directory for the terminal
      close_on_exit = bool -- close the terminal window when the process exits
      highlights = table -- a table with highlights
      env = table -- key:value table with environmental variables passed to jobstart()
      clear_env = bool -- use only environmental variables from `env`, passed to jobstart()
      on_open = fun(t: Terminal) -- function to run when the terminal opens
      on_close = fun(t: Terminal) -- function to run when the terminal closes
      auto_scroll = boolean -- automatically scroll to the bottom on terminal output
      -- callbacks for processing the output
      on_stdout = fun(t: Terminal, job: number, data: string[], name: string) -- callback for processing output on stdout
      on_stderr = fun(t: Terminal, job: number, data: string[], name: string) -- callback for processing output on stderr
      on_exit = fun(t: Terminal, job: number, exit_code: number, name: string) -- function to run when terminal process exits
    }
]]


-- for _, e in pairs({
-- 	'Activator',
-- 	'Actor',
-- 	'Apparatus',
-- 	'Armor',
-- 	'Book',
-- 	'Container',
-- 	'Creature',
-- 	'Door',
-- 	'Ingredient',
-- 	'Item',
-- 	'Light',
-- 	'Lockpick',
-- 	'Miscellaneous',
-- 	'NPC',
-- 	'Player',
-- 	'Potion',
-- 	'Probe',
-- 	'Repair',
-- 	'Static',
-- 	'Weapon',
-- }) do
-- 	print('addHandler '..e)
-- end



local function async_fs_stat(path, timeout_ms, callback)
	local timer = vim.loop.new_timer()
	local done = false

	vim.loop.fs_stat(path, function(err, stat)
		if not done then
			done = true
			timer:stop()
			timer:close()
			callback(err, stat)
		end
	end)

	timer:start(timeout_ms, 0, function()
		if not done then
			done = true
			timer:close()
			callback(nil, false)
		end
	end)
end


-- local s;
-- local e;
-- local over;
-- function sleep(n)
-- 	local t0 = os.clock()
-- 	while os.clock() - t0 <= n do end
-- end
-- async_fs_stat('C:\\tmp', 1300, function(err, stat)
-- 	over = true
-- 	s = stat
-- 	if err ~= nil then
-- 		e = err
-- 	end
-- print('bai')
-- end)
-- while not over do
-- 	print('z')
-- 	sleep(1)
-- end
-- print('hai')
-- print( vim.inspect( s ) )




-- Output: Bob is 30 years old. Happy birthday, Bob!


-- require('telescope.builtin').find_files({
--   prompt_title = 'find string in open buffers...',
-- }):find()


-- -- hm...
-- function os.capture(cmd, raw)
-- 	local f = assert(io.popen(cmd, 'r'))
-- 	local s = assert(f:read('*a'))
-- 	f:close()
-- 	if raw then return s end
-- 	s = string.gsub(s, '^%s+', '')
-- 	s = string.gsub(s, '%s+$', '')
-- 	s = string.gsub(s, '[\n\r]+', ' ')
-- 	return s
-- end

print( type (  package.loaded ))

package.loaded['genja.fn'] = nil

for _, e in pairs(package.loaded) do
	-- print(type(e) .. ' ' .. _)
end
