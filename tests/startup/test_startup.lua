-- Startup: a fresh clone of the config starts cleanly, and startup stays below 1 s (CLAUDE.md ## Goal).
-- `make test D=startup` in tests/.
--
-- Clean clone: the tracked files (git ls-files, as they are in the working tree) are copied to a
-- temp XDG_CONFIG_HOME, so what a clone lacks is missing here too: the gitignored local files
-- (lsp/local.lua, local/startdirs.txt, local/secrets.lua, ...), ignored spec dirs and plug-wip
-- plugins that are their own repos. Plugins come from the real stdpath('data'); mason installs nothing.
--
-- Startup time: `nvim --headless --startuptime` with the real config, the median of a few runs, up
-- to "NVIM STARTED". VeryLazy comes after that: a UI fires it once the first screen is drawn.
local H = require('helpers.timing')
local S = H.suite('startup')

local child = MiniTest.new_child_neovim()
local eq = MiniTest.expect.equality

local CONFIG = vim.fs.normalize(vim.fn.stdpath('config'))
local LIMIT_MS = 1000
local RUNS = 3

local tmp = vim.fs.normalize(vim.fn.tempname())
local old_xdg = vim.env.XDG_CONFIG_HOME

local T = MiniTest.new_set({
    hooks = {
        post_once = function()
            child.stop()
            vim.env.XDG_CONFIG_HOME = old_xdg
            vim.fn.delete(tmp, 'rf')
            H.save()
        end,
    },
})

---Copy the config's tracked files to <tmp>/nvim.
---@return string dest
local function copy_tracked()
    local out = vim.system({ 'git', '-C', CONFIG, 'ls-files', '-z' }, { text = true }):wait()
    assert(out.code == 0, 'git ls-files failed: ' .. (out.stderr or ''))
    local dest = tmp .. '/nvim'
    for _, rel in ipairs(vim.split(out.stdout, '\0', { trimempty = true })) do
        local src = CONFIG .. '/' .. rel
        -- deleted in the working tree but not committed yet: skip, as the next commit will
        if vim.uv.fs_stat(src) then
            local to = dest .. '/' .. rel
            vim.fn.mkdir(vim.fs.dirname(to), 'p')
            assert(vim.uv.fs_copyfile(src, to))
        end
    end
    return dest
end

-- Records warnings and errors from vim.notify, and lazy's LazyDone, from the very start of init.vim on.
local NOTIFY_HOOK = [[lua
    _G.genja_notes = {}
    _G.genja_lazy_done = false
    vim.api.nvim_create_autocmd('User', { pattern = 'LazyDone', once = true, callback = function() _G.genja_lazy_done = true end })
    local notify = vim.notify
    vim.notify = function(msg, level, opts)
        if (level or vim.log.levels.INFO) >= vim.log.levels.WARN then
            table.insert(_G.genja_notes, tostring(msg))
        end
        return notify(msg, level, opts)
    end
]]

T['clean clone: starts without errors or warnings'] = S:case({ name = 'clean clone', groups = { 'startup' }, timeout = 20000, slow = 8000 }, function(ctx)
    local config = copy_tracked()
    vim.env.XDG_CONFIG_HOME = tmp
    child.restart({
        -- mini.test starts children with --clean, which drops the config dir from the rtp
        '--cmd', 'set rtp^=' .. config .. ' rtp+=' .. config .. '/after',
        '--cmd', 'let g:genja_lsp_no_install = v:true',
        '--cmd', NOTIFY_HOOK,
        '-u', config .. '/init.vim',
    })
    vim.env.XDG_CONFIG_HOME = old_xdg

    -- the copy must be the config the child runs, or the test checks the real one
    eq(vim.fs.normalize(child.lua([[return vim.fn.stdpath('config')]])), config)

    -- lazy fires VeryLazy after UIEnter, but only watches for it once LazyDone has fired (later
    -- when a plugin is missing); a headless child has no UI
    H.wait(function() return child.lua([[return _G.genja_lazy_done == true]]) end, ctx.timeout)
    child.lua([[vim.api.nvim_exec_autocmds('UIEnter', {})]])
    H.wait(function() return child.lua([[return vim.g.did_very_lazy == true]]) end, ctx.timeout)
    child.cmd('edit ' .. vim.fn.fnameescape(config .. '/lua/genja/opt.lua'))
    vim.uv.sleep(500)

    local got = child.lua([[
        local errors = {}
        for _, line in ipairs(vim.split(vim.fn.execute('messages'), '\n', { trimempty = true })) do
            if line:match('^E%d+:') or line:match('[Ee]rror') then
                table.insert(errors, line)
            end
        end
        -- specs lazy knows but can't find on disk: a dir = ... that a clone doesn't have
        local missing = {}
        local ok, lazy_config = pcall(require, 'lazy.core.config')
        if ok then
            for name, plugin in pairs(lazy_config.plugins) do
                if not plugin._.installed then
                    table.insert(missing, name)
                end
            end
            table.sort(missing)
        end
        return {
            genja = package.loaded['genja'] ~= nil, -- false: init.vim fell back to the small subset
            lazy_done = _G.genja_lazy_done == true, -- false: lazy's setup didn't finish
            very_lazy = vim.g.did_very_lazy == true,
            missing = missing,
            notes = _G.genja_notes,
            errors = errors,
        }
    ]])
    eq(got, { genja = true, lazy_done = true, very_lazy = true, missing = {}, notes = {}, errors = {} })
end)

---Milliseconds until "NVIM STARTED", one headless run with the real config.
---@param args string[] extra arguments (files to open)
---@param timeout integer
---@return number
local function startup_ms(args, timeout)
    local log = vim.fs.normalize(vim.fn.tempname())
    local cmd = { vim.v.progpath, '--headless', '--cmd', 'let g:genja_lsp_no_install = v:true', '--startuptime', log }
    vim.list_extend(cmd, args)
    table.insert(cmd, '+qa!')
    local out = vim.system(cmd, { cwd = CONFIG }):wait(timeout)
    assert(out.code == 0, 'nvim exited with ' .. tostring(out.code) .. ': ' .. (out.stderr or ''))
    local ms
    for _, line in ipairs(vim.fn.readfile(log)) do
        local t = line:match('^(%d+%.%d+)%s.*NVIM STARTED')
        if t then
            ms = tonumber(t)
        end
    end
    vim.fn.delete(log)
    assert(ms, 'no NVIM STARTED line in --startuptime log')
    return ms
end

-- make's V=1 or more: the times go into a note even when the case passes
local VERBOSE = (tonumber(vim.env.TEST_VERBOSE or '') or 0) >= 1

---Median of RUNS startups; fails above LIMIT_MS, with the times in the error.
---@param args string[]
---@param timeout integer
local function check_startup(args, timeout)
    local times = {}
    for _ = 1, RUNS do
        table.insert(times, startup_ms(args, timeout))
    end
    table.sort(times)
    local median = times[math.ceil(RUNS / 2)]
    local runs = table.concat(vim.tbl_map(function(t) return ('%.0f'):format(t) end, times), ', ')
    if VERBOSE then
        MiniTest.add_note(('startup %.0f ms (runs: %s ms)'):format(median, runs))
    end
    if median >= LIMIT_MS then
        error(('startup %.0f ms, limit %d ms (runs: %s ms)'):format(median, LIMIT_MS, runs), 0)
    end
end

T['startup below 1 s: no file'] = S:case({ name = 'time no file', groups = { 'startup' }, timeout = 15000, slow = 5000 }, function(ctx)
    check_startup({}, ctx.timeout)
end)

T['startup below 1 s: a lua file'] = S:case({ name = 'time lua file', groups = { 'startup' }, timeout = 15000, slow = 5000 }, function(ctx)
    check_startup({ 'lua/genja/opt.lua' }, ctx.timeout)
end)

return T
