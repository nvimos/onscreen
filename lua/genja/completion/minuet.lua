-- blink.cmp source from minuet-ai.nvim (lua/lazyp/langs-comps/minuet.lua).
-- Lives in the config, not in genja-completion011: its own sources need no extra plugins.
-- Listed after 'keymaps' in the features, since that feature replaces config.keymap.
---@type genja.completion.Feature
return function(config)
    table.insert(config.sources.default, 'minuet')
    config.sources.providers.minuet = {
        name = 'minuet',
        module = 'minuet.blink',
        async = true,
        timeout_ms = 3000, -- minuet's request_timeout * 1000
        score_offset = 50, -- README value: above buffer words
    }
    -- manual trigger; answers even while minuet's blink auto-complete is off
    config.keymap['<M-y>'] = {
        function(cmp)
            cmp.show({ providers = { 'minuet' } })
        end,
    }
end
