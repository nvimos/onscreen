-- Diagnostic float (vim.diagnostic.open_float and the float of a diagnostic jump):
--   its own background, a little lighter than Normal, instead of the colorscheme's gray NormalFloat
--   (colors: M.diag_float in lua/genja/hilite.lua);
--   two columns of padding left of every line and an empty row below the last one, same background.
-- Other floats (hover, completion, ...) are not touched.
local SRC = 'lua/genja/ext/diag-float.lua: '

local M = {}

local WINHL = 'NormalFloat:GenjaDiagFloat,FloatBorder:GenjaDiagFloatBorder'
local PAD_COLS = 2 -- columns of padding left of every line

-- PAD_COLS spaces in front of every line and an empty line at the end. The text is inserted with
-- set_text, so the highlight extmarks the float already has move right with it; the window grows by
-- PAD_COLS columns and one row to fit.
---@param buf integer
---@param win integer
local function pad(buf, win)
    -- open_floating_preview focuses a float that is already open: padded already, leave it
    if vim.b[buf].genja_diag_padded == vim.api.nvim_buf_get_changedtick(buf) then
        return
    end
    local rows = vim.api.nvim_buf_line_count(buf)
    local was_modifiable = vim.bo[buf].modifiable
    vim.bo[buf].modifiable = true
    for row = 0, rows - 1 do
        vim.api.nvim_buf_set_text(buf, row, 0, row, 0, { (' '):rep(PAD_COLS) })
    end
    vim.api.nvim_buf_set_lines(buf, rows, rows, false, { '' })
    vim.bo[buf].modifiable = was_modifiable
    vim.b[buf].genja_diag_padded = vim.api.nvim_buf_get_changedtick(buf)

    vim.api.nvim_win_set_width(win, vim.api.nvim_win_get_width(win) + PAD_COLS)
    vim.api.nvim_win_set_height(win, vim.api.nvim_win_get_height(win) + 1)
end

function M.setup()
    -- vim.diagnostic._float.open does the work for open_float, the jump float and keymaps that hold
    -- vim.diagnostic.open_float; it is private API, so check it is there and wrap it only once.
    local float = vim.diagnostic._float
    if type(float) ~= 'table' or type(float.open) ~= 'function' then
        vim.notify(SRC .. 'vim.diagnostic._float.open not found, diagnostic float keeps NormalFloat', vim.log.levels.WARN)
        return
    end
    if float._genja_wrapped then
        return
    end
    local open = float.open
    float.open = function(...)
        local buf, win = open(...)
        if buf and win and vim.api.nvim_win_is_valid(win) then
            vim.wo[win].winhighlight = WINHL
            local ok, err = pcall(pad, buf, win)
            if not ok then
                vim.notify(SRC .. 'padding failed: ' .. tostring(err), vim.log.levels.WARN)
            end
        end
        return buf, win
    end
    float._genja_wrapped = true
end

return M
