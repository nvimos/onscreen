-- Markdown fold text: the fold's first line with treesitter highlights, no line count.
-- Set as 'foldtext' in after/ftplugin/markdown.lua.
-- This nvim has no vim.treesitter.foldtext (only vim.lsp.foldtext), hence the own version.

local M = {}

local LANG = 'markdown'

-- Highlight group per byte of the line (the last capture wins), from the markdown highlights query.
---@param buf integer
---@param row integer
---@param line string
---@return string[]
local function groups_per_byte(buf, row, line)
    local groups = {}
    local parser = vim.treesitter.get_parser(buf, LANG)
    local query = vim.treesitter.query.get(LANG, 'highlights')
    if not parser or not query then
        return groups
    end
    local tree = parser:parse({ row, row + 1 })[1]
    for id, node in query:iter_captures(tree:root(), buf, row, row + 1) do
        local name = query.captures[id]
        if name:sub(1, 1) ~= '_' then
            local srow, scol, erow, ecol = node:range()
            local from = (srow == row) and scol or 0
            local to = (erow == row) and ecol or #line
            for col = from + 1, to do
                groups[col] = '@' .. name .. '.' .. LANG
            end
        end
    end
    return groups
end

-- Chunks {text, group}: runs of bytes that share a group, 'Folded' where nothing is captured.
---@return string|table
function M.text()
    local buf = vim.api.nvim_get_current_buf()
    local row = vim.v.foldstart - 1
    local line = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1] or ''

    -- Never throw from a 'foldtext': a failure shows as "0". No parser or query: the plain line.
    local ok, groups = pcall(groups_per_byte, buf, row, line)
    if not ok then
        return line
    end

    local chunks = {}
    local start = 1
    while start <= #line do
        local group = groups[start]
        local stop = start
        while stop < #line and groups[stop + 1] == group do
            stop = stop + 1
        end
        table.insert(chunks, { line:sub(start, stop), group or 'Folded' })
        start = stop + 1
    end
    if #chunks == 0 then
        return line
    end
    return chunks
end

return M
