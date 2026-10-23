local ok, tsbuiltin = pcall(require, 'telescope.builtin')
if not ok then
	vim.notify('there is no module: telescope.builtin')
	return
end

local km = vim.keymap.set
local nosi = function(d) return { silent = true, noremap = true, desc = d } end

local F = require('genja.map-telescope.fn')

-- Telescope:
-- frequently used
km('n', '<F1>',   F.genja_finder_grep, nosi 'Telescope: grep files (genja-finder)')
km('n', '<S-F1>', F.genja_finder_find, nosi 'Telescope: find files (genja-finder)')


km('n', '<C-F1>', F.oldfiles,       nosi 'Telescope: oldfiles (<M-f> filter)') -- Nb! hhkb2: fn-ctrl-1 is not the same as ctrl-fn-1
km('n', '<F2>',   F.context_picker, nosi 'Telescope: context picker (adhoc, git, make, added tasks)')

km('n', 'g.',             F.action_menu, nosi 'Telescope: actions here (cur: = item under cursor)')
km('n', '<LocalLeader>/', F.action_menu, nosi 'Telescope: actions here (cur: = item under cursor)')


-- browse / find
km('n', '<leader>j?',  tsbuiltin.builtin,    nosi 'Telescope: builtin') -- browse telescopes' pickers
km('n', '<leader>j/.', tsbuiltin.find_files, nosi 'Telescope: find_files')
km('n', '<leader>j//', F.find_in_startdirs,  nosi 'Telescope: find in START_DIRS')
km('n', '<leader>jd',  F.find_in_startdirs,  nosi 'Telescope: find in START_DIRS')
km('n', '<leader>jo',  F.oldfiles,           nosi 'Telescope: oldfiles')
km('n', '<leader>js',  F.grep_string,        nosi 'Telescope: grep string')

-- vim help, inspect state
km('n', '<leader>1',  tsbuiltin.help_tags,     nosi 'Telescope: Vim help') -- dup-help-tags
km('n', '<leader>4',  tsbuiltin.buffers,       nosi 'Telescope: buffers')

km('n', '<leader>jbo',  tsbuiltin.vim_options,  nosi 'Telescope: vim_options')
km('n', '<leader>jbc',  tsbuiltin.colorscheme,  nosi 'Telescope: colorscheme')
km('n', '<leader>jbk',  tsbuiltin.keymaps,      nosi 'Telescope: keymaps')
km('n', '<leader>jb?',  tsbuiltin.keymaps,      nosi 'Telescope: keymaps')
km('n', '<leader>jba',  tsbuiltin.autocommands, nosi 'Telescope: autocommands')
km('n', '<leader>jbb',  tsbuiltin.buffers,      nosi 'Telescope: buffers')
km('n', '<leader>jbh',  tsbuiltin.help_tags,    nosi 'Telescope: help_tags')
km('n', '<leader>jbg',  tsbuiltin.git_files,    nosi 'Telescope: git_files')
km('n', '<leader>jbr',  tsbuiltin.registers,    nosi 'Telescope: registers')
km('n', '<leader>jb\'', tsbuiltin.marks,        nosi 'Telescope: marks')
km('n', '<leader>jj1',  tsbuiltin.quickfix,     nosi 'Telescope: quickfix')
km('n', '<leader>jj2',  tsbuiltin.loclist,      nosi 'Telescope: loclist')

-- grep
km('n', '<leader>jjJ', F.genja_finder_grep,  nosi 'Telescope: genja grep')
km('n', '<leader>jjj', F.genja_finder_find,  nosi 'Telescope: genja find')



--- vim.keymap.set('', '<S-F2>', ':edit ~/AppData/Local/nvim/lua/mymap.lua<CR>')
--- vim.keymap.set('', '<S-F1>', ':edit ~/AppData/Local/nvim/lua/plugins.lua<CR>')
--- vim.keymap.set('',   '<F1>', ':edit ~/AppData/Local/nvim/init.lua<CR>')

-- km('n', '<leader>ff', te.find_files, nosi 'Telescope find_files')
-- km('n', '<leader>fg', te.live_grep, nosi 'Telescope live_grep')
-- km('n', '<leader>fb', te.buffers, nosi 'Telescobe buffers')
-- km('n', '<leader>fh', te.help_tags, nosi 'Telescope help_tags')
--km('n', '<leader>pf', te.find_files, {})
--km('n', '<C-p>', te.git_files, {})
--km('n', '<leader>vh', te.help_tags, {})

-- Keys inside pickers. telescope.setup() in after/plugin/telescope-after.lua merges these.
-- <Tab> marks entries. Alt: send the marked ones, Alt+Shift: append them, Ctrl: send all results.
-- l = location list, q = quickfix list (<C-q>/<M-q> are telescope defaults, listed here for the set).
local actions = require('telescope.actions')
local list_keys = {
	['<M-l>'] = actions.send_selected_to_loclist + actions.open_loclist,
	['<M-L>'] = actions.add_selected_to_loclist + actions.open_loclist,
	['<C-l>'] = actions.send_to_loclist + actions.open_loclist,
	['<M-q>'] = actions.send_selected_to_qflist + actions.open_qflist,
	['<M-Q>'] = actions.add_selected_to_qflist + actions.open_qflist,
	['<C-q>'] = actions.send_to_qflist + actions.open_qflist,
}

local M = {}
M.picker_mappings = {
	i = list_keys,
	n = list_keys,
}

-- builtin.lsp_references
-- builtin.lsp_incoming_calls
-- builtin.lsp_outcoing_calls
-- builtin.lsp_definitions
-- builtin.lsp_type_definitions
-- builtin.lsp_implementations
-- builtin.lsp_document_symbols
-- builtin.lsp_workspace_symbols
-- builtin.diagnostics

return M
