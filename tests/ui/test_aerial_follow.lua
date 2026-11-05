-- aerial (lua/lazyp/ui/aerial.lua, attach_mode 'global'): the sidebar opened with the <leader>mo /
-- <leader>oo keys (:AerialToggle!) follows the file shown in the source window; after :edit of
-- another file it outlines that file, not the old one (todo-ideas.md "aerial", auto-todo J).
-- Boots the real config; two of its own Lua files are the samples.

local child = MiniTest.new_child_neovim()
local eq = MiniTest.expect.equality

local CONFIG = vim.fs.normalize(vim.fn.stdpath('config'))
local FILE_A = CONFIG .. '/lua/genja/plug-wip.lua'
local FILE_B = CONFIG .. '/lua/genja/api.lua'

local T = MiniTest.new_set({
    hooks = {
        pre_once = function()
            require('helpers.real-config').boot_child(child)
        end,
        post_once = function()
            child.stop()
        end,
    },
})

---Name of the file the aerial sidebar outlines, or false while there is no sidebar.
local function outlined()
    return child.lua([[
        local util = require('aerial.util')
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            local buf = vim.api.nvim_win_get_buf(win)
            if util.is_aerial_buffer(buf) then
                local src = util.get_source_buffer(buf)
                if src and vim.api.nvim_buf_is_valid(src) then
                    return vim.fs.normalize(vim.api.nvim_buf_get_name(src))
                end
            end
        end
        return false
    ]])
end

T['sidebar follows :edit in the source window'] = function()
    local H = require('helpers.timing')
    child.cmd('edit ' .. vim.fn.fnameescape(FILE_A))
    child.cmd('AerialToggle!')
    eq(H.wait(function() return outlined() == FILE_A end, 5000), true)

    child.cmd('edit ' .. vim.fn.fnameescape(FILE_B))
    eq(H.wait(function() return outlined() == FILE_B end, 5000), true)
end

return T
