-- sort the oil listing: fixed modes, cycling, per-dir default

local M = {}

local print_sort_by = function(tup) print('sort by ' .. vim.inspect(tup):gsub('[ {}"]', '')) end

-- BufEnter callback: mtime-first in a few config dirs, name-first elsewhere
M.sort_by_mtime_in_certain_paths = function()
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
M.dynamic_dir_sort = M.sort_by_mtime_in_certain_paths

local opp, mi, mo = false, 1, { { { 'name', 'asc' } }, { { 'mtime', 'desc' } }, { { 'size', 'desc' } } }

function M.toggle_asc_desc()
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

function M.cycle_sort_mode()
	mi = mi + 1
	if mi > #mo then mi = 1 end
	local tup = mo[mi]
	print_sort_by(tup)
	require 'oil'.set_sort(tup)
end

M.sort_by_name = function() require('oil').set_sort({ { 'type', 'asc' }, { 'name', 'asc' } }) end
M.sort_by_size = function() require('oil').set_sort({ { 'size', 'desc' } }) end
M.sort_by_mtime = function() require('oil').set_sort({ { 'mtime', 'desc' } }) end

return M
