-- blink.cmp source from minuet-ai.nvim (lua/lazyp/langs-comps/minuet.lua).
-- Lives in the config, not in genja-completion011: its own sources need no extra plugins.
-- Listed after 'keymaps' in the features, since that feature replaces config.keymap.

---Did this request ask for minuet alone (<M-y>)? blink's trigger context holds the providers asked for.
---@return boolean
local function asked_alone()
    local ok, trigger = pcall(require, 'blink.cmp.completion.trigger')
    local providers = ok and trigger.context and trigger.context.providers or {}
    return #providers == 1 and providers[1] == 'minuet'
end

---@type genja.completion.Feature
return function(config)
    table.insert(config.sources.default, 'minuet')
    config.sources.providers.minuet = {
        name = 'minuet',
        module = 'minuet.blink',
        async = true,
        timeout_ms = 14000, -- gemini's worst case with one retry (curl_args in lua/lazyp/langs-comps/minuet.lua)
        score_offset = 50, -- README value: above buffer words
        -- <Tab>'s show() is a manual trigger too, and minuet answers every manual one; so it only
        -- runs for <M-y>, or for everything after :Minuet blink toggle (<leader>aM)
        enabled = function()
            if asked_alone() then
                return true
            end
            local minuet = package.loaded['minuet']
            return minuet ~= nil and minuet.config ~= nil and minuet.config.blink.enable_auto_complete == true
        end,
    }
    config.keymap['<M-y>'] = {
        function(cmp)
            cmp.show({ providers = { 'minuet' } })
        end,
    }
end
