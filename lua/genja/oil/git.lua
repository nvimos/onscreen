-- git add / unstage the oil entries under the cursor or on the visual lines

local entry = require('genja.oil.entry')
local utils = require('genja.oil.utils')

local M = {}

local SRC = 'lua/genja/oil/git.lua: '

-- names of the entries under the cursor or on the visual lines;
-- raw oil entries: unsaved lines and '../' have no stat, so not entry_from_oil()
local function git_entry_names()
	local first = vim.fn.line('.')
	local last = first
	local visual = entry.VisualLine == vim.fn.mode()
	if visual then
		first, last = utils.visual_line_range()
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
		local found = vim.iter(indexed):any(function(path)
			return path == name or vim.startswith(path, name .. '/')
		end)
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
function M.refresh_oil_git()
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
	M.refresh_oil_git()
	if on_success then
		on_success(buf, dir, last)
	end
end

-- run `git <args> -- <entries>` in oil's dir, then after_git_change().
-- opts.on_success(buf, dir, last_lnum): follow-up after a success.
-- opts.tracked_only: skip untracked entries with a notice, as if they succeeded.
local function git_on_entries(args, label, opts)
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
			vim.notify(SRC .. label .. ': not in git, skipped: ' .. table.concat(untracked, ' '))
		end
		if #names == 0 then
			after_git_change(opts.on_success, buf, dir, last)
			return
		end
	end
	local cmd = vim.list_extend({ 'git' }, args)
	table.insert(cmd, '--')
	vim.list_extend(cmd, names) -- relative to dir, which is the cwd below

	vim.system(cmd, { cwd = dir, text = true }, vim.schedule_wrap(function(res)
		if res.code == 0 then
			vim.notify(SRC .. label .. ' ' .. table.concat(names, ' '))
			after_git_change(opts.on_success, buf, dir, last)
		else
			vim.notify(SRC .. label .. ' failed: ' .. vim.trim(res.stderr or ''), vim.log.levels.ERROR)
		end
	end))
end

M.git_add = function()
	git_on_entries({ 'add' }, 'git add', { on_success = jump_to_next_unstaged })
end

-- index only: `restore --staged` never touches the working tree
M.git_unstage = function()
	git_on_entries({ 'restore', '--staged' }, 'git unstage', { on_success = jump_to_next_unstaged, tracked_only = true })
end

return M
