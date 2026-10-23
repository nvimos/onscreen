-- git diff preview: diff when the entry has changes, oil's preview otherwise

local SRC = 'lua/genja/oil/git-diff-preview.lua: '

local preview = require('genja.oil.plug.preview')

local M = {}

-- file path and new-file line for diff line `lnum`;
-- path is relative to the dir git ran in (git diff --relative)
local function diff_target(lines, lnum)
	local path = nil
	local line_nr = 1
	local in_hunk = false
	for i = 1, lnum do
		local line = lines[i]
		if vim.startswith(line, 'diff --git ') then
			path = nil
			line_nr = 1
			in_hunk = false
		elseif not in_hunk and vim.startswith(line, '+++ ') then
			path = line:match('^%+%+%+ b/(.+)$') -- nil for '+++ /dev/null' (deleted file)
		elseif vim.startswith(line, '@@') then
			line_nr = tonumber(line:match('^@@ %-[%d,]+ %+(%d+)')) or 1
			in_hunk = true
		elseif in_hunk and i < lnum then
			-- ' ' and '+' lines exist in the new file, '-' lines don't
			local mark = line:sub(1, 1)
			if mark == ' ' or mark == '+' then
				line_nr = line_nr + 1
			end
		end
	end
	if path == nil and not in_hunk then
		-- cursor on a file header: the '+++' line is below
		for i = lnum + 1, #lines do
			if vim.startswith(lines[i], '@@') then
				break
			end
			local below = lines[i]:match('^%+%+%+ b/(.+)$')
			if below then
				path = below
				break
			end
		end
	end
	return path, line_nr
end

-- <CR> in the diff: open the file in the oil window, at the line under the cursor
local function open_diff_target(diff_buf, dir, oil_win)
	local lines = vim.api.nvim_buf_get_lines(diff_buf, 0, -1, false)
	local path, line_nr = diff_target(lines, vim.fn.line('.'))
	if not path then
		vim.notify(SRC .. 'no file for this diff line (deleted?)', vim.log.levels.WARN)
		return
	end
	vim.api.nvim_win_close(0, true) -- the preview
	if vim.api.nvim_win_is_valid(oil_win) then
		vim.api.nvim_set_current_win(oil_win)
	end
	if vim.w.is_oil_win then
		require('oil').close() -- like oil's select: leave the float before opening a file
	end
	vim.cmd.edit(vim.fn.fnameescape(dir .. path))
	local last = vim.api.nvim_buf_line_count(0)
	vim.api.nvim_win_set_cursor(0, { math.min(line_nr, last), 0 })
	vim.cmd('normal! zz')
end

local function show_diff(preview_win, diff, dir, oil_win)
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, diff)
	vim.bo[buf].bufhidden = 'wipe'
	vim.bo[buf].modifiable = false
	vim.bo[buf].filetype = 'diff'
	vim.b[buf].genja_diff_preview = true
	vim.keymap.set('n', '<CR>', function() open_diff_target(buf, dir, oil_win) end,
		{ buffer = buf, desc = 'Oil diff: open file at this line' })
	vim.api.nvim_win_set_buf(preview_win, buf)
end

M.toggle_diff_preview = function()
	local oil = require('oil')
	local entry = oil.get_cursor_entry()
	if not entry or not entry.id or entry.name == '..' then
		return
	end

	-- second press on the same entry closes the diff
	local preview_win = require('oil.util').get_preview_win()
	if preview_win and preview.is_previewing(entry) then
		local shown = vim.api.nvim_win_get_buf(preview_win)
		if vim.b[shown].genja_diff_preview then
			vim.api.nvim_win_close(preview_win, true)
			return
		end
	end

	local dir = oil.get_current_dir()
	local oil_win = vim.api.nvim_get_current_win()
	-- HEAD: staged + unstaged changes; --relative: paths relative to dir
	local cmd = { 'git', 'diff', 'HEAD', '--relative', '--no-color', '--no-ext-diff', '--', entry.name }
	vim.system(cmd, { cwd = dir, text = true }, vim.schedule_wrap(function(res)
		local diff = {}
		if res.code == 0 and res.stdout ~= '' then
			diff = vim.split(res.stdout:gsub('\n$', ''), '\n', { plain = true })
		end
		-- the user may have moved on while git ran
		if vim.api.nvim_get_current_win() ~= oil_win then
			return
		end
		local now = oil.get_cursor_entry()
		if not now or now.id ~= entry.id then
			return
		end
		oil.open_preview({}, function(err)
			if err then
				return
			end
			local win = require('oil.util').get_preview_win()
			if not win or not vim.api.nvim_win_is_valid(oil_win) then
				return
			end
			if #diff > 0 then
				show_diff(win, diff, dir, oil_win)
			end
			preview.fit_preview(oil_win, win)
		end)
	end))
end

return M
