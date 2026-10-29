local M = {}

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
end
return M
