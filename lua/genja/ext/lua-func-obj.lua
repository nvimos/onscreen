-- if / af textobjects for Lua functions, from the treesitter tree (no plugin).
-- if: the body between `function(...)` and `end`; linewise when the body sits on its own lines.
-- af: the whole function; linewise for a declaration that fills its lines.
-- A count picks the n-th enclosing function.

local M = {}

local FUNC_TYPES = {
    function_declaration = true,
    function_definition = true,
}

---@return TSNode?
local function node_at_cursor()
    local ok, parser = pcall(vim.treesitter.get_parser, 0, 'lua')
    if not ok or not parser then
        return nil
    end
    parser:parse()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    -- in leading whitespace, look from the first non-blank
    local line = vim.api.nvim_get_current_line()
    local first = line:find('%S')
    if first and col < first - 1 then
        col = first - 1
    end
    return vim.treesitter.get_node({ bufnr = 0, pos = { row - 1, col }, lang = 'lua', ignore_injections = true })
end

---@param count integer
---@return TSNode?
local function find_function(count)
    local node = node_at_cursor()
    local found = nil
    while node do
        if FUNC_TYPES[node:type()] then
            found = node
            count = count - 1
            if count == 0 then
                return found
            end
        end
        node = node:parent()
    end
    return found
end

---@param node TSNode
---@param kind string
---@return TSNode?
local function child_of_type(node, kind)
    for child in node:iter_children() do
        if child:type() == kind then
            return child
        end
    end
    return nil
end

-- Select from (srow, scol) to (erow, ecol), 0-based, end inclusive.
local function select_range(mode, srow, scol, erow, ecol)
    if vim.api.nvim_get_mode().mode ~= mode then
        vim.cmd.normal({ mode, bang = true })
    end
    vim.api.nvim_win_set_cursor(0, { srow + 1, scol })
    vim.cmd.normal({ 'o', bang = true })
    vim.api.nvim_win_set_cursor(0, { erow + 1, ecol })
end

local function blank(text)
    return text:match('^%s*$') ~= nil
end

-- TS end positions are exclusive; turn one into the last selected char.
local function last_char(erow, ecol)
    if ecol > 0 then
        return erow, ecol - 1
    end
    local prev = vim.api.nvim_buf_get_lines(0, erow - 1, erow, false)[1] or ''
    return erow - 1, math.max(#prev - 1, 0)
end

function M.inner()
    local fn = find_function(vim.v.count1)
    if not fn then
        return
    end
    local params = child_of_type(fn, 'parameters')
    local body = fn:field('body')[1]
    local end_kw = fn:child(fn:child_count() - 1)
    if not params or not end_kw then
        return
    end
    local _, _, prow, pcol = params:range()
    local erow, ecol = end_kw:range()
    local params_line = vim.api.nvim_buf_get_lines(0, prow, prow + 1, false)[1]
    local end_line = vim.api.nvim_buf_get_lines(0, erow, erow + 1, false)[1]

    -- `function(...)` and `end` close their lines: every line between, comments included
    if erow - prow >= 2 and blank(params_line:sub(pcol + 1)) and blank(end_line:sub(1, ecol)) then
        select_range('V', prow + 1, 0, erow - 1, 0)
        return
    end

    if not body then
        return
    end
    local srow, scol, brow, bcol = body:range()
    select_range('v', srow, scol, last_char(brow, bcol))
end

function M.outer()
    local fn = find_function(vim.v.count1)
    if not fn then
        return
    end
    local srow, scol, erow, ecol = fn:range()
    local first = vim.api.nvim_buf_get_lines(0, srow, srow + 1, false)[1]
    local final = vim.api.nvim_buf_get_lines(0, erow, erow + 1, false)[1] or ''
    if fn:type() == 'function_declaration' and blank(first:sub(1, scol)) and blank(final:sub(ecol + 1)) then
        select_range('V', srow, 0, erow, 0)
        return
    end
    select_range('v', srow, scol, last_char(erow, ecol))
end

return M
