--[[

Stop the git fsmonitor daemons of the repos nvim has seen.

git starts `fsmonitor--daemon` (detached) in a repo with core.fsmonitor=true
and nothing ever stops it. It holds a handle on the working tree, so Windows
refuses to rename or delete a parent folder. Plugins and shells start it; we
cannot wrap them all, so we keep the repos we met and stop their daemons:

- on exit (VimLeavePre)
- on :GitFsmonitorStop

Repos are recorded from the cwd, :cd and every file read. A repo is touched
only when core.fsmonitor is true there and its daemon is running. The next git
call restarts the daemon, so stopping one that is still wanted costs a slower
first `git status`.

]]

local SRC = 'lua/genja/ext/git-stop-fsmonitor.lua: '
local TIMEOUT_MS = 3000

local M = {}

---@alias GitResult { code: integer, stdout: string, stderr: string }

local repos = {} -- repo root -> true
local seen = {} -- dir already looked up -> true

---@param dir string
local function record_dir(dir)
    dir = vim.fs.normalize(dir)
    if seen[dir] then
        return
    end
    seen[dir] = true
    local found = vim.fs.find('.git', { upward = true, path = dir })[1]
    if found then
        repos[vim.fs.normalize(vim.fs.dirname(found))] = true
    end
end

---@param buf integer
local function record_buf(buf)
    if vim.bo[buf].buftype ~= '' then
        return
    end
    local name = vim.api.nvim_buf_get_name(buf)
    if name == '' or name:find('://', 1, true) then
        return
    end
    record_dir(vim.fs.dirname(name))
end

---Run `git -C <root> <args>` in every root at once, wait for all.
---@param roots string[]
---@param args string[]
---@return table<string, GitResult>
local function wave(roots, args)
    local jobs = {}
    for _, root in ipairs(roots) do
        local cmd = vim.list_extend({ 'git', '-C', root }, args)
        local ok, job = pcall(vim.system, cmd, { text = true })
        if ok then
            jobs[root] = job
        end
    end
    local results = {}
    for root, job in pairs(jobs) do
        results[root] = job:wait(TIMEOUT_MS)
    end
    return results
end

---@param roots string[]
---@param results table<string, GitResult>
---@param keep fun(r: GitResult): boolean
---@return string[]
local function select_roots(roots, results, keep)
    local picked = {}
    for _, root in ipairs(roots) do
        local r = results[root]
        if r and keep(r) then
            table.insert(picked, root)
        end
    end
    return picked
end

---Stop the running daemons of the recorded repos that have core.fsmonitor on.
---@return string[] roots whose daemon was running
---@return table<string, GitResult> stop results by root
function M.stop_all()
    local roots = vim.tbl_keys(repos)
    table.sort(roots)

    local config = wave(roots, { 'config', '--type=bool', '--get', 'core.fsmonitor' })
    local enabled = select_roots(roots, config, function(r)
        return r.code == 0 and vim.trim(r.stdout) == 'true'
    end)

    local status = wave(enabled, { 'fsmonitor--daemon', 'status' })
    local running = select_roots(enabled, status, function(r)
        return r.code == 0
    end)

    return running, wave(running, { 'fsmonitor--daemon', 'stop' })
end

--- :GitFsmonitorStop, one line per daemon, nothing when none runs
local function stop_and_report()
    local running, stops = M.stop_all()
    for _, root in ipairs(running) do
        local r = stops[root]
        if r and r.code == 0 then
            vim.notify(SRC .. ' stopped ' .. root)
        else
            vim.notify(SRC .. '  failed ' .. root .. ' ' .. vim.trim(r and r.stderr or 'timeout'), vim.log.levels.WARN)
        end
    end
end

function M.setup()
    record_dir(vim.uv.cwd() or '.')

    local group = vim.api.nvim_create_augroup('GenjaGitStopFsmonitor', { clear = true })
    vim.api.nvim_create_autocmd('BufReadPost', {
        group = group,
        callback = function(args)
            record_buf(args.buf)
        end,
    })
    vim.api.nvim_create_autocmd('DirChanged', {
        group = group,
        callback = function(args)
            record_dir(args.file)
        end,
    })
    vim.api.nvim_create_autocmd('VimLeavePre', {
        group = group,
        -- best-effort cleanup while quitting: nobody can read a report anymore
        callback = function()
            M.stop_all()
        end,
    })

    vim.api.nvim_create_user_command('GitFsmonitorStop', stop_and_report, {
        desc = 'Git: stop fsmonitor daemons of the repos seen',
    })
end

return M
