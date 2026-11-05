-- Debug F-keys: while a debug session runs, `!` flips F1-F8 between debug actions and their own maps.
-- arm() maps `!` (session start), disarm() puts `!` and the F-keys back (session end).
-- Called from lua/lazyp/debug/dap-php.lua.
local SRC = 'lua/genja/ext/debug-fkeys.lua: '

local M = {}

-- Order of a debugger toolbar: run, step, then the rest.
local KEYS = {
    { '<F1>', function() require('dap').continue() end,          'continue' },
    { '<F2>', function() require('dap').step_over() end,         'step over' },
    { '<F3>', function() require('dap').step_into() end,         'step into' },
    { '<F4>', function() require('dap').step_out() end,          'step out' },
    { '<F5>', function() require('dap').run_to_cursor() end,     'run to cursor' },
    { '<F6>', function() require('dap').toggle_breakpoint() end, 'breakpoint' },
    { '<F7>', function() require('dap.ui.widgets').hover() end,  'hover' },
    { '<F8>', function() require('dap').terminate() end,         'stop' },
}

---@type table<string, table|false>|nil  lhs -> map before the flip (false: none); nil while the F-keys are normal
local saved = nil
---@type table|false|nil  `!` before arm(); nil while not armed
local bang_saved = nil

-- The global normal-mode map of lhs, or false. A buffer-local map shadows it and is not saved.
---@param lhs string
---@return table|false
local function save(lhs)
    local map = vim.fn.maparg(lhs, 'n', false, true)
    if vim.tbl_isempty(map) or map.buffer == 1 then
        return false
    end
    return map
end

---@param lhs string
---@param map table|false
local function restore(lhs, map)
    pcall(vim.keymap.del, 'n', lhs)
    if map then
        vim.fn.mapset(map)
    end
end

local function legend()
    local parts = {}
    for _, key in ipairs(KEYS) do
        table.insert(parts, key[1]:sub(2, -2) .. ' ' .. key[3])
    end
    return table.concat(parts, ', ')
end

-- `!`: debug actions on the F-keys, or their own maps back.
function M.flip()
    if saved then
        for _, key in ipairs(KEYS) do
            restore(key[1], saved[key[1]])
        end
        saved = nil
        vim.notify(SRC .. 'F-keys back to their own maps')
        return
    end
    saved = {}
    for _, key in ipairs(KEYS) do
        saved[key[1]] = save(key[1])
        vim.keymap.set('n', key[1], key[2], { desc = 'Debug: ' .. key[3] })
    end
    vim.notify(SRC .. 'F-keys debug: ' .. legend())
end

-- Session started: `!` flips the F-keys. Calling it again does nothing.
function M.arm()
    if bang_saved ~= nil then
        return
    end
    bang_saved = save('!')
    vim.keymap.set('n', '!', M.flip, { desc = 'Debug: flip F-keys (debug actions / own maps)' })
end

-- Session ended: F-keys and `!` as before arm().
function M.disarm()
    if saved then
        for _, key in ipairs(KEYS) do
            restore(key[1], saved[key[1]])
        end
        saved = nil
    end
    if bang_saved ~= nil then
        restore('!', bang_saved)
        bang_saved = nil
    end
end

return M
