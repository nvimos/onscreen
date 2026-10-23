-- vim: set foldmethod=marker foldlevel=1 foldnestmax=2 foldcolumn=2:

-- open oil entries outside nvim: explorer, shell, browser, vlc, rar

local SRC = 'lua/genja/oil/open.lua: '

local G = require('genja.oil.globals')
local entry = require('genja.oil.entry')
local utils = require('genja.oil.utils')

local M = {}

-- {{{ util
-- first of the paths that is executable; else the first one, so the caller's
-- command fails with that name
local function executable(...)
	local paths = { ... }
	for _, path in ipairs(paths) do
		if vim.fn.executable(path) == 1 then
			return path
		end
	end
	if #paths > 0 then
		return paths[1]
	end
	return ""
end
-- }}}

-- {{{ open in browser
function M.open_in_browser(url)
	local cmd = { 'xdg-open', url }
	if vim.fn.executable('rundll32') == 1 then
		cmd = { 'rundll32', 'url.dll,FileProtocolHandler', url }
	end
	local jid = vim.fn.jobstart(cmd, { detach = false })
	assert(jid > 0, 'jobstart() err: ' .. vim.inspect(cmd))
end
-- }}}

-- {{{ open in shell
function M.open_in_shell(url)
	local cmd = { 'xdg-open', url }
	if vim.fn.executable('rundll32') == 1 then
		cmd = { 'rundll32', 'shell32.dll,ShellExec_RunDLL', url }
	end
	local jid = vim.fn.jobstart(cmd, { detach = false })
	assert(jid > 0, 'jobstart() err: ' .. vim.inspect(cmd))
end
-- }}}

-- {{{ open in explorer
M.open_in_explorer = function()
	local _, _, path = utils.oil_entry_dir_path()
	if not path then
		return
	end
	if G.IsDir(path) then
		os.execute('explorer.exe ' .. path)
	else
		os.execute('explorer.exe ' .. G.Dirname(path))
	end
end
-- }}}

-- {{{ open via shell
M.open_via_shell = function()
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
	local e, dir, path = utils.oil_entry_dir_path()
	if not e or not dir then
		return
	end
	local cmd, err = get_open_cmd(path)
	if not cmd then
		vim.notify(string.format(SRC .. "could not open %s: %s", path, err), vim.log.levels.ERROR)
		return
	end
	if G.IsDir(path) then
		-- jobstart explorer does not work for some reason. os.execute goes through
		-- cmd.exe, which is 'shell' too, so shellescape quotes paths with spaces
		os.execute(cmd[1] .. ' ' .. vim.fn.shellescape(path))
	else
		-- https://github.com/neovim/neovim/issues/24567 ("vim.system(xdg-open) fails
		-- but jobstart succeeds"): closed as completed 2024-04-23. Linux/xdg-open
		-- only; on Windows vim.ui.open now runs `cmd.exe /c start "" <path>`.
		-- Oil's gx (actions.open_external) already uses vim.ui.open.
		local jid = vim.fn.jobstart(cmd, { detach = false }) -- original is "true"
		assert(jid > 0, "Failed to start job")
	end
end
-- }}}

-- {{{ rate on movielens
M.rate_on_movielens = function()
	local oil_entries = {}
	local ok, oil = pcall(require, 'oil')
	if ok then
		if entry.VisualLine == vim.fn.mode() then
			local buf = vim.api.nvim_get_current_buf()
			local a, b = utils.visual_line_range()
			for i = a, b do
				local m = entry.entry_from_oil(oil.get_current_dir(), oil.get_entry_on_line(buf, i))
				table.insert(oil_entries, m)
			end
		else
			local m = entry.entry_from_oil(oil.get_current_dir(), oil.get_cursor_entry())
			table.insert(oil_entries, m)
		end
	end
	if ok and #oil_entries > 0 then
		for _, e in pairs(oil_entries) do
			local name = G.StripSceneTags(e.name)
			M.open_in_browser('https://movielens.org/explore?q=' .. name)
		end
	end
end
-- }}}

-- {{{ open rar in vlc (extract)
M.vlc_rar = function()
	local _, _, path = utils.oil_entry_dir_path()
	if not path then
		return
	end
	os.execute(G.Join({ 'start', "A:\\bin\\7z-extract-tmp.bat", path:gsub("%.r%d%d", ".rar") }, ' '))
end
-- }}}

-- {{{ open in vlc
M.open_in_vlc = function()
	local _, _, path = utils.oil_entry_dir_path()
	if not path then
		return
	end
	local vlc        = executable([[C:\Program Files\VideoLAN\VLC\vlc.exe]], 'vlc.exe', 'vlc')
	-- 'shell' is cmd.exe, which os.execute uses too, so shellescape quotes with "..."
	local cmd        = { 'start', '"play-file"', '/I',
		vim.fn.shellescape(vlc),
		vim.fn.shellescape(path) }
	local z          = G.Join(cmd, ' ')
	local e          = os.execute(z)
	if e ~= 0 then
		M.open_in_explorer()
	end
end
-- }}}

-- {{{ select custom: rar, vlc, explorer, else oil's select

-- line of the entry called `name` in the current oil buffer
local function find_entry_line(name)
	local oil = require('oil')
	for lnum = 1, vim.api.nvim_buf_line_count(0) do
		local e = oil.get_entry_on_line(0, lnum)
		if e and e.id and e.name == name then -- id: skip a stale, unsaved typed line
			return lnum
		end
	end
	return nil
end

-- A typed, unsaved entry: save, then open it. Oil's own select would ask
-- "Save changes?" and then not open it. save() with confirm=nil respects
-- skip_confirm_for_simple_edits, so deletes etc. still show the popup.
-- The entry is found again by name: saving re-sorts the listing.
local function save_then_select(typed_name)
	local dir = require('oil').get_current_dir()
	require('oil').save(nil, function(err)
		if err then
			if err ~= 'Canceled' then
				vim.notify(SRC .. err, vim.log.levels.ERROR)
			end
			return
		end

		-- cursor on the new entry, so going back to oil lands there;
		-- 'a/b/c.txt' creates nested entries and the listing shows only 'a'
		local listed_name = vim.split(typed_name, '/', { plain = true })[1]
		local lnum = find_entry_line(listed_name)
		if lnum then
			vim.api.nvim_win_set_cursor(0, { lnum, 0 })
		end

		-- open by path, not by cursor line: doesn't depend on sorting or render timing
		local path = dir .. typed_name
		if vim.fn.isdirectory(path) == 1 then
			require('oil').open(path)
		elseif vim.fn.filereadable(path) == 1 then
			if vim.w.is_oil_win then
				require('oil').close() -- like oil's select: leave the float before opening a file
			end
			vim.cmd.edit(vim.fn.fnameescape(path))
		else
			vim.notify(SRC .. 'saved, but cannot find ' .. typed_name, vim.log.levels.WARN)
		end
	end)
end

M.select_custom = function()
	local cursor_entry = require('oil').get_cursor_entry()
	if cursor_entry and cursor_entry.id == nil then
		save_then_select(cursor_entry.name) -- oil strips the trailing '/' of new dirs
		return
	end

	local e, _, _ = utils.oil_entry_dir_path()
	if not e then
		return
	end
	local ext = G.Extensionname(e.name)
	if false then
	elseif 'rar' == ext or ext:match('r[a%d][r%d]$') then
		vim.cmd [[ OilVlcRar ]]
	elseif G.IsVideoExtension(ext) then
		-- M.open_in_explorer()
		M.open_in_vlc() -- broken, must open in some special way
	elseif G.IsPictureExtension(ext) then
		M.open_in_explorer()
	else
		require('oil.actions').select.callback()
	end
end
-- }}}

return M
