-- Keys for lua/lazyp/new/dap-view.lua.

---@param Maps genja.MapPlugin
return function(Maps)
    local spec_name = Maps.current_file()

    Maps:add_keys(spec_name, {
        { '<leader>dv', '<Cmd>DapViewToggle<CR>', desc = 'Debug: toggle view (dap-view)' },
    })
end
