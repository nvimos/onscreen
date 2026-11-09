local M = {}

---Move each channel of `hex` towards `target` by `share`.
---@param hex string '#rrggbb'
---@param target integer|string 0 (black), 255 (white) or another '#rrggbb'
---@param share number 0..1, how far to move towards target (the methods below take percent)
---@return string
local function shade(hex, target, share)
    local out = '#'
    for i = 2, 6, 2 do
        local channel = tonumber(hex:sub(i, i + 1), 16)
        local goal = target
        if type(target) == 'string' then
            goal = tonumber(target:sub(i, i + 1), 16)
        end
        out = out .. ('%02x'):format(math.floor(channel + (goal - channel) * share + 0.5))
    end
    return out
end

---@param percent number? 0..100
---@param default number
---@return number 0..1
local function share_of(percent, default)
    return math.max(0, math.min(100, percent or default)) / 100
end

local ColorTable = {
    props = {},
    new = function(self)
        local clone = {}
        for prop, fn in pairs(self) do if type(fn) ~= 'function' then clone[prop] = fn end end
        return setmetatable(clone, { __index = self, __call = self.fgbg })
    end,
    fgbg = function(self, fg, bg)
        self.props = {}
        self.props['fg'] = fg
        self.props['bg'] = bg
        return self
    end,
    bold = function(self)
        self.props['bold'] = true; return self
    end,
    -- darken / lighten: move fg and bg (whichever are set, '#rrggbb') that many percent (0..100) towards black / white
    darken = function(self, percent)
        local share = share_of(percent, 20)
        for _, key in ipairs({ 'fg', 'bg' }) do
            if self.props[key] then self.props[key] = shade(self.props[key], 0, share) end
        end
        return self
    end,
    lighten = function(self, percent)
        local share = share_of(percent, 20)
        for _, key in ipairs({ 'fg', 'bg' }) do
            if self.props[key] then self.props[key] = shade(self.props[key], 255, share) end
        end
        return self
    end,
    -- blend: move fg and bg (whichever are set) that many percent (0..100) towards another '#rrggbb';
    -- 0 keeps the color, 100 becomes `other`
    blend = function(self, other, percent)
        local share = share_of(percent, 50)
        for _, key in ipairs({ 'fg', 'bg' }) do
            if self.props[key] then self.props[key] = shade(self.props[key], other, share) end
        end
        return self
    end,
    -- bg_from: start from the background of a highlight group (resolved now, links followed); black when it has none
    bg_from = function(self, group)
        local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
        self.props = { bg = ('#%06x'):format(hl.bg or 0) }
        return self
    end,
    t = function(self) return self.props end,
}

local cc = ColorTable:new()

---Highlight groups that the colorscheme doesn't set.
function M.setup()
    vim.api.nvim_set_hl(0, 'Git', cc("#f14e32"):bold():t())

    vim.api.nvim_set_hl(0, 'TelescopeBorder',       cc('#202020'):bold():t())
    vim.api.nvim_set_hl(0, 'TelescopeBorder',       cc('#606060'):bold():t())
    vim.api.nvim_set_hl(0, 'TelescopeSelection',    cc('#B5642F'):t())
    vim.api.nvim_set_hl(0, 'TelescopeNormal',       cc('#AAAAAA'):t())
    vim.api.nvim_set_hl(0, 'TelescopePromptNormal', cc('#AAAAAA'):t())
    vim.api.nvim_set_hl(0, 'TelescopePromptTitle',  cc('#AAAAAA'):t())

    -- Matched chars in pickers: Visual's foreground and bold, no background.
    local visual = vim.api.nvim_get_hl(0, { name = 'Visual', link = false })
    vim.api.nvim_set_hl(0, 'TelescopeMatching', { fg = visual.fg, bold = visual.bold })

    -- {{{ diffview: left side red, right side green
    -- Remove this fold, `M.diffview_colors`, `M.diffview_sides` below and the hook in lua/lazyp/git/diffview.lua to go back to the colorscheme's diff colors.
    M.diffview_colors()
    vim.api.nvim_create_autocmd('ColorScheme', {
        group = vim.api.nvim_create_augroup('genja_diff_colors', { clear = true }),
        callback = M.diffview_colors,
    })
    -- }}}
end

-- {{{ diffview: left side red, right side green (see the fold in M.setup)
-- Each group starts from the Normal background and is blended with a very dark red / green, so it follows the colorscheme.
-- The percentages say how much of the dark color replaces the background; the targets are barely lighter than black.
local DARK_RED = { line = '#291308', underline = '#3a1010' }
local DARK_GREEN = { line = '#06200a', underline = '#0d3014' }
local BLEND_LINE = 70 -- changed lines
local BLEND_WORD = 80 -- changed words: barely above the line's
local BLEND_UNDERLINE = 90 -- underline under the changed words

---@param dark { line: string, underline: string }
---@return table line, table word the line group and the word group (with a faint underline)
local function diff_groups(dark)
    local line = cc():bg_from('Normal'):blend(dark.line, BLEND_LINE):t()
    local word = cc():bg_from('Normal'):blend(dark.line, BLEND_WORD):t()
    word.underline = true
    word.sp = cc():bg_from('Normal'):blend(dark.underline, BLEND_UNDERLINE):t().bg
    return line, word
end

function M.diffview_colors()
    local add, add_word = diff_groups(DARK_GREEN)
    local delete, delete_word = diff_groups(DARK_RED)
    vim.api.nvim_set_hl(0, 'GenjaDiffAdd', add)
    vim.api.nvim_set_hl(0, 'GenjaDiffAddText', add_word)
    vim.api.nvim_set_hl(0, 'GenjaDiffDelete', delete)
    vim.api.nvim_set_hl(0, 'GenjaDiffDeleteText', delete_word)
    vim.api.nvim_set_hl(0, 'GenjaDiffFill', { fg = cc():bg_from('Normal'):lighten(12):t().bg })
end

-- diffview hook `diff_buf_win_enter`: per-window highlight remap; in two panes the side "a" is the old file, "b" the new one.
---@param ctx { symbol: string?, layout_name: string }
function M.diffview_sides(ctx)
    if ctx.layout_name == 'diff1_inline' then
        -- one window: added and changed lines green, deleted lines (virtual lines) red; the groups are the ones the
        -- inline renderer puts on its extmarks. DiffviewDiffDeleteInline (overleaf strikethrough) keeps its own colors.
        vim.opt_local.winhl = 'DiffviewDiffAdd:GenjaDiffAdd,DiffviewDiffChange:GenjaDiffAdd,'
            .. 'DiffviewDiffTextInline:GenjaDiffAddText,DiffviewDiffAddInline:GenjaDiffAddText,'
            .. 'DiffviewDiffDelete:GenjaDiffDelete'
        return
    end
    if not ctx.layout_name:match('^diff2') then
        return
    end
    if ctx.symbol == 'a' then
        vim.opt_local.winhl = 'DiffAdd:GenjaDiffDelete,DiffChange:GenjaDiffDelete,'
            .. 'DiffText:GenjaDiffDeleteText,DiffDelete:GenjaDiffFill'
    elseif ctx.symbol == 'b' then
        vim.opt_local.winhl = 'DiffAdd:GenjaDiffAdd,DiffChange:GenjaDiffAdd,'
            .. 'DiffText:GenjaDiffAddText,DiffDelete:GenjaDiffFill'
    end
end
-- }}}

return M
