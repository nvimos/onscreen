-- Keys and mappings for lua/lazyp/langs-comps/minuet.lua.
-- Insert-mode ghost text keys are minuet's own (opts.virtualtext.keymap in the spec);
-- the blink key is in lua/genja/completion/minuet.lua.

---@param Maps genja.MapPlugin
return function(Maps)
    local spec_name = Maps.current_file()

    Maps:add_keys(spec_name, {
        { '<leader>am', '<cmd>Minuet virtualtext toggle<cr>', desc = 'Minuet: ghost text toggle (buffer)', silent = true },
        { '<leader>aM', '<cmd>Minuet blink toggle<cr>',       desc = 'Minuet: blink auto-complete toggle', silent = true },
    })

    Maps:add_mappings(spec_name, function(_) end)
end
