-- Markdown: bare http(s) URLs become inline links, `https://x.org/a/b?q=1` -> `[a/b](https://x.org/a/b?q=1)`.
-- The name is the URL's path without query or fragment; a path longer than NAME_MAX keeps only its
-- last part, no path at all gives the host. URLs already in a link, in <...> or in `code` stay.
-- <F2> task `inline links from urls`, registered per markdown buffer from after/ftplugin/markdown.vim.
-- Range: the selection when <F2> was pressed in visual mode (vim.b.f2_range), else the cursor line.
local SRC = 'lua/genja/ext/md-links.lua: '

local M = {}

local NAME_MAX = 60

-- characters a bare URL runs over; parens and brackets end it, so `](url)` is never taken apart
local URL = 'https?://[^%s<>%[%]()`"\']+'

---Link name for `url`: the decoded path, its last part when longer than NAME_MAX, else the host.
---@param url string
---@return string
function M.name(url)
	local rest = url:gsub('^https?://', '')
	local host, path = rest:match('^([^/?#]*)(.*)$')
	path = path:gsub('[?#].*$', ''):gsub('/+$', ''):gsub('^/+', '')
	if path == '' then
		return host
	end
	path = vim.uri_decode(path)
	if #path > NAME_MAX then
		path = path:match('([^/]+)$') or path
	end
	return path
end

---Convert the bare URLs in text that is not inside backticks.
---@param text string
---@return string
local function convert(text)
	local out = {}
	local pos = 1
	while true do
		local s, e = text:find(URL, pos)
		if not s then
			break
		end
		local url = text:sub(s, e)
		local trail = url:match('[.,;:!?]+$') or ''
		url = url:sub(1, #url - #trail)
		local before = text:sub(math.max(1, s - 2), s - 1)
		local last = before:sub(-1)
		if before == '](' or last == '<' or last == '[' then
			table.insert(out, text:sub(pos, e)) -- already a link, an autolink or link text
		else
			table.insert(out, text:sub(pos, s - 1) .. '[' .. M.name(url) .. '](' .. url .. ')' .. trail)
		end
		pos = e + 1
	end
	table.insert(out, text:sub(pos))
	return table.concat(out)
end

---One line: the parts between backticks (odd parts after a split) stay as they are.
---@param line string
---@return string
function M.link_line(line)
	local parts = vim.split(line, '`', { plain = true })
	for i = 1, #parts, 2 do
		parts[i] = convert(parts[i])
	end
	return table.concat(parts, '`')
end

---Lines first..last (1-based) of the current buffer; code fences are skipped.
---@param first integer
---@param last integer
function M.convert_range(first, last)
	if first > last then
		first, last = last, first
	end
	local lines = vim.api.nvim_buf_get_lines(0, first - 1, last, false)
	local in_fence = false
	local changed = 0
	for i, line in ipairs(lines) do
		if line:match('^%s*```') or line:match('^%s*~~~') then
			in_fence = not in_fence
		elseif not in_fence then
			local new = M.link_line(line)
			if new ~= line then
				lines[i] = new
				changed = changed + 1
			end
		end
	end
	if changed == 0 then
		vim.notify(SRC .. 'no bare URLs in the range')
		return
	end
	vim.api.nvim_buf_set_lines(0, first - 1, last, false, lines)
end

--- <F2> task: the stored visual range, else the cursor line.
local function run()
	local range = vim.b.f2_range
	vim.b.f2_range = nil
	if range then
		M.convert_range(range[1], range[2])
		return
	end
	local row = vim.fn.line('.')
	M.convert_range(row, row)
end

---@param buf integer
function M.register(buf)
	local f2 = require('genja.f2')
	f2.add_task(f2.groups.markdown, 'inline links from urls')
		:fn(run)
		:buffer(buf)
		:add()
end

return M
