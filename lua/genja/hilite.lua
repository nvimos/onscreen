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

    -- {{{ markdown headings: pale indigo, markdown files only
    -- Remove this fold and `M.markdown_headings` below to go back to the colorscheme's heading colors.
    M.markdown_headings()
    M.markdown_comment()
    M.markdown_code()
    M.folded()
    M.diag_float()
    M.fold_column()
    M.color_column()
    vim.api.nvim_create_autocmd('ColorScheme', {
        group = vim.api.nvim_create_augroup('genja_md_heading_colors', { clear = true }),
        callback = function()
            M.markdown_headings()
            M.markdown_comment()
            M.markdown_code()
            M.folded()
            M.diag_float()
            M.fold_column()
            M.color_column()
        end,
    })
    -- }}}
end

-- {{{ markdown headings (see the fold in M.setup)
-- Only markdown's own groups (the `.markdown` treesitter captures and the markdown syntax groups), so
-- other filetypes keep the colorscheme's heading color.
-- lua/genja/hilite.vim has the same color as a fallback (group MdHeading); change both.
-- local HEADING_COLOR = '#a5b4fc' -- pale indigo, to go back to; darken or lighten it with cc(HEADING_COLOR):darken(10)
local HEADING_COLOR = '#af4805' -- the StatusLine orange (`hi StatusLine guifg` in lua/genja/hilite.vim)

-- Hierarchy: levels 1 and 2 are bold in the full indigo, from level 3 each level steps a little darker and
-- plain, so the outline reads at a glance. The `#` markers are the same hue, darker: they recede and the
-- title text stands out. (hilite.vim's fallback keeps one color for all of them.)
local HEADING_BOLD_UNTIL = 2 -- levels up to this are bold
local HEADING_STEP = 6 -- percent darker per level below HEADING_BOLD_UNTIL
local HEADING_MARKER_DARKEN = 35 -- percent darker than the title text
local HEADING_MARKER_MAX = 45 -- the deepest levels' markers stop here, so they stay readable

-- cc() hands out one shared object, so each color is taken with :t() before the next cc() call.
---@param percent integer
---@return table
local function heading_shade(percent)
    if percent <= 0 then
        return cc(HEADING_COLOR):t()
    end
    return cc(HEADING_COLOR):darken(percent):t()
end

function M.markdown_headings()
    vim.api.nvim_set_hl(0, 'markdownHeadingDelimiter', heading_shade(HEADING_MARKER_DARKEN))

    for level = 1, 6 do
        local step = math.max(0, level - HEADING_BOLD_UNTIL) * HEADING_STEP
        local text = heading_shade(step)
        text.bold = level <= HEADING_BOLD_UNTIL
        local marker = heading_shade(math.min(step + HEADING_MARKER_DARKEN, HEADING_MARKER_MAX))
        vim.api.nvim_set_hl(0, 'markdownH' .. level, text)
        vim.api.nvim_set_hl(0, ('@markup.heading.%d.markdown'):format(level), text)
        vim.api.nvim_set_hl(0, ('@markup.heading.%d.marker.markdown'):format(level), marker)
    end
end

-- MdComment: gray text, no background, for <!-- --> comments. Highlight groups are global, so
-- the markdown windows swap the html comment groups for it (winhighlight, after/ftplugin/markdown.lua).
-- lua/genja/hilite.vim has the same color as a fallback; change both.
local COMMENT_FG = '#7d8590'

function M.markdown_comment()
    vim.api.nvim_set_hl(0, 'MdComment', cc(COMMENT_FG):darken(15):t())
end

-- Diagnostic float: the Normal background, a little lighter, so it stands out but stays dark. Used by the
-- diagnostic float only (lua/genja/ext/diag-float.lua sets the window's winhighlight to these groups).
local DIAG_FLOAT_LIGHTEN = 7 -- percent towards white

function M.diag_float()
    local bg = cc():bg_from('Normal'):lighten(DIAG_FLOAT_LIGHTEN):t().bg
    local border = vim.api.nvim_get_hl(0, { name = 'FloatBorder', link = false })
    vim.api.nvim_set_hl(0, 'GenjaDiagFloat', { bg = bg })
    vim.api.nvim_set_hl(0, 'GenjaDiagFloatBorder', { fg = border.fg, bg = bg })
end

-- The textwidth/colorcolumn stripe: the Normal background with only a little of the colorscheme's gray
-- in it, so it is barely there. The background is the dominant part of the blend.
local COLORCOLUMN_GRAY = '#303030' -- the colorscheme's ColorColumn background
local COLORCOLUMN_BLEND = 25 -- percent towards the gray: 0 is the background, 100 the gray

function M.color_column()
    local color = cc():bg_from('Normal'):blend(COLORCOLUMN_GRAY, COLORCOLUMN_BLEND):t()
    vim.api.nvim_set_hl(0, 'ColorColumn', color)
end

-- Fold column markers (every filetype; CursorLineFold links to it): hilite.vim's dark brown moved towards
-- the StatusLine orange, so the chrome shares the accent but stays far quieter than text. Starts from the
-- constant, like M.folded, so running it again doesn't blend twice.
local FOLDCOLUMN_FG = '#493423' -- same as `hi FoldColumn guifg` in lua/genja/hilite.vim; change both
local FOLDCOLUMN_BLEND = 60 -- percent towards the StatusLine orange: 0 is the brown, 100 is the orange
local FOLDCOLUMN_FADE = 30 -- percent towards the Normal background afterwards: more is quieter

function M.fold_column()
    local statusline = vim.api.nvim_get_hl(0, { name = 'StatusLine', link = false })
    if not statusline.fg then
        return -- no StatusLine color yet: hilite.vim's FoldColumn stays
    end
    local normal = vim.api.nvim_get_hl(0, { name = 'Normal', link = false })
    local color = cc(FOLDCOLUMN_FG):blend(('#%06x'):format(statusline.fg), FOLDCOLUMN_BLEND)
    color:blend(('#%06x'):format(normal.bg or 0), FOLDCOLUMN_FADE)
    color = color:t()
    vim.api.nvim_set_hl(0, 'FoldColumn', color)
end

-- Folded (the text of a closed fold, every filetype): lua/genja/hilite.vim's color blended towards the
-- Normal text color. It starts from the constant, not from the current group, so running it again
-- doesn't blend twice; the background stays as hilite.vim sets it.
local FOLDED_FG = '#a38652' -- same as `hi Folded guifg` in lua/genja/hilite.vim; change both
local FOLDED_BLEND = 60 -- percent towards the Normal text color

function M.folded()
    local normal = vim.api.nvim_get_hl(0, { name = 'Normal', link = false })
    if not normal.fg then
        return -- no Normal color yet: hilite.vim's Folded stays
    end
    local folded = vim.api.nvim_get_hl(0, { name = 'Folded', link = false })
    local color = cc(FOLDED_FG):blend(('#%06x'):format(normal.fg), FOLDED_BLEND):t()
    color.bg = folded.bg
    vim.api.nvim_set_hl(0, 'Folded', color)
end

-- Inline `code`: the StatusLine's foreground (the orange) blended towards the Normal text color, no
-- background. Both groups are markdown's own, so other filetypes are not touched.
-- lua/genja/hilite.vim has the plain orange as a fallback.
local CODE_BLEND = 65 -- percent towards the Normal text color: 0 is the StatusLine orange, 100 is the text

function M.markdown_code()
    local statusline = vim.api.nvim_get_hl(0, { name = 'StatusLine', link = false })
    if not statusline.fg then
        return -- no StatusLine color yet: the fallback in hilite.vim stays
    end
    local normal = vim.api.nvim_get_hl(0, { name = 'Normal', link = false })
    local orange = cc(('#%06x'):format(statusline.fg))
    if normal.fg then
        orange:blend(('#%06x'):format(normal.fg), CODE_BLEND)
    end
    local color = orange:t()
    vim.api.nvim_set_hl(0, '@markup.raw.markdown_inline', color)
    vim.api.nvim_set_hl(0, 'markdownCode', color)
end
-- }}}

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
