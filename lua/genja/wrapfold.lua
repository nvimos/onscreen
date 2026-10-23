-- Wrap lines in fold markers with a title: `-- {{{ title` … `-- }}}`.
-- Port of WrapFold from vimrc.almalinux.vim (idea 29b). Keys in map-zero.lua (Folds).
local SRC = 'lua/genja/wrapfold.lua: '

local M = {}

---@return string prefix, string suffix comment parts around the marker, trimmed
local function comment_parts()
	local cs = vim.bo.commentstring
	if cs == '' or not cs:find('%s', 1, true) then
		return '#', ''
	end
	local left, right = cs:match('^(.-)%%s(.-)$')
	left = vim.trim(left)
	right = vim.trim(right)
	return left, right
end

---@param prefix string
---@param body string
---@param suffix string
---@return string
local function comment_line(prefix, body, suffix)
	local line = prefix .. ' ' .. body
	if suffix ~= '' then
		line = line .. ' ' .. suffix
	end
	return line
end

--- Insert the markers around lines first..last (1-based, inclusive).
---@param first integer
---@param last integer
---@param title string
function M.wrap(first, last, title)
	if first > last then
		first, last = last, first
	end
	local prefix, suffix = comment_parts()
	local indent = vim.fn.getline(first):match('^%s*')
	local open = indent .. comment_line(prefix, '{{{ ' .. title, suffix)
	local close = indent .. comment_line(prefix, '}}}', suffix)
	-- the closing line first, so `first` stays valid
	vim.api.nvim_buf_set_lines(0, last, last, false, { close })
	vim.api.nvim_buf_set_lines(0, first - 1, first - 1, false, { open })
	if vim.wo.foldmethod ~= 'marker' and not vim.b.wrapfold_noted then
		vim.b.wrapfold_noted = true
		vim.notify(SRC .. "markers added; they fold with 'foldmethod' marker (now " .. vim.wo.foldmethod .. ')')
	end
end

--- Ask for a title, then wrap. Empty title: built-in :fold. Cancel: nothing.
---@param first integer
---@param last integer
function M.ask(first, last)
	vim.ui.input({ prompt = 'Fold title: ' }, function(title)
		if title == nil then
			return
		end
		if vim.trim(title) == '' then
			vim.cmd(string.format('%d,%dfold', math.min(first, last), math.max(first, last)))
			return
		end
		M.wrap(first, last, vim.trim(title))
	end)
end

--- Visual mode: the selected lines.
function M.visual()
	local first = vim.fn.line('v')
	local last = vim.fn.line('.')
	vim.api.nvim_feedkeys(vim.keycode('<Esc>'), 'nx', false)
	M.ask(first, last)
end

--- Normal mode: the paragraph under the cursor (like `vip`).
function M.paragraph()
	local row = vim.fn.line('.')
	if vim.fn.getline(row):match('^%s*$') then
		vim.notify(SRC .. 'cursor is on a blank line, no paragraph')
		return
	end
	local first = row
	while first > 1 and not vim.fn.getline(first - 1):match('^%s*$') do
		first = first - 1
	end
	local last = row
	local max = vim.fn.line('$')
	while last < max and not vim.fn.getline(last + 1):match('^%s*$') do
		last = last + 1
	end
	M.ask(first, last)
end

--- :[range]WrapFold [title]
function M.setup_command()
	vim.api.nvim_create_user_command('WrapFold', function(o)
		if o.args == '' then
			M.ask(o.line1, o.line2)
			return
		end
		M.wrap(o.line1, o.line2, o.args)
	end, { range = true, nargs = '*', desc = 'Fold: wrap range in {{{ title / }}} markers' })
end

return M
