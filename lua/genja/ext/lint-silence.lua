-- Silence the lint rule of the diagnostic under the cursor by writing it into the linter's config:
--   markdownlint  "MDnnn": false        in lint/.markdownlint.jsonc (the shared config, always used)
--   vale          Check.Name = NO       in the [*.md] section of the vale config the buffer uses
--                                       (the project's .vale.ini, else the shared lint/.vale.ini)
-- Each entry gets a comment with the date and the message, so it can be found and undone by hand.
-- Then the buffer is linted again. Mapped in markdown buffers (after/ftplugin/markdown.vim).

local SRC = 'lua/genja/ext/lint-silence.lua: '

local M = {}

---Diagnostics under the cursor; none there: every one on the cursor line.
---@return vim.Diagnostic[]
local function at_cursor()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local on_line = vim.diagnostic.get(0, { lnum = row - 1 })
    local under = {}
    for _, d in ipairs(on_line) do
        local end_lnum = d.end_lnum or d.lnum
        local end_col = d.end_col or d.col
        if end_lnum ~= d.lnum then
            -- spans lines: counts as under the cursor anywhere on its first line
            table.insert(under, d)
        elseif col >= d.col and col <= end_col then
            table.insert(under, d)
        end
    end
    if #under > 0 then
        return under
    end
    return on_line
end

---Rule id of a diagnostic and the linter it comes from; nil when it can't be silenced here.
---@param d vim.Diagnostic
---@return string|nil linter 'markdownlint' or 'vale'
---@return string|nil rule
local function rule_of(d)
    if d.source == 'markdownlint' then
        -- errorformat keeps the rule in the message: "MD033/no-inline-html Inline HTML ..."
        return 'markdownlint', d.message:match('^(MD%d+)')
    end
    if d.source == 'vale' and type(d.code) == 'string' then
        return 'vale', d.code
    end
    return nil, nil
end

---@param path string
---@return string[]|nil
local function read(path)
    if not vim.uv.fs_stat(path) then
        return nil
    end
    return vim.fn.readfile(path)
end

---Comment text: the date and the start of the message, on one line.
---@param d vim.Diagnostic
---@return string
local function note(d)
    local message = d.message:gsub('%s+', ' ')
    return os.date('%Y-%m-%d') .. ' ' .. message:sub(1, 80)
end

---Add `"rule": false` before the closing brace of the JSONC config.
---@param path string
---@param rule string
---@param d vim.Diagnostic
---@return boolean changed
---@return string message
local function silence_markdownlint(path, rule, d)
    local lines = read(path)
    if not lines then
        return false, 'no ' .. path
    end
    for _, line in ipairs(lines) do
        if line:match('^%s*"' .. rule .. '"%s*:%s*false') then
            return false, rule .. ' is already off in ' .. path
        end
    end

    local close = nil
    for i = #lines, 1, -1 do
        if lines[i]:match('^%s*}%s*$') then
            close = i
            break
        end
    end
    if not close then
        return false, 'no closing } in ' .. path
    end

    -- the last entry before the brace needs a comma
    for i = close - 1, 1, -1 do
        local code = lines[i]:gsub('//.*$', '')
        if code:match('%S') then
            if not code:match('[,{]%s*$') then
                lines[i] = code:gsub('%s*$', '') .. ','
            end
            break
        end
    end

    table.insert(lines, close, '\t"' .. rule .. '": false')
    table.insert(lines, close, '\t// ' .. note(d))
    vim.fn.writefile(lines, path)
    return true, rule .. ' off in ' .. path
end

---Set `rule = NO` in the [*.md] section of the vale ini; adds the section when missing.
---@param path string
---@param rule string
---@param d vim.Diagnostic
---@return boolean changed
---@return string message
local function silence_vale(path, rule, d)
    local lines = read(path)
    if not lines then
        return false, 'no ' .. path
    end

    local first = nil
    for i, line in ipairs(lines) do
        if vim.trim(line) == '[*.md]' then
            first = i
            break
        end
    end
    if not first then
        vim.list_extend(lines, { '', '[*.md]' })
        first = #lines
    end

    -- the section ends before the next [header]; trailing blank lines stay after the new entry
    local last = first
    for i = first + 1, #lines do
        if lines[i]:match('^%s*%[') then
            break
        end
        local key = lines[i]:match('^%s*([^=#;%s]+)%s*=')
        if key == rule then
            if lines[i]:match('=%s*NO%s*$') then
                return false, rule .. ' is already off in ' .. path
            end
            lines[i] = rule .. ' = NO'
            vim.fn.writefile(lines, path)
            return true, rule .. ' off in ' .. path
        end
        if lines[i]:match('%S') then
            last = i
        end
    end

    table.insert(lines, last + 1, rule .. ' = NO')
    table.insert(lines, last + 1, '# ' .. note(d))
    vim.fn.writefile(lines, path)
    return true, rule .. ' off in ' .. path
end

---Silence one diagnostic's rule and lint the buffer again.
---@param buf integer
---@param d vim.Diagnostic
local function silence(buf, d)
    local linter, rule = rule_of(d)
    if not linter or not rule then
        vim.notify(SRC .. 'no rule to turn off for ' .. tostring(d.source), vim.log.levels.WARN)
        return
    end
    local lint = require('genja.ext.lint')
    local changed, message
    if linter == 'markdownlint' then
        changed, message = silence_markdownlint(lint.MARKDOWNLINT_CONFIG, rule, d)
    else
        changed, message = silence_vale(lint.vale_config(buf), rule, d)
    end
    vim.notify(SRC .. message)
    if changed then
        lint.lint(buf, 'BufWritePost')
    end
end

---<leader>cx: pick a diagnostic under the cursor (if several) and turn its rule off.
function M.at_cursor()
    local buf = vim.api.nvim_get_current_buf()
    local items = {}
    for _, d in ipairs(at_cursor()) do
        local linter, rule = rule_of(d)
        if linter and rule then
            table.insert(items, d)
        end
    end
    if #items == 0 then
        vim.notify(SRC .. 'no markdownlint or vale diagnostic under the cursor', vim.log.levels.INFO)
        return
    end
    if #items == 1 then
        silence(buf, items[1])
        return
    end
    vim.ui.select(items, {
        prompt = 'Turn off the rule of',
        format_item = function(d)
            local _, rule = rule_of(d)
            return rule .. ': ' .. d.message
        end,
    }, function(d)
        if d then
            silence(buf, d)
        end
    end)
end

return M
