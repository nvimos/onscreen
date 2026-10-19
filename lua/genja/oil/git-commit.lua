-- git commit popup
-- <CR> commits, <C-CR> inserts 'updated <file>' (other staged files go in the body),
-- <Esc> aborts, an empty message aborts.

local git = require('genja.oil.git')

local M = {}

local src = 'nvim/lua/genja/oil/git-commit.lua: '

-- message kept between popups: saved on close, cleared after a successful commit
local commit_draft = nil

local function staged_files(dir)
	local res = vim.system({ 'git', 'diff', '--cached', '--name-only' }, { cwd = dir, text = true }):wait()
	if res.code ~= 0 then
		return nil, vim.trim(res.stderr or '')
	end
	return vim.split(vim.trim(res.stdout), '\n', { trimempty = true })
end

local function run_commit(dir, message)
	local opts = { cwd = dir, text = true, stdin = message .. '\n' }
	vim.system({ 'git', 'commit', '-F', '-' }, opts, vim.schedule_wrap(function(res)
		if res.code == 0 then
			commit_draft = nil -- a failed commit keeps it for the next try
			vim.notify(src .. vim.split(res.stdout, '\n')[1]) -- '[branch abc1234] summary'
			git.refresh_oil_git()
		else
			local out = vim.trim((res.stderr or '') .. '\n' .. (res.stdout or ''))
			vim.notify(src .. 'git commit failed: ' .. out, vim.log.levels.ERROR)
		end
	end))
end

M.git_commit = function()
	local dir = require('oil').get_current_dir()
	if not dir then
		return
	end
	local files, err = staged_files(dir)
	if not files then
		vim.notify(src .. 'git: ' .. err, vim.log.levels.ERROR)
		return
	end
	if #files == 0 then
		vim.notify(src .. 'nothing staged', vim.log.levels.WARN)
		return
	end

	local buf = vim.api.nvim_create_buf(false, true)
	vim.bo[buf].bufhidden = 'wipe'
	vim.bo[buf].filetype = 'gitcommit'
	-- text area 80 x 6 (more rows for a long body/draft, up to 15); width/height
	-- exclude the border, so leave 2 for it plus a little margin on small screens
	local width = math.min(80, vim.o.columns - 4)
	local needed = math.max(#files + 1, 6) -- summary, blank, body
	if commit_draft then
		needed = math.max(needed, #commit_draft)
	end
	local height = math.min(needed, 15, vim.o.lines - vim.o.cmdheight - 4)
	height = math.max(height, 1)
	local win = vim.api.nvim_open_win(buf, true, {
		relative = 'editor',
		width = width,
		height = height,
		row = math.floor((vim.o.lines - height) / 2),
		col = math.floor((vim.o.columns - width) / 2),
		style = 'minimal',
		border = 'rounded',
		title = ' Commit · <CR> commit · <C-CR> updated <file> · <Esc> abort ',
		title_pos = 'center',
	})
	-- a completion menu would take <CR>
	local ok_cmp, cmp = pcall(require, 'cmp')
	if ok_cmp then
		cmp.setup.buffer({ enabled = false })
	end

	if commit_draft then
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, commit_draft)
	end

	local closed = false
	local function close()
		if closed then
			return
		end
		closed = true
		if vim.api.nvim_buf_is_valid(buf) then
			local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
			commit_draft = lines
			if vim.trim(table.concat(lines, '\n')) == '' then
				commit_draft = nil
			end
		end
		if vim.api.nvim_get_current_win() == win then
			vim.cmd.stopinsert()
		end
		if vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_close(win, true)
		end
	end

	local function submit()
		local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
		close()
		local message = vim.trim(table.concat(lines, '\n'))
		if message == '' then
			return
		end
		run_commit(dir, message)
	end

	-- 'updated <first file>' at the cursor on the summary line; other files as body
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

	local function o(desc) return { buffer = buf, desc = desc } end
	vim.keymap.set({ 'n', 'i' }, '<CR>', submit, o 'Commit: submit')
	vim.keymap.set({ 'n', 'i' }, '<C-CR>', fill, o 'Commit: insert "updated <file>"')
	vim.keymap.set({ 'n', 'i' }, '<Esc>', close, o 'Commit: abort')
	-- leaving the popup aborts too; scheduled: no window closing inside WinLeave
	vim.api.nvim_create_autocmd('WinLeave', {
		buffer = buf,
		once = true,
		callback = function() vim.schedule(close) end,
	})
	-- end of the summary line, so a restored draft can be continued
	vim.api.nvim_win_set_cursor(win, { 1, 0 })
	vim.cmd.startinsert({ bang = true })
end

return M
