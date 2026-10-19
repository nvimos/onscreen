local ok, tsbuiltin = pcall(require, 'telescope.builtin')
if not ok then
	vim.notify('there is no module: telescope.builtin')
	return
end

local km = vim.keymap.set
local nosi = function(d) return { silent = true, noremap = true, desc = d } end


local function find_in_startdirs()
	require('telescope.builtin').find_files({
		hidden = false,
		search_dirs = START_DIRS
	})
end

-- in oil: scan oil's directory instead of :pwd (an oil buffer has no file for 'bufdir')
local function oil_dir_opts()
	if vim.bo.filetype ~= 'oil' then
		return nil
	end
	local dir = require('oil').get_current_dir()
	if not dir then
		return nil
	end
	return { cwd = dir }
end

local function genja_finder_grep() require('genja-finder').live_grep(oil_dir_opts()) end
local function genja_finder_find() require('genja-finder').live_find(oil_dir_opts()) end

local function grep_string()
	require('telescope.builtin').grep_string({
		search = vim.fn.input("Grep: ") }) end

-- Telescope:
-- frequently used
km('n', '<F1>',   genja_finder_grep, { desc = 'Telescope: grep files (genja-finder)'})
km('n', '<S-F1>', genja_finder_find, { desc = 'Telescope: find files (genja-finder)'}) -- was: cmd 'Telescope finn'


km('n', '<C-F1>',      tsbuiltin.oldfiles, { desc = 'Telescope: oldfiles'})
km('n', '<F2>', function() require('genja.f2').open() end, { desc = 'Telescope: context picker (adhoc, git, make, added tasks)'})
local function action_menu() require('genja.actions').open() end
km('n', 'g.',             action_menu, { desc = 'Telescope: actions here (cur: = item under cursor)'})
km('n', '<LocalLeader>/', action_menu, { desc = 'Telescope: actions here (cur: = item under cursor)'})
km('n', '<leader>j//', find_in_startdirs,  { desc = 'Telescope: find in START_DIRS'})

-- telescope introspection
km('n', '<leader>j?', tsbuiltin.builtin,       { desc = 'Telescope: builtin'})

-- browse / find
km('n', '<leader>j/.', tsbuiltin.find_files,     { desc = 'Telescope: find_files'})
km('n', '<leader>jo',  tsbuiltin.oldfiles,       { desc = 'Telescope: oldfiles'})
km('n', '<leader>jd',  find_in_startdirs, { desc = 'Telescope: find in START_DIRS'})

-- vim help, inspect state
km('n', '<leader>1',  tsbuiltin.help_tags,             nosi 'Telescope: Vim help') -- dup-help-tags

km('n', '<leader>4',  tsbuiltin.buffers,       { desc = 'Telescope: buffers'})
km('n', '<leader>T',  tsbuiltin.buffers,       { desc = 'Telescope: buffers'})

km('n', '<leader>jv', tsbuiltin.vim_options,   { desc = 'Telescope: vim_options'})
km('n', '<leader>jC', tsbuiltin.colorscheme,   { desc = 'Telescope: colorscheme'})
km('n', '<leader>jM', tsbuiltin.keymaps,       { desc = 'Telescope: keymaps'})
km('n', '<leader>jA', tsbuiltin.autocommands,  { desc = 'Telescope: autocommands'})

-- unused
-- km('n', '<leader>jb', te.buffers,       { desc = 'Telescope: buffers'})
-- km('n', '<leader>jh', te.help_tags,     { desc = 'Telescope: help_tags'})
-- km('n', '<leader>jg',  te.git_files,      { desc = 'Telescope: git_files'})
-- km('n', '<leader>jr', te.registers,     { desc = 'Telescope: registers'})
-- km('n', '<leader>jm', te.marks,         { desc = 'Telescope: marks'})
-- km('n', '<leader>jq', te.quickfix,      { desc = 'Telescope: quickfix'})
-- km('n', '<leader>jl', te.loclist,       { desc = 'Telescope: loclist'})

-- grep
km('n', '<leader>jj', genja_finder_grep,  { desc = 'Telescope: genja grep'})
km('n', '<leader>jf', genja_finder_find,  { desc = 'Telescope: genja find'})
km('n', '<leader>js', grep_string,   { desc = 'Telescope: grep string'})



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

