-- if / af: function body / whole function (cif, daf, vif …)
-- mini.ai (lua/lazyp/new/mini-ai.lua) maps them everywhere; this is the fallback without it:
-- nvim-treesitter-textobjects (main branch) when installed, else lua/genja/ext/lua-func-obj.lua

-- lazy's registry: mini.ai may load later (VeryLazy) than this ftplugin runs
local has_lazy, lazy_config = pcall(require, 'lazy.core.config')
local mini_ai = has_lazy and lazy_config.plugins['mini.ai']
if mini_ai and mini_ai._.installed then
    return
end

local inner, outer
local has_ts_obj, ts_select = pcall(require, 'nvim-treesitter-textobjects.select')
if has_ts_obj then
    inner = function() ts_select.select_textobject('@function.inner', 'textobjects') end
    outer = function() ts_select.select_textobject('@function.outer', 'textobjects') end
else
    local lua_func = require('genja.ext.lua-func-obj')
    inner = lua_func.inner
    outer = lua_func.outer
end
vim.keymap.set({ 'x', 'o' }, 'if', inner, { buffer = true, desc = 'Lua: function body (textobject)' })
vim.keymap.set({ 'x', 'o' }, 'af', outer, { buffer = true, desc = 'Lua: function (textobject)' })
