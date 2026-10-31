-- :CheckHealthSimpleMinuet: minuet's provider, model, API key and frontends in a float (lua/genja/ext/minuet-status.lua).
vim.api.nvim_create_user_command('CheckHealthSimpleMinuet', function()
    require('genja.ext.minuet-status').open()
end, {
    desc = 'Minuet: provider, model and API key status',
})
