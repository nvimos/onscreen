-- Flip a boolean option, or step a number or string option through its values (given ones,
-- else NUMBERS, else what :set completes). Local options change only this window or buffer.
-- Commands: plugin/opt-cycle.lua. Vim's :To (lua/genja/vimrc.almalinux.vim) is the fallback version.
local SRC = 'lua/genja/ext/opt-cycle.lua: '

local M = {}

-- values for number options; :set completes no values for these
local NUMBERS = {
    conceallevel = { 0, 1, 2, 3 },
    laststatus = { 0, 1, 2, 3 },
    showtabline = { 0, 1, 2 },
    cmdheight = { 0, 1 },
    scrolloff = { 0, 5, 999 },
    sidescrolloff = { 0, 5, 999 },
}

---Option info for a long or short name; nil when there is no such option.
---@param name string
---@return vim.api.keyset.get_option_info|nil
local function info_of(name)
    if name == '' then
        return nil
    end
    local ok, info = pcall(vim.api.nvim_get_option_info2, name, {})
    if not ok then
        return nil
    end
    return info
end

---@param info vim.api.keyset.get_option_info
---@return any
local function get(info)
    return vim.api.nvim_get_option_value(info.name, {})
end

---Window and buffer options change this window/buffer only; global ones as :set does.
---@param info vim.api.keyset.get_option_info
---@param value any
local function set(info, value)
    if info.scope == 'global' or info.global_local then
        vim.api.nvim_set_option_value(info.name, value, {})
        return
    end
    vim.api.nvim_set_option_value(info.name, value, { scope = 'local' })
end

---How :set prints it: wrap / nowrap / conceallevel=2, after the source prefix.
---@param info vim.api.keyset.get_option_info
local function notify(info)
    local value = get(info)
    if info.type == 'boolean' then
        local prefix = ''
        if not value then
            prefix = 'no'
        end
        vim.notify(SRC .. prefix .. info.name)
        return
    end
    vim.notify(SRC .. info.name .. '=' .. tostring(value))
end

---The current value as the string the value lists hold.
---@param info vim.api.keyset.get_option_info
---@return string
local function current(info)
    local value = get(info)
    if info.type == 'boolean' then
        return (value and '1' or '0')
    end
    return tostring(value)
end

---Default values to cycle through, as strings.
---@param info vim.api.keyset.get_option_info
---@return string[]
local function defaults(info)
    if info.type == 'boolean' then
        return { '0', '1' }
    end
    if info.type == 'number' then
        local values = {}
        for _, n in ipairs(NUMBERS[info.name] or {}) do
            table.insert(values, tostring(n))
        end
        return values
    end
    return vim.fn.getcompletion('set ' .. info.name .. '=', 'cmdline')
end

---@param name string
function M.toggle(name)
    local info = info_of(name)
    if not info then
        vim.notify(SRC .. 'no option ' .. name, vim.log.levels.ERROR)
        return
    end
    if info.type ~= 'boolean' then
        vim.notify(SRC .. info.name .. ' is not on/off; :Cycle ' .. info.name, vim.log.levels.WARN)
        return
    end
    set(info, not get(info))
    notify(info)
end

---@param name string
---@param values string[] empty: the defaults
function M.cycle(name, values)
    local info = info_of(name)
    if not info then
        vim.notify(SRC .. 'no option ' .. name, vim.log.levels.ERROR)
        return
    end
    if #values == 0 then
        values = defaults(info)
    end
    -- free-form options (path, statusline) complete only their current value: nothing to cycle
    if #values < 2 then
        vim.notify(SRC .. 'no values known for ' .. info.name .. '; :Cycle ' .. info.name .. ' {value} {value}...',
            vim.log.levels.WARN)
        return
    end
    -- not in the list: start at the first value
    local index = 0
    for i, v in ipairs(values) do
        if v == current(info) then
            index = i
            break
        end
    end
    local next = values[index % #values + 1]
    if info.type == 'string' then
        set(info, next)
    elseif info.type == 'boolean' then
        set(info, next == '1')
    else
        local n = tonumber(next)
        if not n then
            vim.notify(SRC .. info.name .. ' takes a number, not ' .. next, vim.log.levels.ERROR)
            return
        end
        set(info, n)
    end
    notify(info)
end

---Option names starting with `lead`, sorted; only booleans when asked.
---@param lead string
---@param boolean_only boolean
---@return string[]
local function names(lead, boolean_only)
    local list = {}
    for name, info in pairs(vim.api.nvim_get_all_options_info()) do
        if (not boolean_only or info.type == 'boolean') and vim.startswith(name, lead) then
            table.insert(list, name)
        end
    end
    table.sort(list)
    return list
end

---:Toggle completion: boolean option names.
---@param lead string
---@return string[]
function M.complete_toggle(lead)
    return names(lead, true)
end

---:Cycle completion: the option name first, then its values, the current one included.
---@param lead string
---@param line string
---@param pos integer
---@return string[]
function M.complete_cycle(lead, line, pos)
    local words = vim.split(line:sub(1, pos), '%s+', { trimempty = true })
    local done = #words
    if lead ~= '' then
        done = done - 1
    end
    if done <= 1 then
        return names(lead, false)
    end
    local info = info_of(words[2])
    if not info then
        return {}
    end
    local values = defaults(info)
    if not vim.tbl_contains(values, current(info)) then
        table.insert(values, 1, current(info))
    end
    return vim.tbl_filter(function(v) return vim.startswith(v, lead) end, values)
end

return M
