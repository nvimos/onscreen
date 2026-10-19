-- sort the oil listing: fixed modes, cycling, per-dir default

-- todo: generalize this. extract options into a config. sorting modes, paths to sort by time.
-- todo: consider adding .oily.sort for sorting options per dir, maybe put it all in .oily with a sort: prefix

local M = {}

local print_sort_by = function(sort_spec) print('sort by ' .. vim.inspect(sort_spec):gsub('[ {}"]', '')) end

-- BufEnter callback: mtime-first in a few config dirs, name-first elsewhere
M.sort_by_mtime_in_certain_paths = function()
	local dir = require('oil').get_current_dir() or ''
	local is_lua_dir = dir:match('nvim[/\\]lua[/\\]*$') ~= nil
	local is_lazyp_dir = dir:match('nvim[/\\]lua[/\\]lazyp[/\\]*$') ~= nil
	local is_after_plugin_dir = dir:match('nvim[/\\]after[/\\]plugin[/\\]*$') ~= nil
	local sort_spec = {}
	if is_lua_dir or is_lazyp_dir or is_after_plugin_dir then
		sort_spec = { { 'type', 'asc' }, { 'mtime', 'desc' } }
	else
		sort_spec = { { 'type', 'asc' }, { 'name', 'asc' } }
	end
	print_sort_by(sort_spec)
	require('oil').set_sort(sort_spec)
end
M.dynamic_dir_sort = M.sort_by_mtime_in_certain_paths

-- modes <F12> cycles through; toggle_asc_desc flips the current one in place
local sort_modes = { { { 'name', 'asc' } }, { { 'mtime', 'desc' } }, { { 'size', 'desc' } } }
local mode_index = 1

function M.toggle_asc_desc()
	local sort_spec = sort_modes[mode_index]
	if sort_spec[1][2] == 'asc' then
		sort_spec[1][2] = 'desc'
	elseif sort_spec[1][2] == 'desc' then
		sort_spec[1][2] = 'asc'
	end
	print_sort_by(sort_spec)
	require 'oil'.set_sort(sort_spec)
end

function M.cycle_sort_mode()
	mode_index = mode_index + 1
	if mode_index > #sort_modes then mode_index = 1 end
	local sort_spec = sort_modes[mode_index]
	print_sort_by(sort_spec)
	require 'oil'.set_sort(sort_spec)
end

M.sort_by_name = function() require('oil').set_sort({ { 'type', 'asc' }, { 'name', 'asc' } }) end
M.sort_by_size = function() require('oil').set_sort({ { 'size', 'desc' } }) end
M.sort_by_mtime = function() require('oil').set_sort({ { 'mtime', 'desc' } }) end

return M
