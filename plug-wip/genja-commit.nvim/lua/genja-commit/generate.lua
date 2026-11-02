-- Write a commit message from the staged diff with an AI CLI, inserted at the cursor.
-- Backends are tried in opts.generate.order; the first available one runs (CLIs: on PATH;
-- http ones such as ollama: curl on PATH). Backends: plug-wip/genja-util.nvim/lua/genja-util/llm.lua.

local llm = require('genja-util.llm')
local config = require('genja-commit.config')
local git = require('genja-commit.git')
local popup = require('genja-commit.popup')

local M = {}

local SRC = 'genja-commit/generate.lua: '

---@type table<integer, { job: any, cancelled: boolean }> running jobs (vim.system objects) by buffer
local running = {}

---Backends tried in generate.order: built-in ones (genja-util/llm.lua) or generate.backends entries.
---@return genja-util.llm.Backend|nil
local function pick_backend()
	local opts = config.get().generate
	for _, name in ipairs(opts.order) do
		local backend = llm.named(name, opts[name], opts.backends[name])
		if backend and backend:available() then
			return backend
		end
	end
	return nil
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
	pcall(vim.keymap.del, { 'n', 'i' }, config.get().keys.cancel, { buffer = buf })
end

---Generate a message for the gitcommit buffer buf.
---@param buf integer
function M.run(buf)
	if running[buf] then
		vim.notify(SRC .. 'already generating', vim.log.levels.WARN)
		return
	end
	local opts = config.get()
	local dir = git.buf_dir(buf)
	local input, err = build_input(dir, vim.b[buf].genja_commit_conventional == true)
	if not input then
		vim.notify(SRC .. (err or 'no input'), vim.log.levels.WARN)
		return
	end
	local backend = pick_backend()
	if not backend then
		vim.notify(SRC .. 'none available: ' .. table.concat(opts.generate.order, ', '), vim.log.levels.WARN)
		return
	end
	local name = backend.name

	local status = ('generating (%s) · %s cancels'):format(name, opts.keys.cancel)
	vim.notify(SRC .. status)
	popup.set_status(buf, status)

	local entry = { cancelled = false }
	entry.job = backend:run(input, { cwd = dir, timeout = opts.generate.timeout }, function(err, out)
		finish(buf)
		if entry.cancelled then
			vim.notify(SRC .. name .. ' cancelled')
			return
		end
		if err then
			vim.notify(SRC .. name .. ' failed: ' .. err, vim.log.levels.ERROR)
			return
		end
		local text = clean(out or '')
		if text == '' then
			vim.notify(SRC .. name .. ' returned nothing', vim.log.levels.WARN)
			return
		end
		if vim.api.nvim_buf_is_valid(buf) then
			insert_at_cursor(buf, text)
		end
	end)
	if not entry.job then
		finish(buf)
		return
	end
	running[buf] = entry

	local function cancel()
		entry.cancelled = true
		entry.job:kill('sigterm')
	end
	vim.keymap.set({ 'n', 'i' }, opts.keys.cancel, cancel, { buffer = buf, desc = 'Commit: cancel generating' })
end

return M
