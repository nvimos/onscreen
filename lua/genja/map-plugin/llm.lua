-- Keys and mappings for lua/lazyp/unused-failed/llm.lua.
-- Disabled with the spec (2026-10-31): no ghost text on nvim 0.13, see the spec's header.
-- Insert-mode accept/dismiss are llm.nvim's own (accept_keymap, dismiss_keymap in the spec).

---@param Maps genja.MapPlugin
return function(Maps)
    local spec_name = Maps.current_file()

    Maps:add_keys(spec_name, {
        -- { '<leader>al', '<cmd>LLMToggleAutoSuggest<cr>', desc = 'LLM: auto-suggest toggle (llm.nvim)', silent = true },
    })

    Maps:add_mappings(spec_name, function(_) end)
end
