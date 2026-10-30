-- :messages as a jump list: file:line locations in Lua tracebacks and Vim script errors.
--   :Messages [-dump]   :messages in a scratch buffer (current window); <CR> jumps, q closes
--   :Messages -quick    append the locations to the quickfix list, open it
--   :Messages -loc      append them to this window's location list, open it
--   :Messages -yank     all of :messages to the clipboard (+)
--   <F2>                one item per location, newest first, at most 10 (lua/genja/f2/collect/messages.lua)
-- Reads :messages when asked; nothing runs in the background. The recording variant
-- (wraps vim.notify, off by default) is lua/genja/ext/messages-capture.lua.
-- Command: plugin/messages.lua. Tests: tests/messages/.

local SRC = 'lua/genja/ext/messages.lua: '

local M = {}

---@class genja.messages.Location
---@field filename string
---@field lnum integer
---@field text string the message line it came from

---Lines of :messages, oldest first.
---@return string[]
function M.lines()
	return vim.split(vim.fn.execute('messages'), '\n', { trimempty = true })
end

---Full path for a traceback path; Lua shortens long ones to `...ocal/nvim/lua/genja/x.lua`.
---Shortened: the part from `lua/` (or `plugin/`, `after/`) looked up in the runtimepath.
---@param path string
---@return string|nil
function M.resolve(path)
	path = vim.fs.normalize(path)
	if not vim.startswith(path, '...') then
		return (vim.uv.fs_stat(path) and path or nil)
	end
	for _, dir in ipairs({ 'lua/', 'plugin/', 'after/', 'ftplugin/' }) do
		local at = path:find('/' .. dir, 1, true)
		if at then
			local found = vim.api.nvim_get_runtime_file(path:sub(at + 1), false)[1]
			if found then
				return vim.fs.normalize(found)
			end
		end
	end
	return nil
end

---Locations in `lines`, in order, each file:line once.
---Lua: `<path>.lua:<n>:`; Vim script: `Error detected while processing <path>:` then `line <n>:`.
---@param lines string[]
---@return genja.messages.Location[]
function M.locations(lines)
	local out = {}
	local seen = {}
	local function add(path, lnum, text)
		local file = M.resolve(path)
		if not file then
			return
		end
		local id = file .. ':' .. lnum
		if seen[id] then
			return
		end
		seen[id] = true
		table.insert(out, { filename = file, lnum = lnum, text = vim.trim(text) })
	end

	local vim_file = nil
	for _, line in ipairs(lines) do
		-- `\` paths too, and drive letters (C:/...)
		for path, lnum in line:gmatch('(%S-%.lua):(%d+):') do
			-- a quote or bracket in front isn't part of the path
			local clean = path:gsub('^[%[%(\'"]+', '')
			add(clean, tonumber(lnum), line)
		end
		local processing = line:match('^Error detected while processing (.-):$')
		if processing then
			-- `function <SNR>12_foo[3]..` names no file; `BufEnter Autocommands for "*"` neither
			vim_file = processing:match('^(%a?:?[^%s]+%.vim)$')
		end
		local vim_lnum = line:match('^line%s+(%d+):$')
		if vim_lnum and vim_file then
			add(vim_file, tonumber(vim_lnum), 'Error in ' .. vim_file)
		end
	end
	return out
end

---Locations of the current :messages, newest first.
---@param max? integer
---@return genja.messages.Location[]
function M.newest(max)
	local newest = vim.iter(M.locations(M.lines())):rev()
	if max then
		newest = newest:take(max)
	end
	return newest:totable()
end

---Open `loc` in the current window.
---@param loc genja.messages.Location
function M.open(loc)
	vim.cmd('edit ' .. vim.fn.fnameescape(loc.filename))
	local last = vim.api.nvim_buf_line_count(0)
	vim.api.nvim_win_set_cursor(0, { math.min(loc.lnum, last), 0 })
	vim.cmd('normal! zv')
end

---:Messages -dump: :messages in one scratch buffer in the current window.
---The old :DumpMessages set the scratch options on its first `enew`, then put the
---text into a second, normal buffer: that one blocked :q with "no write since last change".
function M.dump()
	local lines = M.lines()
	local prev = vim.api.nvim_get_current_buf()
	local buf = vim.api.nvim_create_buf(false, true) -- unlisted scratch: buftype=nofile, noswapfile
	vim.bo[buf].bufhidden = 'wipe'
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].modified = false
	vim.bo[buf].filetype = 'messages'
	vim.api.nvim_buf_set_name(buf, 'messages://' .. buf)
	vim.api.nvim_win_set_buf(0, buf)
	vim.api.nvim_win_set_cursor(0, { math.max(#lines, 1), 0 })

	vim.keymap.set('n', '<CR>', function()
		local here = M.locations({ vim.api.nvim_get_current_line() })[1]
		if here then
			M.open(here)
		else
			vim.notify(SRC .. 'no file:line on this line', vim.log.levels.INFO)
		end
	end, { buffer = buf, desc = 'Messages: open file:line under the cursor' })
	vim.keymap.set('n', 'q', function()
		if vim.api.nvim_buf_is_valid(prev) then
			vim.api.nvim_win_set_buf(0, prev)
		else
			vim.cmd('bwipeout')
		end
	end, { buffer = buf, desc = 'Messages: close' })
end

---:Messages -quick / -loc: append the locations (oldest first) and open the list.
---@param loc_list boolean true: this window's location list
function M.to_list(loc_list)
	local items = M.locations(M.lines()) -- filename, lnum, text: already quickfix items
	if #items == 0 then
		vim.notify(SRC .. 'no file:line in :messages', vim.log.levels.INFO)
		return
	end
	local what = { title = ':Messages', items = items }
	if loc_list then
		vim.fn.setloclist(0, {}, 'a', what)
		vim.cmd('lopen')
	else
		vim.fn.setqflist({}, 'a', what)
		vim.cmd('copen')
	end
end

---:Messages -yank: all of :messages into the + register.
function M.yank()
	local lines = M.lines()
	vim.fn.setreg('+', table.concat(lines, '\n'))
	vim.notify(SRC .. #lines .. ' message lines yanked to the clipboard')
end

---:Messages [-dump|-quick|-loc|-yank]
---@param args string
function M.command(args)
	local arg = vim.trim(args)
	if arg == '' or arg == '-dump' then
		M.dump()
	elseif arg == '-quick' then
		M.to_list(false)
	elseif arg == '-loc' or arg == '-location' then
		M.to_list(true)
	elseif arg == '-yank' then
		M.yank()
	else
		vim.notify(SRC .. 'unknown argument ' .. arg .. ' (-dump, -quick, -loc, -yank)', vim.log.levels.WARN)
	end
end

return M
