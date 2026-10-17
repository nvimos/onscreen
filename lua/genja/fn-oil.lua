-- vim: set foldmethod=marker foldlevel=0 foldnestmax=2 foldcolumn=2:

local VisualLine   = 'V'
local F            = {} -- functions

IsVideoExtension   = require('genja.fn').IsVideoExtension
IsPictureExtension = require('genja.fn').IsPictureExtension
Extensionname      = require('genja.fn').Extensionname
JoinPaths          = require('genja.fn').JoinPaths

-- {{{ util
local function escpath(p, qq)
	local q = '"'
	p = p:gsub("\"", "\\\"")
	if qq then return q .. p .. q end
	return p
end
--
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
-- }}}

-- {{{ sort listing options
local print_sort_by = function(tup) print('sort by ' .. vim.inspect(tup):gsub('[ {}"]', '')) end
F.sort_by_mtime_in_certain_paths = function()
	-- this is a callback for an autocommand
	local dir = require('oil').get_current_dir() or ''
	local m0 = dir:match('nvim[/\\]lua[/\\]*$') or ''
	local m1 = dir:match('nvim[/\\]lua[/\\]lazyp[/\\]*$') or ''
	local m2 = dir:match('nvim[/\\]after[/\\]plugin[/\\]*$') or ''
	local m = m0 .. m1 .. m2
	local tup = {}
	if m ~= '' then
		tup = { { 'type', 'asc' }, { 'mtime', 'desc' } }
	else
		tup = { { 'type', 'asc' }, { 'name', 'asc' } }
	end
	print_sort_by(tup)
	require('oil').set_sort(tup)
end
F.dynamic_dir_sort = F.sort_by_mtime_in_certain_paths
local opp, mi, mo = false, 1, { { { 'name', 'asc' } }, { { 'mtime', 'desc' } }, { { 'size', 'desc' } } }
function F.toggle_asc_desc()
	local tup = mo[mi]
	if tup[1][2] == 'asc' then
		tup[1][2] = 'desc'
	elseif tup[1][2] == 'desc' then
		tup[1][2] = 'asc'
	end
	opp = not opp
	print_sort_by(tup)
	require 'oil'.set_sort(tup)
end

function F.cycle_sort_mode()
	mi = mi + 1
	if mi > #mo then mi = 1 end
	local tup = mo[mi]
	print_sort_by(tup)
	require 'oil'.set_sort(tup)
end

F.sort_by_name = function() require('oil').set_sort({ { 'type', 'asc' }, { 'name', 'asc' } }) end
F.sort_by_size = function() require('oil').set_sort({ { 'size', 'desc' } }) end
F.sort_by_mtime = function() require('oil').set_sort({ { 'mtime', 'desc' } }) end
-- }}}

-- {{{ rate on movielens
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
-- }}}

-- {{{ open rar in vlc (extract)
F.vlc_rar = function()
	local _, _, path = F.oil_entry_dir_path()
	os.execute(Join({ 'start', "A:\\bin\\7z-extract-tmp.bat", path:gsub("%.r%d%d", ".rar") }, ' '))
end
-- }}}

-- {{{ open in vlc
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
-- }}}

-- {{{ open in browser
function F.open_in_browser(url)
	local cmd = { 'xdg-open', url }
	if vim.fn.executable('rundll32') == 1 then
		cmd = { 'rundll32', 'url.dll,FileProtocolHandler', url }
	end
	local jid = vim.fn.jobstart(cmd, { detach = false })
	assert(jid > 0, 'jobstart() err: ' .. vim.inspect(cmd))
end

-- }}}

-- {{{ open in shell
function F.open_in_shell(url)
	local cmd = { 'xdg-open', url }
	if vim.fn.executable('rundll32') == 1 then
		cmd = { 'rundll32', 'shell32.dll,ShellExec_RunDLL', url }
	end
	local jid = vim.fn.jobstart(cmd, { detach = false })
	assert(jid > 0, 'jobstart() err: ' .. vim.inspect(cmd))
end

-- }}}

-- {{{ open in explorer
F.open_in_explorer = function()
	local _, _, path = F.oil_entry_dir_path()
	if IsDir(path) then
		os.execute('explorer.exe ' .. path)
	else
		os.execute('explorer.exe ' .. Dirname(path))
	end
end
-- }}}

-- {{{ open via shell
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
-- }}}

-- {{{ undersort
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
-- }}}

-- {{{ open / select custom : rar, vlc, explorer

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
	local src = 'nvim/lua/genja/fn-oil.lua: '
	local dir = require('oil').get_current_dir()
	require('oil').save(nil, function(err)
		if err then
			if err ~= 'Canceled' then
				vim.notify(src .. err, vim.log.levels.ERROR)
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
			vim.notify(src .. 'saved, but cannot find ' .. typed_name, vim.log.levels.WARN)
		end
	end)
end

F.select_custom = function()
	local cursor_entry = require('oil').get_cursor_entry()
	if cursor_entry and cursor_entry.id == nil then
		save_then_select(cursor_entry.name) -- oil strips the trailing '/' of new dirs
		return
	end

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
-- }}}

-- {{{ preview: list snug to the longest name, preview gets the rest (at least 50%)
local name_to_preview_gap = 3

-- width of the widest listing line, without oil's concealed '/<id> ' prefix
local function widest_listing_line(buf)
	local widest = 0
	for _, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
		local visible_text = line:gsub('^/%d+ ', '')
		local width = vim.fn.strdisplaywidth(visible_text)
		widest = math.max(widest, width)
	end
	return widest
end

-- gutter (signs, numbers) + longest name + a little air before the preview
local function wanted_listing_width(oil_win)
	local oil_buf = vim.api.nvim_win_get_buf(oil_win)
	local gutter_width = vim.fn.getwininfo(oil_win)[1].textoff
	return gutter_width + widest_listing_line(oil_buf) + name_to_preview_gap
end

-- never more than half, so the preview keeps at least 50%
local function listing_width(oil_win, total_width)
	local half = math.floor(total_width / 2)
	return math.min(wanted_listing_width(oil_win), half)
end

local function fit_split(oil_win, preview_win)
	local total_width = vim.api.nvim_win_get_width(oil_win) + vim.api.nvim_win_get_width(preview_win)
	vim.api.nvim_win_set_width(oil_win, listing_width(oil_win, total_width))
end

-- oil places the floats side by side with float.padding between them
local function fit_float(oil_win, preview_win)
	local oil_cfg = vim.api.nvim_win_get_config(oil_win)
	local preview_cfg = vim.api.nvim_win_get_config(preview_win)
	local stacked = oil_cfg.row ~= preview_cfg.row
	if stacked then
		return -- above/below, width does not matter
	end

	local left_cfg = oil_cfg
	local right_cfg = preview_cfg
	if preview_cfg.col < oil_cfg.col then
		left_cfg = preview_cfg
		right_cfg = oil_cfg
	end
	local padding = right_cfg.col - (left_cfg.col + left_cfg.width)
	local total_width = oil_cfg.width + preview_cfg.width

	oil_cfg.width = listing_width(oil_win, total_width)
	preview_cfg.width = total_width - oil_cfg.width
	right_cfg.col = left_cfg.col + left_cfg.width + padding

	vim.api.nvim_win_set_config(oil_win, oil_cfg)
	vim.api.nvim_win_set_config(preview_win, preview_cfg)
end

local function fit_preview(oil_win, preview_win)
	local is_float = vim.api.nvim_win_get_config(oil_win).relative ~= ''
	if is_float then
		fit_float(oil_win, preview_win)
	else
		fit_split(oil_win, preview_win)
	end
end

local function is_previewing(entry)
	local preview_win = require('oil.util').get_preview_win()
	if not preview_win then
		return false
	end
	return vim.w[preview_win].oil_entry_id == entry.id
end

F.toggle_preview_fit = function()
	local oil = require('oil')
	local entry = oil.get_cursor_entry()
	if not entry or is_previewing(entry) then
		require('oil.actions').preview.callback() -- closes it
		return
	end

	local oil_win = vim.api.nvim_get_current_win()
	oil.open_preview({}, function(err)
		if err then
			return
		end
		local preview_win = require('oil.util').get_preview_win()
		if not preview_win or not vim.api.nvim_win_is_valid(oil_win) then
			return
		end
		fit_preview(oil_win, preview_win)
	end)
end
-- }}}

-- {{{ git add / unstage
-- names of the entries under the cursor or on the visual lines;
-- raw oil entries: unsaved lines and '../' have no stat, so not entry_from_oil()
local function git_entry_names()
	local first = vim.fn.line('.')
	local last = first
	local visual = VisualLine == vim.fn.mode()
	if visual then
		first, last = F.visual_line_range()
	end
	local names = {}
	for lnum = first, last do
		local e = require('oil').get_entry_on_line(0, lnum)
		if e and e.id and e.name ~= '..' then -- id nil: typed but not saved yet
			table.insert(names, e.name)
		end
	end
	if visual then
		vim.api.nvim_feedkeys(vim.keycode('<Esc>'), 'n', false)
	end
	return names, last
end

-- top-level names in `dir` with unstaged changes or untracked files;
-- a dir counts when anything under it does. Calls on_done(set) on the main loop.
local function unstaged_names(dir, on_done)
	vim.system({ 'git', 'rev-parse', '--show-prefix' }, { cwd = dir, text = true }, function(prefix_res)
		if prefix_res.code ~= 0 then
			return
		end
		local prefix = vim.trim(prefix_res.stdout) -- dir relative to the repo root, e.g. 'lua/genja/'
		local status_cmd = { 'git', 'status', '--porcelain=v1', '-z' }
		vim.system(status_cmd, { cwd = dir, text = true }, vim.schedule_wrap(function(res)
			if res.code ~= 0 then
				return
			end
			local set = {}
			local fields = vim.split(res.stdout, '\0', { plain = true })
			local i = 1
			while i <= #fields do
				local field = fields[i]
				local x = field:sub(1, 1)
				local y = field:sub(2, 2)
				local path = field:sub(4) -- porcelain paths are relative to the repo root
				local is_unstaged = y ~= ' ' and y ~= '!' and y ~= ''
				if is_unstaged and vim.startswith(path, prefix) then
					local top = vim.split(path:sub(#prefix + 1), '/', { plain = true })[1]
					set[top] = true
				end
				if x == 'R' or x == 'C' then
					i = i + 1 -- skip the original path of a rename/copy
				end
				i = i + 1
			end
			on_done(set)
		end))
	end)
end

-- move the cursor to the next entry below `after_lnum` with unstaged changes, wrapping
local function jump_to_next_unstaged(buf, dir, after_lnum)
	unstaged_names(dir, function(set)
		if vim.api.nvim_get_current_buf() ~= buf then
			return -- user left the oil buffer meanwhile
		end
		local count = vim.api.nvim_buf_line_count(buf)
		for step = 1, count do
			local lnum = (after_lnum + step - 1) % count + 1
			local e = require('oil').get_entry_on_line(buf, lnum)
			if e and set[e.name] then
				vim.api.nvim_win_set_cursor(0, { lnum, 0 })
				return
			end
		end
	end)
end

-- split names into those in git's index and the rest (untracked);
-- a dir is in the index when any file under it is
local function split_tracked(dir, names)
	local cmd = { 'git', 'ls-files', '-z', '--' } -- paths relative to cwd
	vim.list_extend(cmd, names)
	local res = vim.system(cmd, { cwd = dir, text = true }):wait()
	if res.code ~= 0 then
		return names, {} -- let the real command report the problem
	end
	local indexed = vim.split(res.stdout, '\0', { plain = true, trimempty = true })
	local tracked = {}
	local untracked = {}
	for _, name in ipairs(names) do
		local found = false
		for _, path in ipairs(indexed) do
			if path == name or vim.startswith(path, name .. '/') then
				found = true
				break
			end
		end
		if found then
			table.insert(tracked, name)
		else
			table.insert(untracked, name)
		end
	end
	return tracked, untracked
end

-- oil-git caches git status for 500 ms and refresh() reuses it; drop the cache
-- first (as oil-git does on its own events) so the symbols show this change.
-- oil-git.git is internal, hence the checks. Skipped when oil-git isn't installed.
local function refresh_oil_git()
	local ok, oil_git = pcall(require, 'oil-git')
	if not ok then
		return
	end
	local ok_git, git = pcall(require, 'oil-git.git')
	if ok_git and git.invalidate_cache then
		git.invalidate_cache()
	end
	oil_git.refresh()
end

-- refresh oil-git's symbols, then run the follow-up (e.g. cursor jump)
local function after_git_change(on_success, buf, dir, last)
	refresh_oil_git()
	if on_success then
		on_success(buf, dir, last)
	end
end

-- run `git <args> -- <entries>` in oil's dir, then after_git_change().
-- opts.on_success(buf, dir, last_lnum): follow-up after a success.
-- opts.tracked_only: skip untracked entries with a notice, as if they succeeded.
local function git_on_entries(args, label, opts)
	local src = 'nvim/lua/genja/fn-oil.lua: '
	local dir = require('oil').get_current_dir()
	if not dir then
		return
	end
	local buf = vim.api.nvim_get_current_buf()
	local names, last = git_entry_names()
	if #names == 0 then
		return
	end
	if opts.tracked_only then
		local untracked
		names, untracked = split_tracked(dir, names)
		if #untracked > 0 then
			vim.notify(src .. label .. ': not in git, skipped: ' .. table.concat(untracked, ' '))
		end
		if #names == 0 then
			after_git_change(opts.on_success, buf, dir, last)
			return
		end
	end
	local cmd = { 'git' }
	vim.list_extend(cmd, args)
	table.insert(cmd, '--')
	vim.list_extend(cmd, names) -- relative to dir, which is the cwd below

	vim.system(cmd, { cwd = dir, text = true }, vim.schedule_wrap(function(res)
		if res.code == 0 then
			vim.notify(src .. label .. ' ' .. table.concat(names, ' '))
			after_git_change(opts.on_success, buf, dir, last)
		else
			vim.notify(src .. label .. ' failed: ' .. vim.trim(res.stderr or ''), vim.log.levels.ERROR)
		end
	end))
end

F.git_add = function()
	git_on_entries({ 'add' }, 'git add', { on_success = jump_to_next_unstaged })
end

-- index only: `restore --staged` never touches the working tree
F.git_unstage = function()
	git_on_entries({ 'restore', '--staged' }, 'git unstage', { on_success = jump_to_next_unstaged, tracked_only = true })
end
-- }}}

-- {{{ .oily: per-project hidden entries
-- <pwd>/.oily lists what oil hides (oil's g. still shows everything), one per line:
--   node_modules         a bare name: hidden in every directory
--   lua/lazyp/unused     a path: relative to the .oily dir (or absolute), hides that entry
--   *.log                a bare glob: matched against names in every directory
--   lua/**/zold*         a glob with '/': matched against the path relative to the .oily dir
--   # comment
-- Globs use vim.glob syntax (* ? ** [abc] {a,b}) and must match the whole name/path.
-- Dotfiles stay hidden as in oil's default. <LocalLeader>M appends the entry's path.

local oily_cache = {} -- .oily path -> parsed rules, see read_oily()

-- comparable path: forward slashes, no trailing slash, lowercase on Windows
local function oily_key(path)
	local key = vim.fs.normalize(path)
	if vim.fn.has('win32') == 1 then
		key = key:lower()
	end
	return key
end

local function oily_file()
	return vim.fs.joinpath(vim.fn.getcwd(), '.oily')
end

local function has_glob(line)
	return line:find('[%*%?%[{]') ~= nil
end

-- parsed .oily, re-read when its mtime changes; nil when there is none
local function read_oily(file)
	local stat = vim.uv.fs_stat(file)
	if not stat then
		oily_cache[file] = nil
		return nil
	end
	local mtime = stat.mtime.sec .. '.' .. stat.mtime.nsec
	local cached = oily_cache[file]
	if cached and cached.mtime == mtime then
		return cached
	end

	local base = vim.fs.dirname(file)
	local rules = {
		mtime = mtime,
		base = oily_key(base),
		names = {},      -- exact names, any dir
		paths = {},      -- exact absolute paths
		name_globs = {}, -- matched against the name
		rel_globs = {},  -- matched against the path relative to base
		abs_globs = {},  -- matched against the absolute path
	}
	for lnum, line in ipairs(vim.fn.readfile(file)) do
		line = vim.trim(line):gsub('/+$', '')
		if line ~= '' and not vim.startswith(line, '#') then
			local is_absolute = line:match('^%a:') or vim.startswith(line, '/')
			local is_path = line:find('/', 1, true) ~= nil
			if has_glob(line) then
				local ok, glob = pcall(vim.glob.to_lpeg, oily_key(line))
				if not ok then
					vim.notify('nvim/lua/genja/fn-oil.lua: bad glob in ' .. file .. ':' .. lnum .. ': ' .. line,
						vim.log.levels.WARN)
				elseif is_absolute then
					table.insert(rules.abs_globs, glob)
				elseif is_path then
					table.insert(rules.rel_globs, glob)
				else
					table.insert(rules.name_globs, glob)
				end
			elseif is_absolute then
				rules.paths[oily_key(line)] = true
			elseif is_path then
				rules.paths[oily_key(vim.fs.joinpath(base, line))] = true
			else
				rules.names[oily_key(line)] = true
			end
		end
	end
	oily_cache[file] = rules
	return rules
end

local function any_glob_matches(globs, subject)
	for _, glob in ipairs(globs) do
		if glob:match(subject) then
			return true
		end
	end
	return false
end

---view_options.is_hidden_file for oil
---@param name string
---@param bufnr integer
---@return boolean
F.is_hidden_file = function(name, bufnr)
	if vim.startswith(name, '.') then
		return true -- oil's default
	end
	local rules = read_oily(oily_file())
	if not rules then
		return false
	end

	local name_key = oily_key(name)
	if rules.names[name_key] or any_glob_matches(rules.name_globs, name_key) then
		return true
	end

	local dir = require('oil').get_current_dir(bufnr)
	if not dir then
		return false
	end
	local full = oily_key(vim.fs.joinpath(dir, name))
	if rules.paths[full] or any_glob_matches(rules.abs_globs, full) then
		return true
	end
	local prefix = rules.base .. '/'
	if vim.startswith(full, prefix) then
		return any_glob_matches(rules.rel_globs, full:sub(#prefix + 1))
	end
	return false
end

-- <LocalLeader>M: hide the entry (or visual lines) by adding its path to .oily
F.oily_hide = function()
	local src = 'nvim/lua/genja/fn-oil.lua: '
	local dir = require('oil').get_current_dir()
	if not dir then
		return
	end
	local names = git_entry_names() -- saved entries under the cursor / visual lines
	if #names == 0 then
		return
	end

	local file = oily_file()
	local base = vim.fs.normalize(vim.fs.dirname(file))
	local lines = {}
	for _, name in ipairs(names) do
		local path = vim.fs.normalize(vim.fs.joinpath(dir, name))
		local line = path -- absolute when outside the .oily dir
		if oily_key(path):sub(1, #base + 1) == oily_key(base) .. '/' then
			line = path:sub(#base + 2)
		end
		table.insert(lines, line)
	end
	vim.fn.writefile(lines, file, 'a') -- creates the file if needed
	vim.notify(src .. 'hidden via ' .. file .. ': ' .. table.concat(lines, ' '))
	require('oil').set_is_hidden_file(F.is_hidden_file) -- re-render with the new rules
end
-- }}}

-- {{{ oil entry
F.cd_to_entry = function()
	local _, _, path = F.oil_entry_dir_path()
	if not IsDir(path) then
		path = Dirname(path)
	end
	vim.cmd('cd ' .. path)
end

F.oil_entry_dir_path = function()
	local entry = require('oil').get_cursor_entry()
	local dir = require('oil').get_current_dir()
	local path = JoinPaths(dir, entry.name)
	return entry, dir, path
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

-- }}}

return F
