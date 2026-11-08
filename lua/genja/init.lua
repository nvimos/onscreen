-- Genja init for nvim
--
-- vim.cmd 'colorscheme lunaperche'
--
vim.g.mapleader      = ' '
vim.g.maplocalleader = ','


-- -- new gui module
-- -- if vim.fn.has('nvim-0.13') == 1 then require('vim._core.ui2').enable({}) end ui2 ships with nvim 0.12

local Safeload = require('genja.api').Safeload


Safeload 'genja.env'
Safeload 'genja.map-zero'           -- stable early maps, if config breaks
Safeload 'genja.opt'                -- just static options
Safeload 'genja.opt-listchars'
Safeload 'genja.fu'                 -- userfuncs

require 'genja.fn'.win_chdir_home() -- cd ~ on windows

local C = vim.fn.stdpath('config')
vim.cmd('source ' .. C .. '/lua/genja/auto-alias.vim') -- aliases, onliners, autocommads, abbreviations
vim.cmd('source ' .. C .. '/lua/genja/abbreviations.vim') -- abbreviations
vim.cmd('source ' .. C .. '/lua/genja/hilite.vim')     -- colors
vim.cmd('source ' .. C .. '/lua/genja/fn.vim')

-- selene: allow(multiple_statements)
Safeload('genja.hilite', function(m) m.setup() end)
Safeload 'genja.ext.term' -- terminal cursor; after hilite, reads StatusLine color
Safeload 'genja.auto' -- autocommads
Safeload 'genja.lazy-plug-spec'
Safeload 'genja.map-lsp'
Safeload 'genja.map-telescope'
Safeload 'genja.ext.ui-select'          -- vim.ui.select in telescope (code actions etc.)
Safeload 'genja.map-convoluted'
-- selene: allow(multiple_statements)
Safeload('genja.ext.user-command.wrapfold', function(m) m.setup_user_command() end) -- :WrapFold
Safeload('genja.ext.user-command.sort-length', function(m) m.setup_user_command() end) -- :SortLen[!]
Safeload('genja.ext.user-command.reload-lua', function(m) m.setup_user_command() end) -- :ReloadLua {module}
Safeload('genja.ext.git-stop-fsmonitor', function(m) m.setup() end) -- :GitFsmonitorStop, and on exit
-- todo: move this somewhere fitting (treesitter config?)
Safeload('genja.ext.colorize-mappings', function(m) m.setup() end) -- vimscript colors in keymap rhs strings


-- start dirs: plug-wip/genja-startdirs.nvim, list in lua/genja/local/startdirs.txt
