-- :Toggle and :Cycle for options (lua/genja/ext/opt-cycle.lua).
local function oc() return require('genja.ext.opt-cycle') end

vim.api.nvim_create_user_command('Toggle', function(o) oc().toggle(o.args) end, {
    nargs = 1,
    bar = true,
    complete = function(lead) return oc().complete_toggle(lead) end,
    desc = 'Option: flip a boolean',
})

vim.api.nvim_create_user_command('Cycle', function(o)
    local name = table.remove(o.fargs, 1)
    oc().cycle(name, o.fargs)
end, {
    nargs = '+',
    bar = true,
    complete = function(lead, line, pos) return oc().complete_cycle(lead, line, pos) end,
    desc = 'Option: next value',
})
