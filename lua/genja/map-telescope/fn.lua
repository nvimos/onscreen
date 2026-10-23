-- Functions bound in lua/genja/map-telescope.lua.
-- Each requires its plugin on call, so loading this file loads nothing.

local M = {}

-- in oil: scan oil's directory instead of :pwd (an oil buffer has no file for 'bufdir')
---@return table|nil
local function oil_dir_opts()
	if vim.bo.filetype ~= 'oil' then
		return nil
	end
	local dir = require('oil').get_current_dir()
	if not dir then
		return nil
	end
	return { cwd = dir }
end

function M.find_in_startdirs()
	require('telescope.builtin').find_files({
		hidden = false,
		search_dirs = require('genja-startdirs').dirs(),
	})
end

function M.genja_finder_grep() require('genja-finder').live_grep(oil_dir_opts()) end
function M.genja_finder_find() require('genja-finder').live_find(oil_dir_opts()) end

function M.grep_string()
	require('telescope.builtin').grep_string({ search = vim.fn.input('Grep: ') })
end

-- oldfiles with genja-finder's shared keys (<M-f> filter, <F2>/<F3>)
function M.oldfiles()
	require('genja-finder').enhance(require('telescope.builtin').oldfiles)()
end

function M.context_picker()
	vim.b.f2_range = nil -- a range only comes from visual <F2>
	require('genja.f2').open()
end

-- visual <F2>: tasks read the selected lines from vim.b.f2_range (e.g. md-checklist)
function M.context_picker_visual()
	local first = vim.fn.line('v')
	local last = vim.fn.line('.')
	if first > last then
		first, last = last, first
	end
	vim.api.nvim_feedkeys(vim.keycode('<Esc>'), 'nx', false)
	vim.b.f2_range = { first, last }
	require('genja.f2').open()
end
function M.action_menu() require('genja.actions').open() end

return M
