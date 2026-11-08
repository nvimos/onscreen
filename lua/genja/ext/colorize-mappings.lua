--[=[

Highlight the right-hand side of vim.keymap.set(...) as Vimscript.

    vim.keymap.set('n', '<leader>x', [[<Cmd>exe "norm! yip" | '[,']sort<CR>]], opts)

The third argument, when it is a string, gets the `vim` treesitter parser
injected, so :commands, strings and <Cmd>/<CR> keys get colors.

How: the lua `injections` query (nvim runtime + nvim-treesitter) is read,
our rule is appended, and the result replaces it via vim.treesitter.query.set.
Needs the `vim` parser (lua/lazyp/my/load-treesitter.lua).

Setup: require('genja.ext.colorize-mappings').setup(), early, before lua buffers open.
Buffers already open keep their old injections until reopened (:e).

Also matches the alias `km(...)` (local km = vim.keymap.set in the map-*.lua files).
Other alias names: add them to the any-of list in ALIAS_RULE.

]=]

local M = {}

local SRC = 'lua/genja/ext/colorize-mappings.lua: '

-- third argument of vim.keymap.set, when it is a string
local RULE = [[
(function_call
  name: (dot_index_expression
    table: (dot_index_expression
      table: (identifier) @_vim
      field: (identifier) @_keymap)
    field: (identifier) @_set)
  arguments: (arguments
    .
    (_)
    .
    (_)
    .
    (string content: (string_content) @injection.content))
  (#eq? @_vim "vim")
  (#eq? @_keymap "keymap")
  (#eq? @_set "set")
  (#set! injection.language "vim"))
]]

-- same for the alias km(...)
local ALIAS_RULE = [[
(function_call
  name: (identifier) @_alias
  arguments: (arguments
    .
    (_)
    .
    (_)
    .
    (string content: (string_content) @injection.content))
  (#any-of? @_alias "km")
  (#set! injection.language "vim"))
]]

function M.setup()
    local parts = {}
    for _, path in ipairs(vim.treesitter.query.get_files('lua', 'injections')) do
        local f = io.open(path, 'r')
        if f then
            table.insert(parts, f:read('*a'))
            f:close()
        end
    end
    table.insert(parts, RULE)
    table.insert(parts, ALIAS_RULE)

    -- a broken rule must not break lua highlighting
    local ok, err = pcall(vim.treesitter.query.set, 'lua', 'injections', table.concat(parts, '\n'))
    if not ok then
        vim.notify(SRC .. 'query rejected: ' .. tostring(err), vim.log.levels.WARN)
    end
end

return M
