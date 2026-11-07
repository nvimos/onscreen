-- f2 scripts.lua: composer.json / package.json scripts as <F2> items, run in overseer.
-- Fixtures in tests/f2/eff-two/ (scripts echo a line). Runs the real composer and npm;
-- cases skip without them. Fresh child nvim per case, with overseer from lazy's dir.
-- Run from pwsh (make): started from Git Bash, the child nvim segfaults in overseer's job.

local child = MiniTest.new_child_neovim()
local eq = MiniTest.expect.equality

-- MiniTest.skip() only ends the function it is called in, so check per case
local function needs(exe, case)
    return function()
        if vim.fn.executable(exe) == 0 then
            MiniTest.skip(exe .. ' not on PATH')
        end
        case()
    end
end

local T = MiniTest.new_set({
    hooks = {
        pre_case = function()
            child.restart({ '-u', 'tests/minimal_init.lua' })
            child.lua([[
                local overseer_dir = vim.fn.stdpath('data') .. '/lazy/overseer.nvim'
                vim.opt.rtp:prepend(overseer_dir)
                vim.cmd.source(overseer_dir .. '/plugin/overseer.lua')
                -- plain output buffer: a headless child's terminal (ConPTY) shows only "[Process exited 0]"
                require('overseer').setup({ output = { use_terminal = false } })
                _G.scripts = require('genja.f2.collect.scripts')
                _G.picker = require('genja.f2.picker')
                _G.run = require('genja.f2.run')
                _G.dir = vim.fs.normalize(vim.fn.getcwd() .. '/tests/f2/eff-two')
                _G.ctx = { dir = dir, bufnr = 0, filetype = '' }
                -- <F2> items for the fixture dir; collect calls done synchronously
                _G.items = function()
                    local out
                    scripts.collect(ctx, function(tasks) out = tasks end)
                    return out
                end
                _G.labels = function()
                    return vim.tbl_map(function(t) return t.group .. ': ' .. t.label end, items())
                end
                -- the sub-picker's entries of the item whose label starts with `runner`
                _G.entries_of = function(runner)
                    local got
                    local orig = picker.entries
                    picker.entries = function(entries) got = entries end
                    for _, t in ipairs(items()) do
                        if vim.startswith(t.label, runner .. ' ') then
                            t.action(ctx)
                        end
                    end
                    picker.entries = orig
                    return got
                end
                -- run the runner's `hello` script; the task once it is done, else false
                _G.run_hello = function(runner)
                    run.entries(entries_of(runner), ctx)
                    local task = require('overseer').list_tasks()[1]
                    vim.wait(30000, function() return task:is_complete() end, 100)
                    return task
                end
                _G.output = function(task)
                    return table.concat(vim.api.nvim_buf_get_lines(task:get_bufnr(), 0, -1, false), '\n')
                end
                _G.list_open = function()
                    for _, win in ipairs(vim.api.nvim_list_wins()) do
                        if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == 'OverseerList' then
                            return true
                        end
                    end
                    return false
                end
            ]])
        end,
        post_once = child.stop,
    },
})

T['eff-two offers composer and npm scripts'] = needs('composer', needs('npm', function()
    eq(child.lua([[return labels()]]), {
        'script: composer scripts in eff-two (1)',
        'script: npm scripts in eff-two (1)',
    })
end))

T['composer hello runs in overseer'] = needs('composer', function()
    local got = child.lua([[
        local task = run_hello('composer')
        return { name = task.name, status = task.status, cwd = vim.fs.normalize(task.cwd), out = output(task) }
    ]])
    eq(got.name, 'composer run-script hello')
    eq(got.status, 'SUCCESS')
    eq(got.cwd, child.lua([[return dir]]))
    eq(got.out:find('eff-two composer hello', 1, true) ~= nil, true)
end)

T['npm hello runs in overseer'] = needs('npm', function()
    local got = child.lua([[
        local task = run_hello('npm')
        return { name = task.name, status = task.status, out = output(task) }
    ]])
    eq(got.name, 'npm run hello')
    eq(got.status, 'SUCCESS')
    eq(got.out:find('eff-two npm hello', 1, true) ~= nil, true)
end)

T['the task list opens with the run; :OverseerToggle closes and reopens it'] = needs('npm', function()
    child.lua([[run_hello('npm')]])
    eq(child.lua([[return list_open()]]), true)
    child.cmd('OverseerToggle')
    eq(child.lua([[return list_open()]]), false)
    child.cmd('OverseerToggle')
    eq(child.lua([[return list_open()]]), true)
end)

return T
