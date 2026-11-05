-- nvim-dap-view: one debug window with sections in its winbar, a lighter alternative to nvim-dap-ui.
-- Under evaluation next to dap-ui (todo-test/php-debug.md, step 7). Keys: lua/genja/map-plugin/dap-view.lua.
local Maps = require('genja.map-plugin')

---@type LazySpec
return {
    'igorlfs/nvim-dap-view',
    dependencies = { 'mfussenegger/nvim-dap' },
    cmd = { 'DapViewOpen', 'DapViewClose', 'DapViewToggle', 'DapViewWatch', 'DapViewJump', 'DapViewShow', 'DapViewHover' },
    keys = Maps:keys(),
    opts = {
        winbar = {
            -- Stack (threads) and breakpoints matter most; opens on the stack.
            sections = { 'threads', 'breakpoints', 'scopes', 'watches', 'repl' },
            default_section = 'threads',
        },
        -- Vertical split right of the code (default: below).
        windows = {
            position = 'right',
        },
    },
}
