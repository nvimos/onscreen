-- <F2> group names, one symbol per group, so tasks refer to a name, not a string:
--   local groups = require('genja.f2').groups
--   f2.add_task(groups.this_file, 'run with pwsh') ...
-- At most 14 chars each (readme.md). Collectors require this module directly
-- (genja.f2 loads the collectors, so requiring it from them would be circular).

-- todo: should be extendable by arbitrary callers via "api" function from this module
return {
    this_file = 'this file (%)',
    markdown  = 'markdown',
    script    = 'script',
    claude    = 'claude',
    lookup    = 'lookup',
    adhoc     = 'adhoc',
    diag      = 'diag',
    make      = 'make',
    msgs      = 'msgs',
    lsp       = 'lsp',
    git       = 'git',
    oil       = 'oil',
    gui       = 'gui',
}
