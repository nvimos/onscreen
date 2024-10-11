local VisualLine = 'V'
local F = {} -- functions



F.sort_by_mtime_in_certain_paths = function()
	-- this is a callback for an autocommand
	local dir = require('oil').get_current_dir()
	local m1 = dir:match('nvim[/\\]lua[/\\]lazyp[/\\]*$') or ''
	local m2 = dir:match('nvim[/\\]after[/\\]plugin[/\\]*$') or ''
	local m = m1..m2
	if m then
		require('oil').set_sort({ { 'type', 'asc' }, { 'mtime', 'desc' }})
	else
		require('oil').set_sort({ { 'type', 'asc' }, { 'name', 'asc' }, })
	end
end


F.sort_by_size = function ()
	require('oil').set_sort({ { 'size', 'desc' }})
end

F.sort_by_mtime = function ()
	-- require('oil').set_sort({ { 'type', 'asc' }, { 'mtime', 'desc' }})
	require('oil').set_sort({ { 'mtime', 'desc' }})
end

F.vlc_rar = function()
	local _, _, path = F.oil_entry_dir_path()
	os.execute(Join({
		'start',
		"A:\\bin\\7z-extract-tmp.bat",
		path:gsub("%.r%d%d", ".rar")
	}, ' '))
end

F.cd_to_entry = function()
	local _, _, path = F.oil_entry_dir_path()
	if not IsDir(path) then
		path = Dirname(path)
	end
	vim.cmd('cd ' .. path)
end

F.rate_on_movielens = function()
	local oil_entries = {}
	local ok, oil = pcall(require, 'oil')
	if ok then
		if VisualLine == vim.fn.mode() then
			local buf = vim.api.nvim_get_current_buf()
			local a, b = F.visual_line_range()
			for i = a, b do
				local m = F.entry_from_oil(oil.get_current_dir(), oil.get_entry_on_line(buf, i))
				table.insert(oil_entries, m)
			end
		else
			local m = F.entry_from_oil(oil.get_current_dir(), oil.get_cursor_entry())
			table.insert(oil_entries, m)
		end
	end
	if ok and #oil_entries > 0 then
		for _, e in pairs(oil_entries) do
			local name = StripSceneTags(e.name)
			F.open_in_browser('https://movielens.org/explore?q=' .. name)
		end
	end
end

F.oil_entry_dir_path = function()
	local entry = require('oil').get_cursor_entry()
	local dir = require('oil').get_current_dir()
	local path = JoinPaths(dir, entry.name)
	return entry, dir, path
end


local function escpath(p, qq)
	local q = '"'
	p = p:gsub("\"", "\\\"")

	if qq then return q .. p .. q end
	return p
end

local function executable(...)
	local paths = { ... }
	for _, path in pairs(paths) do
		if vim.fn.executable(path) then
			return path
		end
	end
	for _, path in pairs(paths) do
		return path
	end
	return ""
end

F.open_in_vlc = function()
	local _, _, path = F.oil_entry_dir_path()
	local vlc        = executable([[C:\Program Files\VideoLAN\VLC\vlc.exe]], 'vlc.exe', 'vlc')
	local cmd        = { 'start', '"play-file"', '/I',
		escpath(vlc, 1),
		escpath(path, 1) }
	local z          = Join(cmd, ' ')
	local e          = os.execute(z)
	if e ~= 0 then
		F.open_in_explorer()
	end
end


F.open_in_explorer = function()
	local _, _, path = F.oil_entry_dir_path()
	if IsDir(path) then
		os.execute('explorer.exe ' .. path)
	else
		os.execute('explorer.exe ' .. Dirname(path))
	end
end

F.open_via_shell = function()
	local get_open_cmd = function(path)
		if false then
		elseif 1 == vim.fn.has("mac") then
			return { "open", path }
		elseif 1 == vim.fn.executable("explorer.exe") then
			return { "explorer.exe", path }
		elseif 1 == vim.fn.executable("xdg-open") then
			return { "xdg-open", path }
		else
			return nil, "no handler found";
		end
	end
	local entry, dir, path = F.oil_entry_dir_path()
	if not entry or not dir then
		return
	end
	local cmd, err = get_open_cmd(path)
	if not cmd then
		vim.notify(string.format("Could not open %s: %s", path, err), vim.log.levels.ERROR)
		return
	end
	if IsDir(path) then
		os.execute(Join(cmd, ' ')) -- jobstart explorer does not work for some reason.
	else
		-- TODO use vim.ui.open once this is resolved
		-- https://github.com/neovim/neovim/issues/24567
		local jid = vim.fn.jobstart(cmd, { detach = false }) -- original is "true"
		assert(jid > 0, "Failed to start job")
	end
end


F.move_to_cat_delete = function()
	local pos = vim.api.nvim_win_get_cursor(0)
	F.MoveCat(function()
		-- move cursor back to where it was after reloading
		-- maybe there is oil-reload?
		vim.cmd([[edit ]] .. vim.fn.expand('%'))
		local timer = vim.loop.new_timer()
		timer:start(500, 0, vim.schedule_wrap(function()
			vim.api.nvim_win_set_cursor(0, pos)
		end))
	end, { default_text = "_del" })
end


F.move_to_cat = function()
	local pos = vim.api.nvim_win_get_cursor(0)
	F.MoveCat(function()
		-- move cursor back to where it was after reloading
		-- maybe there is oil-reload?
		vim.cmd([[edit ]] .. vim.fn.expand('%'))
		local timer = vim.loop.new_timer()
		timer:start(1000, 0, vim.schedule_wrap(function()
			vim.api.nvim_win_set_cursor(0, pos)
		end))
	end)
end

F.select_custom = function()
	local entry, _, _ = F.oil_entry_dir_path()
	local ext = Extensionname(entry.name)
	if false then
	elseif 'rar' == ext or ext:match('r[a%d][r%d]$') then
		vim.cmd [[ OilVlcRar ]]
	elseif IsVideoExtension(ext) then
		-- F.open_in_explorer()
		F.open_in_vlc() -- broken, must open in some special way
	elseif IsPictureExtension(ext) then
		F.open_in_explorer()
	else
		require('oil.actions').select.callback()
	end
end

F.get_oil_entries = function()
	local oil = require('oil')
	local d = oil.get_current_dir()
	local oil_entries = {}
	if VisualLine == vim.fn.mode() then
		local buf = vim.api.nvim_get_current_buf()
		local a, b = F.visual_line_range()
		for i = a, b do
			local m = F.entry_from_oil(d, oil.get_entry_on_line(buf, i))
			table.insert(oil_entries, m)
		end
		-- elseif VisualBlock == ...
	else
		local m = F.entry_from_oil(d, oil.get_cursor_entry())
		table.insert(oil_entries, m)
	end
	-- local meta_files = {}
	for _, e in pairs(oil_entries) do
		local stat = vim.loop.fs_stat(e.path)
		if stat ~= nil then
			local pat = e.path .. '*.{finished,torrent}'
			for _, mf in pairs(vim.fn.glob(pat, false, true)) do
				-- table.insert(meta_files, F.entry_from_path(mf))
				table.insert(oil_entries, F.entry_from_path(mf))
			end
		end
	end
	return oil_entries
end


F.entry_from_path = function(path)
	local dirname = vim.fn.fnamemodify(path:gsub('/$', ''), ':h')
	local basename = vim.fn.fnamemodify(path:gsub('/$', ''), ':t')
	local stat = vim.loop.fs_stat(path)
	return {
		dir = dirname,
		name = basename,
		path = JoinPaths(dirname, basename),
		stat = stat,
		size = stat.size,
		type = stat.type,
	}
end
F.entry_from_oil = function(d, e)
	return {
		dir = d,
		name = e.name,
		path = JoinPaths(d, e.name),
		stat = e.meta.stat,
		size = e.meta.stat.size,
		type = e.meta.stat.type,
	}
end

function F.visual_line_range()
	local v, c = vim.fn.line("v"), vim.fn.line(".")
	local a, b = v, c
	if c < v then
		a, b = c, v
	end
	return a, b
end

function F.open_in_browser(url)
	local cmd = { 'xdg-open', url }
	if vim.fn.executable('rundll32') == 1 then
		cmd = { 'rundll32', 'url.dll,FileProtocolHandler', url }
	end
	local jid = vim.fn.jobstart(cmd, { detach = false })
	assert(jid > 0, 'jobstart() err: ' .. vim.inspect(cmd))
end

function F.open_in_shell(url)
	local cmd = { 'xdg-open', url }
	if vim.fn.executable('rundll32') == 1 then
		cmd = { 'rundll32', 'shell32.dll,ShellExec_RunDLL', url }
	end
	local jid = vim.fn.jobstart(cmd, { detach = false })
	assert(jid > 0, 'jobstart() err: ' .. vim.inspect(cmd))
end

return F
