-- :Morning (idea 30/31): a clickable page for lazy mornings and planning sessions.
--   Sections: Start dirs (genja-startdirs, most used first), Recent (genja-recent, else oldfiles),
--   Todo (open Backlog.md tasks of the nvimos/meta checkout), Untested (open lines of the newest doc-wip/untested.*.md).
--   A click or <CR> opens the line's target; q closes. Command in plugin/morning.lua,
--   also in the right-click menu (lua/genja/popup.lua).

local SRC = 'lua/genja/ext/morning.lua: '

local M = {}

local RECENT_MAX = 12
local CONFIG = vim.fs.normalize(vim.fn.stdpath('config'))

-- The backlog lives in the planning repo github.com/nvimos/meta (Backlog.md tasks); its checkout:
-- vim.g.genja_meta_dir, else ~/es/nvimos-meta.
local META_ORDER = { ['In Progress'] = 1, ['Needs Test'] = 2, ['To Do'] = 3 }

---Open Backlog.md tasks of the meta checkout: in progress, needs test, to do.
---@return { status: string, title: string, path: string }[] tasks
---@return string dir the meta checkout
local function meta_tasks()
	local dir = vim.fs.normalize(vim.g.genja_meta_dir or '~/es/nvimos-meta')
	local tasks = {}
	for _, path in ipairs(vim.fn.glob(dir .. '/backlog/tasks/*.md', false, true)) do
		-- the header is in the first lines; an unreadable file is left out
		local ok, head_lines = pcall(vim.fn.readfile, path, '', 12)
		if ok then
			local task = { path = path, status = '', title = vim.fs.basename(path) }
			for _, line in ipairs(head_lines) do
				local key, value = line:match('^(%w+):%s*(.*)$')
				if key == 'status' then
					task.status = value
				elseif key == 'title' then
					task.title = value:gsub("^'(.*)'$", '%1')
				end
			end
			if META_ORDER[task.status] then
				table.insert(tasks, task)
			end
		end
	end
	table.sort(tasks, function(a, b)
		if a.status ~= b.status then
			return META_ORDER[a.status] < META_ORDER[b.status]
		end
		return a.title < b.title
	end)
	return tasks, dir
end

---What a line opens.
---@class genja.MorningItem
---@field kind 'dir'|'file'
---@field path string
---@field lnum? integer

---Items per line of each morning buffer.
---@type table<integer, table<integer, genja.MorningItem>>
local items_by_buf = {}

---@param path string
---@return string path relative to home with ~
local function short(path)
	return vim.fn.fnamemodify(path, ':~')
end

---@return string[]
local function start_dirs()
	local ok, sd = pcall(require, 'genja-startdirs')
	if not ok then
		return {}
	end
	return sd.ranked()
end

---@return string[]
local function recent_files()
	local list = {}
	local ok, recent = pcall(require, 'genja-recent')
	if ok then
		list = recent.list()
	else
		list = vim.tbl_filter(function(f) return vim.uv.fs_stat(f) ~= nil end, vim.v.oldfiles)
	end
	return vim.list_slice(list, 1, RECENT_MAX)
end

---Lines of `file` matching `pattern`, with their line numbers.
---@param file string
---@param pattern string
---@return { text: string, lnum: integer }[]
local function grep_file(file, pattern)
	local found = {}
	if vim.fn.filereadable(file) == 0 then
		return found
	end
	for lnum, line in ipairs(vim.fn.readfile(file)) do
		if line:match(pattern) then
			table.insert(found, { text = vim.trim(line), lnum = lnum })
		end
	end
	return found
end

---Newest doc-wip/untested.*.md (names sort by date).
---@return string|nil
local function untested_file()
	local files = vim.fn.glob(CONFIG .. '/doc-wip/untested.*.md', true, true)
	table.sort(files)
	return files[#files]
end

---Build the page: lines and the item behind each line.
---@return string[] lines, table<integer, genja.MorningItem> items
local function build()
	local lines = {}
	local items = {}
	local function head(title)
		if #lines > 0 then
			table.insert(lines, '')
		end
		table.insert(lines, '## ' .. title)
	end
	local function add(text, item)
		table.insert(lines, '  ' .. text)
		items[#lines] = item
	end

	table.insert(lines, '# Morning  ' .. os.date('%Y-%m-%d %a') .. '   (click or <CR> opens, q closes)')

	head('Start dirs')
	for _, dir in ipairs(start_dirs()) do
		add(short(dir), { kind = 'dir', path = dir })
	end

	head('Recent')
	for _, file in ipairs(recent_files()) do
		add(short(file), { kind = 'file', path = file })
	end

	local tasks, dir = meta_tasks()
	head('Todo (' .. short(dir) .. ')')
	for _, task in ipairs(tasks) do
		add(('%-11s %s'):format(task.status, task.title), { kind = 'file', path = task.path })
	end

	local untested = untested_file()
	if untested then
		head('Untested (' .. vim.fs.basename(untested) .. ')')
		for _, hit in ipairs(grep_file(untested, '^%- %[ %]')) do
			add(hit.text, { kind = 'file', path = untested, lnum = hit.lnum })
		end
	end
	return lines, items
end

---Open the item on the cursor line of `buf`.
---@param buf integer
local function open_item(buf)
	local items = items_by_buf[buf]
	if not items then
		return
	end
	local item = items[vim.fn.line('.')]
	if not item then
		return
	end
	if item.kind == 'dir' then
		vim.cmd('cd ' .. vim.fn.fnameescape(item.path))
		vim.cmd('Oil ' .. vim.fn.fnameescape(item.path))
		return
	end
	vim.cmd('edit ' .. vim.fn.fnameescape(item.path))
	if item.lnum then
		vim.api.nvim_win_set_cursor(0, { item.lnum, 0 })
		vim.cmd('normal! zv')
	end
end

---:Morning: show the page in the current window (rebuilt each time).
function M.open()
	local lines, items = build()
	local buf = vim.api.nvim_create_buf(false, true)
	vim.bo[buf].bufhidden = 'wipe'
	vim.bo[buf].filetype = 'markdown'
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].modifiable = false
	pcall(vim.api.nvim_buf_set_name, buf, 'morning')
	items_by_buf[buf] = items
	vim.api.nvim_create_autocmd('BufWipeout', {
		buffer = buf, once = true,
		callback = function() items_by_buf[buf] = nil end,
	})
	vim.api.nvim_win_set_buf(0, buf)

	local function o(desc) return { buffer = buf, desc = desc, nowait = true } end
	vim.keymap.set('n', '<CR>', function() open_item(buf) end, o 'Morning: open')
	-- the click has already moved the cursor (mouse=a), so release opens that line
	vim.keymap.set('n', '<LeftRelease>', function() open_item(buf) end, o 'Morning: open (click)')
	vim.keymap.set('n', 'q', '<Cmd>bwipeout<CR>', o 'Morning: close')
	vim.keymap.set('n', 'R', M.open, o 'Morning: rebuild')
	if #lines <= 1 then
		vim.notify(SRC .. 'nothing to show', vim.log.levels.INFO)
	end
end

return M
