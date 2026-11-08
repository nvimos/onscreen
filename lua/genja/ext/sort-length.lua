--[[

:[range]SortLen[!]  sort lines by their length, shortest first; ! reverses, like :sort!

Vim's :sort can't compare lengths: its patterns only pick the text to compare.
So the lines are sorted here in Lua. Length is counted in characters, not bytes.
Lines of equal length keep their order, also with !.

Keys: lua/genja/map-convoluted.lua (visual).

]]

local M = {}

---@param line1 integer
---@param line2 integer
---@param reverse boolean
function M.sort(line1, line2, reverse)
    local lines = vim.api.nvim_buf_get_lines(0, line1 - 1, line2, false)

    local items = {}
    for i, text in ipairs(lines) do
        table.insert(items, { text = text, len = vim.fn.strchars(text), pos = i })
    end

    table.sort(items, function(a, b)
        if a.len ~= b.len then
            if reverse then
                return a.len > b.len
            end
            return a.len < b.len
        end
        return a.pos < b.pos
    end)

    local sorted = {}
    for _, item in ipairs(items) do
        table.insert(sorted, item.text)
    end
    vim.api.nvim_buf_set_lines(0, line1 - 1, line2, false, sorted)
end

--- :[range]SortLen[!]
function M.setup_command()
    vim.api.nvim_create_user_command('SortLen', function(o)
        M.sort(o.line1, o.line2, o.bang)
    end, { range = '%', bang = true, desc = 'Edit: sort lines by length (! reverses)' })
end

return M
