-- Lint gitcommit buffers while typing.
-- nvim-lint + gitlint when both are there, else the Lua rules below.

local config = require('genja-commit.config')
local git = require('genja-commit.git')
local convention = require('genja-commit.convention')

local M = {}

local SRC = 'genja-commit/lint.lua: '
local ns = vim.api.nvim_create_namespace('genja_commit_lint')
local LINTER = 'genja_gitlint'
local LINTER_CC = 'genja_gitlint_cc' -- with the Conventional Commits rule (CT1)
local severity = vim.diagnostic.severity

local registered = false
local install_checked = false
---@type table<integer, any> debounce timers (uv timers) by buffer
local timers = {}

local function has_python()
	for _, exe in ipairs({ 'python', 'python3', 'py' }) do
		local path = vim.fn.exepath(exe)
		-- WindowsApps\python.exe is the Store installer stub, not Python
		if path ~= '' and not path:find('WindowsApps', 1, true) then
			return true
		end
	end
	return false
end

-- once per session: Mason's gitlint is a pypi package, so it needs Python
local function install_gitlint()
	if install_checked then
		return
	end
	install_checked = true
	if not config.get().lint.install_gitlint or vim.fn.executable('gitlint') == 1 or not has_python() then
		return
	end
	local ok, registry = pcall(require, 'mason-registry')
	if not ok then
		return
	end
	registry.refresh(vim.schedule_wrap(function()
		local ok_pkg, pkg = pcall(registry.get_package, 'gitlint')
		if ok_pkg and not pkg:is_installed() and not pkg:is_installing() then
			vim.notify(SRC .. 'installing gitlint (Mason)')
			pkg:install()
		end
	end))
end

-- nvim-lint's gitlint reads the file named after the buffer (--msg-filename),
-- which is stale while typing and missing in the popup; this one reads stdin.
---@param lint table require('lint')
---@param extra string[] args added to the shared ones
local function gitlint_linter(lint, extra)
	local opts = config.get().lint
	local linter = vim.deepcopy(lint.linters.gitlint)
	linter.args = {
		'-c', 'title-max-length.line-length=' .. opts.title_max,
		'-c', 'body-max-line-length.line-length=' .. opts.body_max,
		'--ignore', 'B5,B6', -- body too short / missing: title-only messages are fine
	}
	vim.list_extend(linter.args, extra)
	-- gitlint reports everything as an error; long lines are warnings here
	return require('lint.util').wrap(linter, function(d)
		if d.code == 'T1' or d.code == 'B1' then
			d.severity = severity.WARN
		end
		return d
	end)
end

local function register_gitlint(lint)
	local types = table.concat(config.get().conventional_types, ',')
	lint.linters[LINTER] = gitlint_linter(lint, {})
	lint.linters[LINTER_CC] = gitlint_linter(lint, {
		'--contrib', 'CT1',
		'-c', 'contrib-title-conventional-commits.types=' .. types,
	})
	registered = true
end

---@param buf integer
---@param lnum integer 0-based
---@param line string
---@param max integer
---@param sev integer vim.diagnostic.severity
---@param message string
local function diag(buf, lnum, line, max, sev, message)
	-- byteidx is -1 past the end of the line
	local col = math.max(vim.fn.byteidx(line, max), 0)
	return { bufnr = buf, lnum = lnum, col = col, end_col = #line, severity = sev, message = message, source = 'genja-commit' }
end

---Lua rules: title length, blank line 2, body line length.
---Real git commit buffers skip '#' lines and stop at the scissors line; the
---popup commits with `-F -`, which keeps '#' lines, so it counts them.
---@param buf integer
---@return table[] diagnostics
local function rules(buf)
	local opts = config.get().lint
	local popup = vim.b[buf].genja_commit_popup
	local diagnostics = {}
	local n = 0 -- message line, comments skipped
	for i, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
		if not popup and line:find('^# %-+ >8 %-+') then
			break
		end
		local comment = not popup and line:sub(1, 1) == '#'
		if not comment then
			n = n + 1
			local len = vim.fn.strchars(line)
			if n == 1 then
				if len > opts.title_max then
					table.insert(diagnostics, diag(buf, i - 1, line, opts.title_max, severity.WARN,
						('title is %d chars, max %d'):format(len, opts.title_max)))
				end
				local cc_error = vim.b[buf].genja_commit_conventional and line ~= '' and convention.title_error(line)
				if cc_error then
					table.insert(diagnostics, diag(buf, i - 1, line, 0, severity.ERROR, cc_error))
				end
			elseif n == 2 and line ~= '' then
				table.insert(diagnostics, diag(buf, i - 1, line, 0, severity.ERROR, 'line 2 must be blank'))
			elseif n > 2 and len > opts.body_max then
				table.insert(diagnostics, diag(buf, i - 1, line, opts.body_max, severity.WARN,
					('body line is %d chars, max %d'):format(len, opts.body_max)))
			end
		end
	end
	return diagnostics
end

---@param buf integer
local function run(buf)
	if not vim.api.nvim_buf_is_valid(buf) then
		return
	end
	local ok, lint = pcall(require, 'lint')
	if ok and vim.fn.executable('gitlint') == 1 then
		if not registered then
			register_gitlint(lint)
		end
		vim.diagnostic.reset(ns, buf) -- gitlint may have arrived mid-session
		local name = (vim.b[buf].genja_commit_conventional and LINTER_CC or LINTER)
		vim.api.nvim_buf_call(buf, function()
			lint.try_lint(name, { cwd = git.buf_dir(buf) })
		end)
		return
	end
	vim.diagnostic.set(ns, buf, rules(buf))
end

---@param buf integer
local function schedule(buf)
	local timer = timers[buf]
	if not timer then
		timer = assert(vim.uv.new_timer())
		timers[buf] = timer
	end
	timer:stop()
	timer:start(config.get().lint.debounce, 0, vim.schedule_wrap(function() run(buf) end))
end

---Lint buf now and after each change.
---@param buf integer
function M.attach(buf)
	install_gitlint()
	local group = vim.api.nvim_create_augroup('genja_commit_lint_' .. buf, { clear = true })
	vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI', 'InsertLeave' }, {
		group = group,
		buffer = buf,
		callback = function() schedule(buf) end,
	})
	vim.api.nvim_create_autocmd('BufWipeout', {
		group = group,
		buffer = buf,
		callback = function()
			local timer = timers[buf]
			if timer then
				timer:stop()
				timer:close()
				timers[buf] = nil
			end
			vim.api.nvim_del_augroup_by_id(group)
		end,
	})
	run(buf)
end

return M
