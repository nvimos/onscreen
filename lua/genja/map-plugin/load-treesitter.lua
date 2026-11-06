-- Keys for lua/lazyp/my/load-treesitter.lua.
-- Incremental selection as in vermaden's nvim-treesitter.lua (incremental_selection: <C-s> grow, <BS> shrink):
-- https://github.com/vermaden/scripts/raw/master/distfiles/nvim-lua-plugins.tar.gz
-- (from https://vermaden.wordpress.com/2024/03/13/perfect-neovim-ansible-setup/)
-- nvim-treesitter main dropped incremental_selection; this uses the built-in vim.treesitter.select.
--
-- Versions and clashes:
--   nvim 0.12: defaults v_an v_in v_]n v_[n (node selection); vim.treesitter.select is not public yet,
--              so these keys are skipped there and only the defaults exist.
--   nvim 0.13: vim.treesitter.select() public; defaults v_]N v_[N added.
--   mini.ai (lua/lazyp/new/mini-ai.lua) has next / last on aN iN / aL iL, so the defaults
--   an / in (0.12) and al / il (0.13) stay; <C-s> / <BS> are a second way to select by node.
--   <BS> in visual: by default only acts in Select mode (v_<BS>, delete); mapped for 'x' only, Select mode keeps it.
--   <C-s> in visual: no default. In normal mode <C-s> is aerial's outline toggle
--   (lua/genja/map-plugin/aerial.lua), so start with v<C-s>.
--
-- Check the defaults: :help v_an, :help v_<BS>; who owns a key now: :verbose xmap an, :verbose xmap <BS>.
-- Try them without this config: nvim --clean some.lua, then van / vin / v]n.

---@param Maps genja.MapPlugin
return function(Maps)
    local spec_name = Maps.current_file()

    Maps:add_mappings(spec_name, function(_)
        -- vim.treesitter.select arrived after 0.11
        if not vim.treesitter.select then
            return
        end
        vim.keymap.set('x', '<C-s>', function()
            vim.treesitter.select('parent', vim.v.count1)
        end, { desc = 'Select: grow to parent node (treesitter)' })
        vim.keymap.set('x', '<BS>', function()
            vim.treesitter.select('child', vim.v.count1)
        end, { desc = 'Select: shrink to child node (treesitter)' })
    end)
end
