-- Markdown: show or hide the markup (`**`, `[]()`, backticks) through 'conceallevel'.
-- Registered per markdown buffer from after/ftplugin/markdown.vim, which also sets the start value.
local SRC = 'lua/genja/ext/md-conceal.lua: '

-- 'conceallevel' of the toggle's on state: 2 hides the markup without leaving a space
local ON = 2

local M = {}

---@param level integer
local function set(level)
	vim.wo.conceallevel = level
	vim.notify(SRC .. 'conceallevel ' .. level)
end

---0 shows all markup, ON hides it.
function M.toggle()
	if vim.wo.conceallevel == 0 then
		set(ON)
		return
	end
	set(0)
end

---Next level in 0 1 2 3, then back to 0.
function M.cycle()
	set((vim.wo.conceallevel + 1) % 4)
end

---@param buf integer
function M.register(buf)
	vim.keymap.set('n', '<leader>tmc', M.toggle, { buffer = buf, desc = 'Toggle: markdown conceal 0/' .. ON })

	local f2 = require('genja.f2')
	f2.add_task(f2.groups.markdown, 'conceal cycle')
		:fn(function() M.cycle() end)
		:buffer(buf)
		:add()
end

return M
