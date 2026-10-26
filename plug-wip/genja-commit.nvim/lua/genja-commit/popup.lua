-- Commit message popup.
-- The buffer is named after the repo's COMMIT_EDITMSG (buftype=acwrite): :w writes it.
-- Unsaved text is kept in memory per repo; reopening refills from the newer of the
-- two. A successful commit empties both.

local config = require('genja-commit.config')
local git = require('genja-commit.git')

local M = {}

local SRC = 'genja-commit/popup.lua: '

---@class genja-commit.Draft
---@field lines string[]
---@field time integer os.time() when saved

---@type table<string, genja-commit.Draft> key: COMMIT_EDITMSG path, or the dir without one
local drafts = {}

---@type table<integer, { win: integer, title: string }> open popups by buffer
local popups = {}

---@param lines string[]
local function is_blank(lines)
	return vim.trim(table.concat(lines, '\n')) == ''
end

---COMMIT_EDITMSG content worth refilling: written after the last commit
---(git writes the file on every commit), without git's '#' help lines.
---@param path string
---@param dir string
---@return string[]? lines
---@return integer time
local function saved_message(path, dir)
	local stat = vim.uv.fs_stat(path)
	if not stat or stat.mtime.sec <= git.last_commit_time(dir) then
		return nil, 0
	end
	local lines = {}
	for _, line in ipairs(vim.fn.readfile(path)) do
		if line:find('^# %-+ >8 %-+') then
			break
		end
		if line:sub(1, 1) ~= '#' then
			table.insert(lines, line)
		end
	end
	if is_blank(lines) then
		return nil, 0
	end
	return lines, stat.mtime.sec
end

---Newest wins: the in-memory draft or the saved file.
---@param key string
---@param path? string
---@param dir string
---@return string[]?
local function initial_lines(key, path, dir)
	local file_lines, file_time = nil, 0
	if path then
		file_lines, file_time = saved_message(path, dir)
	end
	local draft = drafts[key]
	if draft and (not file_lines or draft.time >= file_time) then
		if is_blank(draft.lines) then
			return nil
		end
		return draft.lines
	end
	return file_lines
end

---@param dir string
---@param message string
---@param key string
---@param path? string
local function run_commit(dir, message, key, path)
	local opts = { cwd = dir, text = true, stdin = message .. '\n' }
	vim.system({ 'git', 'commit', '-F', '-' }, opts, vim.schedule_wrap(function(res)
		if res.code ~= 0 then
			-- the draft stays for the next try
			local out = vim.trim((res.stderr or '') .. '\n' .. (res.stdout or ''))
			vim.notify(SRC .. 'git commit failed: ' .. out, vim.log.levels.ERROR)
			return
		end
		drafts[key] = nil
		if path then
			vim.fn.writefile({}, path) -- git wrote this message there; don't refill it
		end
		vim.notify(SRC .. vim.split(res.stdout, '\n')[1]) -- '[branch abc1234] summary'
		local on_commit = config.get().on_commit
		if on_commit then
			on_commit(dir)
		end
	end))
end

---A key option as a list: one key or several.
---@param lhs string|string[]
---@return string[]
local function key_list(lhs)
	if type(lhs) == 'string' then
		return { lhs }
	end
	return lhs
end

---@param keys genja-commit.Keys
local function title_for(keys)
	return (' Commit · %s commit · %s update <file> · %s generate · %s abort '):format(
		table.concat(key_list(keys.commit), '/'), keys.fill, keys.generate, keys.abort[1] or 'q')
end

---Show a status in the popup's title; nil restores it. No-op for other buffers.
---@param buf integer
---@param text? string
function M.set_status(buf, text)
	local popup = popups[buf]
	if not popup or not vim.api.nvim_win_is_valid(popup.win) then
		return
	end
	local title = popup.title
	if text then
		title = ' ' .. text .. ' '
	end
	vim.api.nvim_win_set_config(popup.win, { title = title, title_pos = 'center' })
end

---Open the popup for the repo at dir.
---@param dir? string
function M.open(dir)
	if not dir then
		return
	end
	local files, err = git.staged_files(dir)
	if not files then
		vim.notify(SRC .. 'git: ' .. (err or ''), vim.log.levels.ERROR)
		return
	end
	if #files == 0 then
		vim.notify(SRC .. 'nothing staged', vim.log.levels.WARN)
		return
	end

	local keys = config.get().keys
	local path = git.msg_path(dir)
	local key = path or dir
	local lines = initial_lines(key, path, dir)

	local buf = vim.api.nvim_create_buf(false, true)
	vim.bo[buf].bufhidden = 'wipe'
	vim.bo[buf].swapfile = false
	if path then
		-- fails when COMMIT_EDITMSG is already open in another buffer
		local ok = pcall(vim.api.nvim_buf_set_name, buf, path)
		if ok then
			vim.bo[buf].buftype = 'acwrite'
		else
			vim.notify(SRC .. 'COMMIT_EDITMSG is open elsewhere; :w is off in this popup', vim.log.levels.WARN)
			path = nil
		end
	end
	vim.b[buf].genja_commit_dir = dir
	vim.b[buf].genja_commit_popup = true
	if lines then
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	end
	vim.bo[buf].modified = false

	-- text area 80 x 6 (more rows for a long body/draft, up to 15); width/height
	-- exclude the border, so leave 2 for it plus a little margin on small screens
	local width = math.min(80, vim.o.columns - 4)
	local needed = math.max(#files + 1, 6) -- summary, blank, body
	if lines then
		needed = math.max(needed, #lines)
	end
	local height = math.min(needed, 15, vim.o.lines - vim.o.cmdheight - 4)
	height = math.max(height, 1)
	local title = title_for(keys)
	local win = vim.api.nvim_open_win(buf, true, {
		relative = 'editor',
		width = width,
		height = height,
		row = math.floor((vim.o.lines - height) / 2),
		col = math.floor((vim.o.columns - width) / 2),
		style = 'minimal',
		border = 'rounded',
		title = title,
		title_pos = 'center',
	})
	popups[buf] = { win = win, title = title }
	-- after the window: the FileType autocmd (lint, <M-g>) sees the popup's dir
	vim.bo[buf].filetype = 'gitcommit'

	-- only edits since opening or :w count; an untouched popup keeps the old draft
	local function save_draft()
		if not vim.api.nvim_buf_is_valid(buf) or not vim.bo[buf].modified then
			return
		end
		drafts[key] = { lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false), time = os.time() }
	end

	local closed = false
	local function close()
		if closed then
			return
		end
		closed = true
		save_draft()
		popups[buf] = nil
		if vim.api.nvim_get_current_win() == win then
			vim.cmd.stopinsert()
		end
		if vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_close(win, true)
		end
	end

	local function submit()
		local errors = vim.diagnostic.get(buf, { severity = vim.diagnostic.severity.ERROR })
		if #errors > 0 then
			local choice = vim.fn.confirm(('Commit with %d lint error(s)?'):format(#errors), '&Yes\n&No', 2)
			if choice ~= 1 then
				return
			end
		end
		local message = vim.trim(table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), '\n'))
		close()
		if message == '' then
			return
		end
		run_commit(dir, message, key, path)
	end

	-- 'update: <first file>' at the cursor on the summary line; other files as body
	local function fill()
		local text = 'update: ' .. files[1]
		local cursor = vim.api.nvim_win_get_cursor(win)
		local col = cursor[2]
		if cursor[1] ~= 1 then
			col = #vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1]
		end
		vim.api.nvim_buf_set_text(buf, 0, col, 0, col, { text })
		if #files > 1 then
			local body = { '' }
			for i = 2, #files do
				table.insert(body, files[i])
			end
			vim.api.nvim_buf_set_lines(buf, 1, -1, false, body)
		end
		vim.api.nvim_win_set_cursor(win, { 1, col + #text })
	end

	if path then
		vim.api.nvim_create_autocmd('BufWriteCmd', {
			buffer = buf,
			callback = function()
				local content = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
				if vim.fn.writefile(content, path) ~= 0 then
					vim.notify(SRC .. 'cannot write ' .. path, vim.log.levels.ERROR)
					return
				end
				vim.bo[buf].modified = false
				drafts[key] = nil -- the file holds it now
			end,
		})
	end

	local function o(desc) return { buffer = buf, desc = desc } end
	for _, lhs in ipairs(key_list(keys.commit)) do
		vim.keymap.set({ 'n', 'i' }, lhs, submit, o 'Commit: submit')
	end
	vim.keymap.set({ 'n', 'i' }, keys.fill, fill, o 'Commit: insert "update: <file>"')
	for _, lhs in ipairs(keys.abort) do
		vim.keymap.set('n', lhs, close, o 'Commit: abort')
	end
	-- leaving the popup closes it; the draft is read now, the window closed later
	-- (no window closing inside WinLeave)
	vim.api.nvim_create_autocmd('WinLeave', {
		buffer = buf,
		once = true,
		callback = function()
			save_draft()
			vim.schedule(close)
		end,
	})
	-- end of the summary line, so a restored draft can be continued
	vim.api.nvim_win_set_cursor(win, { 1, 0 })
	vim.cmd.startinsert({ bang = true })
end

return M
