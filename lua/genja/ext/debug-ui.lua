-- Debug UI: open dap-ui when a session first stops, in its own tab or in the current one; close it at the end.
-- Switches, also at runtime with :let (read at each open):
--   g:genja_debug_auto_open  v:true (default): open on the first stop; v:false: only when toggled by hand
--   g:genja_debug_layout     'tab' (default): dap-ui in a new tab; 'split': splits in the current tab
-- Called from lua/lazyp/debug/dap-php.lua.
local M = {}

if vim.g.genja_debug_auto_open == nil then
    vim.g.genja_debug_auto_open = true
end
if vim.g.genja_debug_layout == nil then
    vim.g.genja_debug_layout = 'tab'
end

---@type integer|nil  tab opened for this session
local debug_tab = nil
-- Opened once per session: after <leader>du closes it, later stops leave it closed.
local opened = false

-- First stop of a session: open the UI unless switched off. Runs before dap jumps to the frame,
-- so the jump lands in the new tab.
function M.on_stopped()
    if opened or not vim.g.genja_debug_auto_open then
        return
    end
    opened = true
    M.open()
end

function M.open()
    if vim.g.genja_debug_layout == 'tab' then
        if debug_tab and vim.api.nvim_tabpage_is_valid(debug_tab) then
            vim.api.nvim_set_current_tabpage(debug_tab)
        else
            vim.cmd('tab split')
            debug_tab = vim.api.nvim_get_current_tabpage()
        end
    end
    require('dapui').open()
end

-- Session ended: close dap-ui, dap-view and the session's tab.
function M.close()
    pcall(function() require('dapui').close() end)
    if package.loaded['dap-view'] then
        require('dap-view').close()
    end
    if debug_tab and vim.api.nvim_tabpage_is_valid(debug_tab) and #vim.api.nvim_list_tabpages() > 1 then
        vim.cmd('tabclose ' .. vim.api.nvim_tabpage_get_number(debug_tab))
    end
    debug_tab = nil
    opened = false
end

return M
