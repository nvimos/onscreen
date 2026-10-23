-- Start screen with the :Morning sections (idea 30/31), kept as an alternative to :Morning
-- (lua/genja/morning.lua). Disabled: set enabled = true to try it; it shows when nvim
-- starts without file arguments, or with :lua MiniStarter.open().
-- Upstream moved from echasnovski/mini.starter to nvim-mini/mini.starter.

local MAX = 10

---Items for one section: name, action and section, as mini.starter wants them.
---@param section string
---@param paths string[]
---@param action fun(path: string): string|fun()
---@return table[]
local function items(section, paths, action)
	local list = {}
	for i = 1, math.min(MAX, #paths) do
		local path = paths[i]
		table.insert(list, { name = vim.fn.fnamemodify(path, ':~'), action = action(path), section = section })
	end
	return list
end

local function start_dirs()
	local ok, sd = pcall(require, 'genja-startdirs')
	if not ok then
		return {}
	end
	return items('Start dirs', sd.ranked(), function(dir)
		return 'cd ' .. vim.fn.fnameescape(dir) .. ' | Oil ' .. vim.fn.fnameescape(dir)
	end)
end

local function recent()
	local ok, rc = pcall(require, 'genja-recent')
	local paths = vim.v.oldfiles
	if ok then
		paths = rc.list()
	end
	return items('Recent', paths, function(file) return 'edit ' .. vim.fn.fnameescape(file) end)
end

---@type LazySpec
return {
	'nvim-mini/mini.starter',
	enabled = false, -- not used: 2026-10 (:Morning instead; kept to compare)
	event = 'VimEnter',
	opts = function()
		local starter = require('mini.starter')
		local config = vim.fn.stdpath('config')
		return {
			header = 'Morning',
			items = {
				start_dirs,
				recent,
				{ name = 'todo-ideas.md', action = 'edit ' .. config .. '/todo-ideas.md', section = 'Todo' },
				{ name = 'untested list', action = 'Morning', section = 'Todo' },
				starter.sections.builtin_actions(),
			},
			footer = ':Morning has the same sections, with todo items and untested lines',
		}
	end,
}
