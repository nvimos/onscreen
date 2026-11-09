-- <F2> source, group `script`: one item per manifest found above ctx.dir, composer.json and
-- package.json, `<manifest> scripts in <folder> (N)`, opening a sub-picker of its scripts.
-- Each chosen script runs as an overseer task: `composer run-script <name>`, `<runner> run <name>`
-- (runner from the lockfile: bun, pnpm, yarn, else npm). Same shape as collect/make.lua.

local picker = require('genja.f2.picker')
local groups = require('genja.f2.groups')

local M = {}

local SRC = 'lua/genja/f2/collect/scripts.lua: '

---Lockfile -> package manager that runs package.json scripts; first match wins.
local RUNNERS = {
    { 'bun.lock', 'bun' },
    { 'bun.lockb', 'bun' },
    { 'pnpm-lock.yaml', 'pnpm' },
    { 'yarn.lock', 'yarn' },
}

---@param dir string
---@return string
local function npm_runner(dir)
    for _, pair in ipairs(RUNNERS) do
        if vim.uv.fs_stat(vim.fs.joinpath(dir, pair[1])) then
            return pair[2]
        end
    end
    return 'npm'
end

---Script names of a manifest, sorted; empty when it has none or doesn't parse.
---@param path string
---@return string[]
local function script_names(path)
    local ok, data = pcall(vim.json.decode, table.concat(vim.fn.readfile(path), '\n'))
    if not ok or type(data) ~= 'table' or type(data.scripts) ~= 'table' then
        return {}
    end
    local names = vim.tbl_keys(data.scripts)
    table.sort(names)
    return names
end

---One <F2> item for the manifest `name` above `dir`, or nil.
---@param dir string
---@param name 'composer.json'|'package.json'
---@return genja.f2.Task|nil
local function item(dir, name)
    local path = vim.fs.find(name, { upward = true, type = 'file', path = dir })[1]
    if not path then
        return nil
    end
    local root = vim.fs.dirname(path)
    local runner = 'composer'
    local run = { 'run-script' }
    if name == 'package.json' then
        runner = npm_runner(root)
        run = { 'run' }
    end
    if vim.fn.executable(runner) == 0 then
        vim.notify(SRC .. 'found ' .. path .. ', but no ' .. runner .. ' in nvim\'s PATH', vim.log.levels.WARN)
        return nil
    end
    local names = script_names(path)
    if #names == 0 then
        return nil
    end
    local nothing = function() end -- scripts aren't stored
    local entries = {}
    for i, script in ipairs(names) do
        local cmd = vim.list_extend({ runner }, vim.list_extend(vim.deepcopy(run), { script }))
        table.insert(entries, {
            task = { group = groups.script, label = runner .. ': ' .. script, cmd = cmd, cwd = root, order = i },
            remove = nothing,
        })
    end
    return {
        group = groups.script,
        label = ('%s scripts in %s (%d)'):format(runner, vim.fs.basename(root), #entries),
        action = function(pick_ctx)
            picker.entries(entries, pick_ctx, { title = name .. ' scripts: ' .. vim.fn.fnamemodify(root, ':~') })
        end,
    }
end

---@param ctx genja.f2.Ctx
---@param done fun(tasks: genja.f2.Task[])
function M.collect(ctx, done)
    local tasks = {}
    for _, name in ipairs({ 'composer.json', 'package.json' }) do
        local task = item(ctx.dir, name)
        if task then
            table.insert(tasks, task)
        end
    end
    done(tasks)
end

-- exposed for tests/f2
M._script_names = script_names
M._npm_runner = npm_runner

return M
