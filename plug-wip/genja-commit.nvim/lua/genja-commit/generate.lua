-- Write a commit message from the staged diff with an AI CLI, inserted at the cursor.
-- Backends are tried in opts.generate.order; the first one on PATH runs.
-- The whole prompt goes on stdin: npm .cmd shims cap the command line at 8191 chars.

local config = require('genja-commit.config')
local git = require('genja-commit.git')
local popup = require('genja-commit.popup')

local M = {}

local src = 'plug-wip/genja-commit.nvim/lua/genja-commit/generate.lua: '

---@type table<integer, { job: any, cancelled: boolean }> running jobs (vim.system objects) by buffer
local running = {}

---@param name string
---@return string[]? cmd
local function command_for(name)
	local opts = config.get().generate
	local exe = vim.fn.exepath(name) -- full path: finds .cmd shims on Windows
	if exe == '' then
		return nil
	end
	local cmd = { exe }
	if name == 'claude' then
		vim.list_extend(cmd, { '-p', '--tools', '' }) -- no tools: answer from stdin only
		if opts.claude.model then
			vim.list_extend(cmd, { '--model', opts.claude.model })
		end
		if opts.claude.effort then
			vim.list_extend(cmd, { '--effort', opts.claude.effort })
		end
	elseif name == 'copilot' then
		-- untested. -s: response only, no stats; --no-ask-user: never wait for input.
		-- No --allow-* flags: tools needing permission are refused in -p mode.
		vim.list_extend(cmd, { '-p', 'Follow the instructions on stdin.', '-s', '--no-ask-user' })
		if opts.copilot.model then
			vim.list_extend(cmd, { '--model', opts.copilot.model })
		end
	elseif name == 'gemini' then
		-- untested. -p text is appended to stdin; -o text: plain answer
		vim.list_extend(cmd, { '-p', 'Follow the instructions above.', '-o', 'text' })
		if opts.gemini.model then
			vim.list_extend(cmd, { '-m', opts.gemini.model })
		end
	elseif name == 'aichat' then
		table.insert(cmd, '-S') -- no streaming: one plain answer
		if opts.aichat.model then
			vim.list_extend(cmd, { '-m', opts.aichat.model })
		end
		local role = opts.aichat.role
		if role then
			local roles = vim.system({ exe, '--list-roles' }, { text = true }):wait()
			local list = vim.split(roles.stdout or '', '\n', { trimempty = true })
			if roles.code == 0 and vim.list_contains(vim.tbl_map(vim.trim, list), role) then
				vim.list_extend(cmd, { '-r', role })
			end
		end
	else
		vim.notify(src .. 'unknown generator ' .. name, vim.log.levels.WARN)
		return nil
	end
	return cmd
end

---@return string? name
---@return string[]? cmd
local function pick_backend()
	for _, name in ipairs(config.get().generate.order) do
		local cmd = command_for(name)
		if cmd then
			return name, cmd
		end
	end
	return nil, nil
end

---Extra prompt lines for Conventional Commits mode: the model infers type and scope.
---@return string
local function conventional_rules()
	local types = table.concat(config.get().conventional_types, ', ')
	return table.concat({
		'',
		'Use Conventional Commits for the summary line: type(scope): description.',
		'This format wins over the style of the recent subjects.',
		'Infer the type from the diff; one of: ' .. types .. '.',
		'Scope: optional, the main module or area touched, one lower-case word.',
		'Description: imperative, lower case, no trailing period.',
		'Only for a breaking change: add ! after type(scope) and a "BREAKING CHANGE: ..." footer.',
		'The summary line limit includes type and scope.',
	}, '\n')
end

---@param dir string
---@param conventional boolean
---@return string? input
---@return string? err
local function build_input(dir, conventional)
	local opts = config.get()
	local diff, err = git.run(dir, { 'diff', '--cached', '--no-color' })
	if not diff then
		return nil, err
	end
	if vim.trim(diff) == '' then
		return nil, 'nothing staged'
	end
	if #diff > opts.generate.diff_max then
		diff = diff:sub(1, opts.generate.diff_max) .. '\n[diff truncated]\n'
	end
	local subjects = git.run(dir, { 'log', '-' .. opts.generate.subjects, '--format=%s' }) or ''

	local prompt = opts.generate.prompt
	if not prompt then
		prompt = table.concat({
			'Write a git commit message for the staged diff below.',
			('Summary line: imperative mood, at most %d characters, no trailing period.'):format(opts.lint.title_max),
			('Then, only if the why is not obvious, a blank line and a body wrapped at %d columns.'):format(opts.lint.body_max),
			'Match the style of the recent subjects.',
			'Reply with the message only: no code fences, no quotes, no commentary.',
		}, '\n')
	end
	if conventional then
		prompt = prompt .. conventional_rules()
	end
	return prompt .. '\n\nRecent subjects:\n' .. subjects .. '\nStaged diff:\n' .. diff
end

---Trim and drop a surrounding code fence.
---@param text string
---@return string
local function clean(text)
	text = vim.trim(text)
	text = text:gsub('^```%w*\n', ''):gsub('\n```$', '')
	return vim.trim(text)
end

---@param buf integer
---@param text string
local function insert_at_cursor(buf, text)
	local lines = vim.split(text, '\n', { plain = true })
	local win = vim.fn.bufwinid(buf)
	local row, col = 0, 0
	if win ~= -1 then
		local cursor = vim.api.nvim_win_get_cursor(win)
		row, col = cursor[1] - 1, cursor[2]
	end
	vim.api.nvim_buf_set_text(buf, row, col, row, col, lines)
	if win ~= -1 then
		local end_col = #lines[#lines]
		if #lines == 1 then
			end_col = col + end_col
		end
		vim.api.nvim_win_set_cursor(win, { row + #lines, end_col })
	end
end

---@param buf integer
local function finish(buf)
	running[buf] = nil
	popup.set_status(buf, nil)
	local cancel = config.get().keys.cancel
	pcall(vim.keymap.del, 'n', cancel, { buffer = buf })
	pcall(vim.keymap.del, 'i', cancel, { buffer = buf })
end

---Generate a message for the gitcommit buffer buf.
---@param buf integer
function M.run(buf)
	if running[buf] then
		vim.notify(src .. 'already generating', vim.log.levels.WARN)
		return
	end
	local opts = config.get()
	local dir = git.buf_dir(buf)
	local input, err = build_input(dir, vim.b[buf].genja_commit_conventional == true)
	if not input then
		vim.notify(src .. (err or 'no input'), vim.log.levels.WARN)
		return
	end
	local name, cmd = pick_backend()
	if not name or not cmd then
		vim.notify(src .. 'none on PATH: ' .. table.concat(opts.generate.order, ', '), vim.log.levels.WARN)
		return
	end

	local status = ('generating (%s) · %s cancels'):format(name, opts.keys.cancel)
	vim.notify(src .. status)
	popup.set_status(buf, status)

	local entry = { cancelled = false }
	entry.job = vim.system(cmd, {
		cwd = dir,
		text = true,
		stdin = input,
		timeout = opts.generate.timeout * 1000,
	}, vim.schedule_wrap(function(res)
		finish(buf)
		if entry.cancelled then
			vim.notify(src .. name .. ' cancelled')
			return
		end
		if res.code == 124 then -- vim.system's timeout code
			vim.notify(src .. ('%s timed out after %d s'):format(name, opts.generate.timeout), vim.log.levels.WARN)
			return
		end
		if res.code ~= 0 then
			local out = vim.trim((res.stderr or '') .. '\n' .. (res.stdout or ''))
			vim.notify(src .. name .. ' failed: ' .. out, vim.log.levels.ERROR)
			return
		end
		local text = clean(res.stdout or '')
		if text == '' then
			vim.notify(src .. name .. ' returned nothing', vim.log.levels.WARN)
			return
		end
		if vim.api.nvim_buf_is_valid(buf) then
			insert_at_cursor(buf, text)
		end
	end))
	running[buf] = entry

	local function cancel()
		entry.cancelled = true
		entry.job:kill('sigterm')
	end
	vim.keymap.set({ 'n', 'i' }, opts.keys.cancel, cancel, { buffer = buf, desc = 'Commit: cancel generating' })
end

return M
