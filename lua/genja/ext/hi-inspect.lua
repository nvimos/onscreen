-- :HiInspect: highlight groups under the cursor in a split (plugin/hi-inspect.lua).
-- Same data as :Inspect (vim.inspect_pos), plus each group's link chain and final colours;
-- each group name is drawn in its own colours.
local SRC = 'lua/genja/ext/hi-inspect.lua: '

local M = {}

local BUF_NAME = 'hi-inspect://'
local NS = vim.api.nvim_create_namespace('genja.hi-inspect')

---Link chain of a group: { 'Name', 'Link', 'Link of link' … }; stops at a loop.
---@param name string
---@return string[]
local function chain(name)
    local out = { name }
    local seen = { [name] = true }
    local cur = name
    while true do
        local hl = vim.api.nvim_get_hl(0, { name = cur, link = true })
        if hl.link == nil or seen[hl.link] then
            return out
        end
        cur = hl.link
        seen[cur] = true
        table.insert(out, cur)
    end
end

---@param color integer|nil
---@return string|nil
local function hex(color)
    if color == nil then
        return nil
    end
    return ('#%06x'):format(color)
end

---Final attributes of a group: 'fg=#… bg=#… bold italic', or 'cleared'.
---@param name string
---@return string
local function attrs(name)
    local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
    local parts = {}
    if hl.fg then
        table.insert(parts, 'fg=' .. hex(hl.fg))
    end
    if hl.bg then
        table.insert(parts, 'bg=' .. hex(hl.bg))
    end
    if hl.sp then
        table.insert(parts, 'sp=' .. hex(hl.sp))
    end
    local flags = { 'bold', 'italic', 'underline', 'undercurl', 'strikethrough', 'reverse' }
    for _, flag in ipairs(flags) do
        if hl[flag] then
            table.insert(parts, flag)
        end
    end
    if #parts == 0 then
        return 'cleared'
    end
    return table.concat(parts, ' ')
end

---@class genja.HiInspectRow
---@field group string
---@field note string|nil  capture, namespace, token type

---Rows per section, from vim.inspect_pos() at the cursor.
---@return { title: string, rows: genja.HiInspectRow[] }[]
local function collect()
    local info = vim.inspect_pos()
    local sections = {}

    local ts = {}
    for _, item in ipairs(info.treesitter or {}) do
        table.insert(ts, { group = item.hl_group, note = item.lang })
    end
    table.insert(sections, { title = 'Treesitter', rows = ts })

    local tokens = {}
    for _, item in ipairs(info.semantic_tokens or {}) do
        local note = nil
        if item.opts.priority then
            note = 'priority ' .. item.opts.priority
        end
        table.insert(tokens, { group = item.opts.hl_group, note = note })
    end
    table.insert(sections, { title = 'Semantic tokens', rows = tokens })

    local syntax = {}
    for _, item in ipairs(info.syntax or {}) do
        table.insert(syntax, { group = item.hl_group })
    end
    table.insert(sections, { title = 'Syntax', rows = syntax })

    local marks = {}
    for _, item in ipairs(info.extmarks or {}) do
        if item.opts.hl_group then
            table.insert(marks, { group = item.opts.hl_group, note = item.ns })
        end
    end
    table.insert(sections, { title = 'Extmarks', rows = marks })

    return sections
end

---Window showing BUF_NAME in this tab, else a new split under the current one.
---@return integer buf
local function open_split()
    local buf = vim.fn.bufnr(BUF_NAME)
    if buf ~= -1 then
        local wins = vim.fn.win_findbuf(buf)
        for _, win in ipairs(wins) do
            if vim.api.nvim_win_get_tabpage(win) == vim.api.nvim_get_current_tabpage() then
                return buf
            end
        end
    else
        buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_name(buf, BUF_NAME)
        vim.bo[buf].bufhidden = 'hide'
        vim.keymap.set('n', 'q', '<Cmd>close<CR>', { buffer = buf, desc = 'HiInspect: close' })
    end
    local cur = vim.api.nvim_get_current_win()
    vim.cmd('belowright split')
    vim.api.nvim_win_set_buf(0, buf)
    vim.api.nvim_set_current_win(cur)
    return buf
end

function M.show()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local file = vim.fn.expand('%:t')
    if file == '' then
        file = '[No Name]'
    end
    local char = vim.fn.strcharpart(vim.api.nvim_get_current_line():sub(col + 1), 0, 1)
    local sections = collect()

    local lines = { ('%s %d:%d  %q'):format(file, row, col + 1, char) }
    local marks = {} ---@type { line: integer, len: integer, group: string }[]
    local found = 0
    for _, section in ipairs(sections) do
        if #section.rows > 0 then
            table.insert(lines, '')
            table.insert(lines, section.title)
            for _, r in ipairs(section.rows) do
                local text = '  ' .. table.concat(chain(r.group), ' -> ')
                text = text .. '  ' .. attrs(r.group)
                if r.note then
                    text = text .. '  ' .. r.note
                end
                table.insert(lines, text)
                table.insert(marks, { line = #lines - 1, len = #r.group, group = r.group })
                found = found + 1
            end
        end
    end
    if found == 0 then
        table.insert(lines, '')
        table.insert(lines, 'no highlight groups here (Normal)')
    end

    local buf = open_split()
    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false
    vim.api.nvim_buf_clear_namespace(buf, NS, 0, -1)
    for _, m in ipairs(marks) do
        vim.api.nvim_buf_set_extmark(buf, NS, m.line, 2, { end_col = 2 + m.len, hl_group = m.group })
    end
    for i, line in ipairs(lines) do
        if line ~= '' and not vim.startswith(line, ' ') and i > 1 then
            vim.api.nvim_buf_set_extmark(buf, NS, i - 1, 0, { end_col = #line, hl_group = 'Title' })
        end
    end
    for _, win in ipairs(vim.fn.win_findbuf(buf)) do
        local height = math.min(#lines, 15)
        local ok, err = pcall(vim.api.nvim_win_set_height, win, height)
        if not ok then
            vim.notify(SRC .. 'window height: ' .. tostring(err), vim.log.levels.WARN)
        end
    end
end

return M
