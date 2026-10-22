-- Small synchronous git helpers.

local M = {}

---Run git in dir.
---@param dir string
---@param args string[]
---@return string? stdout
---@return string? err
function M.run(dir, args)
	local cmd = { 'git' }
	vim.list_extend(cmd, args)
	local res = vim.system(cmd, { cwd = dir, text = true }):wait()
	if res.code ~= 0 then
		return nil, vim.trim(res.stderr or '')
	end
	return res.stdout or ''
end

---@param dir string
---@return string[]? files
---@return string? err
function M.staged_files(dir)
	local out, err = M.run(dir, { 'diff', '--cached', '--name-only' })
	if not out then
		return nil, err
	end
	return vim.split(vim.trim(out), '\n', { trimempty = true })
end

---Absolute path of COMMIT_EDITMSG (worktrees have their own).
---@param dir string
---@return string?
function M.msg_path(dir)
	local out = M.run(dir, { 'rev-parse', '--path-format=absolute', '--git-path', 'COMMIT_EDITMSG' })
	if not out or vim.trim(out) == '' then
		return nil
	end
	return vim.fs.normalize(vim.trim(out))
end

---Committer time of HEAD, 0 without commits.
---@param dir string
---@return integer
function M.last_commit_time(dir)
	local out = M.run(dir, { 'log', '-1', '--format=%ct' })
	if not out then
		return 0
	end
	return tonumber(vim.trim(out)) or 0
end

---Repo dir for a gitcommit buffer: the popup's dir, else nvim's cwd
---(git starts its editor in the work tree).
---@param buf integer
---@return string
function M.buf_dir(buf)
	local dir = vim.b[buf].genja_commit_dir
	if dir then
		return dir
	end
	return vim.fn.getcwd()
end

return M
