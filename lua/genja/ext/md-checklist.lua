-- Markdown: turn lines into a checklist (`- [ ] `), or back when all are boxes (idea 34).
-- First caller of f2.add_task: registered per markdown buffer from after/ftplugin/markdown.lua.
-- Range: the selection when <F2> was pressed in visual mode (vim.b.f2_range), else the cursor line.
local SRC = 'lua/genja/ext/md-checklist.lua: '

local M = {}

---@param line string
---@return boolean
local function has_box(line)
	return line:match('^%s*[-*+] %[[ xX]%] ') ~= nil or line:match('^%s*%d+[.)] %[[ xX]%] ') ~= nil
end

---@param line string
---@return string
local function add_box(line)
	local indent, bullet, rest = line:match('^(%s*)([-*+]) (.*)$')
	if indent then
		return indent .. bullet .. ' [ ] ' .. rest
	end
	local nindent, num, nrest = line:match('^(%s*)(%d+[.)]) (.*)$')
	if nindent then
		return nindent .. num .. ' [ ] ' .. nrest
	end
	local lead, text = line:match('^(%s*)(.*)$')
	return lead .. '- [ ] ' .. text
end

---@param line string
---@return string
local function remove_box(line)
	local out = line:gsub('^(%s*[-*+] )%[[ xX]%] ', '%1', 1)
	out = out:gsub('^(%s*%d+[.)] )%[[ xX]%] ', '%1', 1)
	return out
end

--- Lines first..last (1-based): add `[ ]` to each non-blank line; if every
--- non-blank line has a box already, remove the boxes instead.
---@param first integer
---@param last integer
function M.toggle(first, last)
	if first > last then
		first, last = last, first
	end
	local lines = vim.api.nvim_buf_get_lines(0, first - 1, last, false)
	local text = vim.tbl_filter(function(line) return not line:match('^%s*$') end, lines)
	local all_boxed = vim.iter(text):all(has_box)
	if #text == 0 then
		vim.notify(SRC .. 'only blank lines, nothing to do')
		return
	end
	local out = {}
	for _, line in ipairs(lines) do
		if line:match('^%s*$') then
			table.insert(out, line)
		elseif all_boxed then
			table.insert(out, remove_box(line))
		elseif has_box(line) then
			table.insert(out, line)
		else
			table.insert(out, add_box(line))
		end
	end
	vim.api.nvim_buf_set_lines(0, first - 1, last, false, out)
end

--- <F2> task: the stored visual range, else the cursor line.
local function run()
	local range = vim.b.f2_range
	vim.b.f2_range = nil
	if range then
		M.toggle(range[1], range[2])
		return
	end
	local row = vim.fn.line('.')
	M.toggle(row, row)
end

---@param buf integer
function M.register(buf)
	require('genja.f2').add_task('md', 'checklist toggle')
		:fn(run)
		:buffer(buf)
		:add()
end

M._add_box = add_box
M._remove_box = remove_box

return M
