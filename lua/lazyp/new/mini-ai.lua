-- mini.ai: a/i textobjects with next/last (`ciNf`, `daLc`), treesitter ids from nvim-treesitter-textobjects queries.
-- Upstream moved from echasnovski/mini.ai to nvim-mini/mini.ai.
-- Without mini.ai, after/ftplugin/lua.lua maps if/af itself (lua/genja/ext/lua-func-obj.lua).
-- Brackets, quotes and `_` are mini.ai defaults; not redefined here.
--
-- Next / last on aN iN / aL iL instead of mini.ai's an in / al il, which override nvim defaults
-- (deliberate upstream: :help MiniAi-default-an-in, MiniAi-default-al-il; aN iN aL iL is its suggested way out):
--   an / in (x, o): nvim 0.12+ selects the parent / child treesitter node (v_an, v_in).
--   al / il (x, o): nvim 0.13+ selects the whole buffer / the line without surrounding blanks (v_al, v_il).
-- kickstart.nvim uses aa / ii for next instead; that collides with mini.ai's argument object (aa / ia).
-- Visual <C-s> / <BS> also select by node (lua/genja/map-plugin/load-treesitter.lua, nvim 0.13+).
-- Other ids:
--   f: mini.ai's own default is a function call; replaced by the treesitter function definition.
--   if / af: no nvim default; after/ftplugin/lua.lua maps them only when mini.ai is not installed.
-- Check: :verbose xmap an shows the nvim default as owner; :help v_an, :help v_al the defaults;
-- nvim --clean some.lua, then van / vin / val / vil to try them without this config.

---@type LazySpec
return {
    'nvim-mini/mini.ai',
    version = false,
    event = 'VeryLazy',
    dependencies = {
        { 'nvim-treesitter/nvim-treesitter-textobjects', branch = 'main' },
    },
    config = function()
        local ai = require('mini.ai')
        ai.setup({
            n_lines = 5001,
            mappings = {
                around_next = 'aN',
                inside_next = 'iN',
                around_last = 'aL',
                inside_last = 'iL',
            },
            custom_textobjects = {
                f = ai.gen_spec.treesitter({ a = '@function.outer', i = '@function.inner' }),
                c = ai.gen_spec.treesitter({ a = '@class.outer', i = '@class.inner' }),
                o = ai.gen_spec.treesitter({
                    a = { '@conditional.outer', '@loop.outer' },
                    i = { '@conditional.inner', '@loop.inner' },
                }),
            },
        })
    end,
}
