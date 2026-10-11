local ok, te = pcall(require, 'telescope.builtin')
if not ok then
	return
end

local t = require 'telescope'
te = require 'telescope.builtin'

local km = vim.keymap.set
local nosi = function(d) return { silent = true, noremap = true, desc = d } end


function Telemap(map)
	local act = require 'telescope.actions'
	map({ 'i', 'n' }, '<esc>',  act.close)
	map({ 'i', 'n' }, '<F3>',   act.move_selection_previous)
	map({ 'i', 'n' }, '<F2>',   act.move_selection_next)
	map({ 'i', 'n' }, '<S-F3>', act.move_selection_previous)
	map({ 'i', 'n' }, '<S-F2>', act.move_selection_next)
end


local function find_in_startdirs()
	require('telescope.builtin').find_files({
		hidden = false,
		search_dirs = START_DIRS
	})
end

local function cmd(c) return '<cmd>' .. c .. '<cr>' end

local function grep_string()
	require('telescope.builtin').grep_string({
		search = vim.fn.input("Grep: ") }) end

-- frequently used
km('n', '<F1>', te.live_grep,           { desc = ' live 󰵃'})
-- km('n', '<S-F1>', te.find_files,          { desc = ' find_files'})
km('n', '<S-F1>', cmd 'Telescope finn',          { desc = ' finn filer'})


km('n', '<C-F1>', te.oldfiles,              { desc = ' oldfiles'})
km('n', '<leader>j//', find_in_startdirs, { desc = ' find in START_DIRS'})

-- telescope introspection
km('n', '<leader>j?', te.builtin,       { desc = ' builtin'})

-- browse / find
km('n', '<leader>j/.', te.find_files,     { desc = ' find_files'})
km('n', '<leader>jo',  te.oldfiles,       { desc = ' oldfiles'})
km('n', '<leader>jd',  find_in_startdirs, { desc = ' find in START_DIRS'})

-- vim help, inspect state
km('n', '<leader>1',  te.help_tags,             nosi 'Vim help') -- dup-help-tags

km('n', '<leader>4',  te.buffers,       { desc = ' buffers'})
km('n', '<leader>T',  te.buffers,       { desc = ' buffers'})

km('n', '<leader>jv', te.vim_options,   { desc = ' vim_options'})
km('n', '<leader>jC', te.colorscheme,   { desc = ' colorscheme'})
km('n', '<leader>jM', te.keymaps,       { desc = ' keymaps'})
km('n', '<leader>jA', te.autocommands,  { desc = ' autocommands'})

-- unused
-- km('n', '<leader>jb', te.buffers,       { desc = ' buffers'})
-- km('n', '<leader>jh', te.help_tags,     { desc = ' help_tags'})
-- km('n', '<leader>jg',  te.git_files,      { desc = ' git_files'})
-- km('n', '<leader>jr', te.registers,     { desc = ' registers'})
-- km('n', '<leader>jm', te.marks,         { desc = ' marks'})
-- km('n', '<leader>jq', te.quickfix,      { desc = ' quickfix'})
-- km('n', '<leader>jl', te.loclist,       { desc = ' loclist'})

-- grep
km('n', '<leader>jj', te.live_grep,  { desc = ' grep live'})
km('n', '<leader>js', grep_string,   { desc = ' grep string'})



--- vim.keymap.set('', '<S-F2>', ':edit ~/AppData/Local/nvim/lua/mymap.lua<CR>')
--- vim.keymap.set('', '<S-F1>', ':edit ~/AppData/Local/nvim/lua/plugins.lua<CR>')
--- vim.keymap.set('',   '<F1>', ':edit ~/AppData/Local/nvim/init.lua<CR>')

-- km('n', '<leader>ff', te.find_files, { desc = 'Telescope find_files'})
-- km('n', '<leader>fg', te.live_grep, { desc = 'Telescope live_grep'})
-- km('n', '<leader>fb', te.buffers, { desc = 'Telescobe buffers' })
-- km('n', '<leader>fh', te.help_tags, { desc = 'Telescope help_tags'})
--km('n', '<leader>pf', te.find_files, {})
--km('n', '<C-p>', te.git_files, {})
--km('n', '<leader>vh', te.help_tags, {})

-- builtin.lsp_references
-- builtin.lsp_incoming_calls
-- builtin.lsp_outcoing_calls
-- builtin.lsp_definitions
-- builtin.lsp_type_definitions
-- builtin.lsp_implementations
-- builtin.lsp_document_symbols
-- builtin.lsp_workspace_symbols
-- builtin.diagnostics

