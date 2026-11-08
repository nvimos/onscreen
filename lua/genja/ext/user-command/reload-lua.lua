-- :ReloadLua2 {module}  uncache, require again, redraw; completes package.loaded
-- Dense twin of reload-lua.lua, for comparing.

local function complete_loaded_modules(lead)
    local names = vim.tbl_filter(
        function(n) return vim.startswith(n, lead) end,
        vim.tbl_keys(package.loaded))
    table.sort(names)
    return names
end

return {
    setup_user_command = function()
        vim.api.nvim_create_user_command('ReloadLua2',
            function(o)
                package.loaded[o.args] = nil
                local ok, err = pcall(require, o.args)
                if not ok then return vim.notify(err, vim.log.levels.ERROR) end
                vim.cmd('redrawstatus! | redrawtabline')
            end,
            {
                nargs = 1,
                complete = complete_loaded_modules,
                desc = 'Lua: reload a loaded module'
            })
    end
}
