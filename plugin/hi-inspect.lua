-- :HiInspect: highlight groups under the cursor in a split (lua/genja/ext/hi-inspect.lua).
vim.api.nvim_create_user_command('HiInspect', function()
    require('genja.ext.hi-inspect').show()
end, {
    desc = 'Highlight: groups under the cursor, link chains and colours, in a split',
})
