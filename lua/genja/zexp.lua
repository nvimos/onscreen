

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


local function bdecode(data)
	local function decode_item(index)
		local char = data:sub(index, index)
		-- Decode integer
		if char == "i" then
			local end_index = data:find("e", index)
			local number = tonumber(data:sub(index + 1, end_index - 1))
			return number, end_index + 1
			-- Decode string
		elseif char:match("%d") then
			local colon_index = data:find(":", index)
			local length = tonumber(data:sub(index, colon_index - 1))
			local str = data:sub(colon_index + 1, colon_index + length)
			return str, colon_index + length + 1
			-- Decode list
		elseif char == "l" then
			local list = {}
			index = index + 1
			while data:sub(index, index) ~= "e" do
				local item
				item, index = decode_item(index)
				table.insert(list, item)
			end
			return list, index + 1
			-- Decode dictionary
		elseif char == "d" then
			local dict = {}
			index = index + 1
			while data:sub(index, index) ~= "e" do
				local key
				key, index = decode_item(index)
				local value
				value, index = decode_item(index)
				dict[key] = value
			end
			return dict, index + 1
		else
			error("Invalid Bencode data at index " .. index)
		end
	end
	local result, _ = decode_item(1)
	return result
end

function TorrentTarget(torrent)
	local file = io.open(torrent, "rb")
	if not file then
		return
	end
	local torrentData = file:read("*all"); file:close()
	local decoded = bdecode(torrentData)
	if decoded.info.files  then
		return { torrent = torrent, type = "directory", name = decoded.info.name}
	else
		return { torrent = torrent, type = "file", name = decoded.info.name }
	end
end

local D = vim.inspect
local K = vim.tbl_keys
local luv = vim.loop

----------------------------------------------

local children = function (path, skip_suffixes)
	skip_suffixes = skip_suffixes or { [".bak"] = true }
	local c = {}
	local function chi(cp)
		local fh = nil
		local entry = false
		fh = luv.fs_scandir(cp)
		if fh then
			entry = luv.fs_scandir_next(fh)
		end
		while entry do
			-- table.insert(c, { a = entry[1], b = entry[2]})
			local P = JoinPaths(cp, entry)
			local ee = {}
			local fi = luv.fs_stat(P)
			if fi then
				ee.mtime = fi.mtime.sec
				ee.size = fi.size
				ee.type = fi.type
				ee.path = P
				ee.name = entry
			else
				ee.path = P
				ee.name = entry
				ee.error = true
			end
			local suff = ee.name:match("%.([^%.]+)$")
			-- print(not skip_suffixes[suff], suff)
			if not skip_suffixes[suff] then
				table.insert(c, ee)
			end
			entry = luv.fs_scandir_next(fh)
		end
	end
	chi(path)
	for _, e in pairs(c) do
		if e.type == 'directory' then
			if e.path then
				-- print("S2", e.path)
				chi(e.path)
			end
		end
	end
	-- print ("S3 <-", #c)
	return c
end

function ScanPaths(p)
	local nowant = {
		["nfo"] = true,
		["sub"] = true,
		["rar"] = true,
		["torrent"] = true,
		["finished"] = true,
	}
	for i = 0, 60 do
		nowant[string.format('r%02d', i)] = true
	end
	local mp = {}
	local globbed = vim.fn.glob(p, false, true)
	-- print('glob', D(globbed))
	for _, dir in pairs(globbed) do
		local dd = children(dir, nowant)
		-- print('SCAN G', dir, #dd)
		for _, e in pairs(dd) do
			-- print(e.name)
			mp[e.name] = e
		end
	end
	return mp
end

local sp = ScanPaths( [[V:\_*{vote-n-remove,0new}]] )
local tt = {
	[[V:/_0new/Jackass.Forever.2022.1080p.WEB-DL.DD5.1.H.264-CMRG [TD].torrent]],
	[[V:\_vote-n-remove\The.Rum.Diary.2011.720p.BRRip.x264-x0r [TD].torrent]],
	[[V:\_0new\When the Wind Blows (1986).avi [TD].torrent]],
	[[V:\_0new/Er.Ist.Wieder.Da.2015.PROPER.720p.BluRay.x264-USURY [TD].torrent]],
}
-- tt = vim.fn.glob('V:/**/*.torrent', false, true)

sp = ScanPaths( [[V:\_*]] )
tt = vim.fn.glob('V:/_0new/*.torrent', false, true)

local L = require('genja.log')
L.init('mv-torrent')
L.nuke()

local log = L.log
for _, path in ipairs(tt) do
	local r = TorrentTarget(path)
	local tfound = nil
	if r then
		local t = sp[r.name]
		if t then
			tfound = t.path
		else
			print("no...", r.name)
			tfound = [[V:/torr/here]]
		end
	end
	if tfound then
		local esc = vim.fn.shellescape
		-- local msg = string.format([[mv %-70s %s]], esc(path), esc(Dirname(tfound)) )
		local f = path:gsub([[\+]], '/')
		local t = Dirname(tfound):gsub([[\+]], '/')
		local msg1 = string.format([[mv %q %q]], f, t )
		local msg2 = string.format([[mv %q %q]], f:gsub('(torrent)$', 'finished'), t )
		-- local msg = string.format([[mv %-70s %s]], esc(path), esc(Dirname(tfound)) )
		log.warn( msg1 )
		print( msg1 )

		log.warn( msg2 )
		print( msg2 )
	end
end

print()

-- print(D(
-- TorrentTarget([[V:\_vote-n-remove\The.Rum.Diary.2011.720p.BRRip.x264-x0r [TD].torrent]])
-- ))
