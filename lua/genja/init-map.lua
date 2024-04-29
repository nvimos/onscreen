

vim.keymap.set('n', [[\]], [[l]])

-- vim.keymap.set('', '<F3>', ':tabedit %:p:h<CR>')
vim.keymap.set('n', '<S-F5>', ':source %<CR>:echo "{sourced}" resolve(expand("%:t")) <CR>')

vim.keymap.set('', '<Esc>', '<cmd>nohlsearch<CR><Esc>')
vim.keymap.set('', '<M-]>', ':tabnext<CR>')
vim.keymap.set('', '<M-[>', ':tabprevious<CR>')
vim.keymap.set('', '<leader>]', ':tabnext<CR>')
vim.keymap.set('', '<leader>[', ':tabprevious<CR>')

vim.keymap.set('n', '<leader><Space>', ':nohlsearch<CR>')
vim.keymap.set('n', '<leader>r', 'mjgg=G<CR>`j')

vim.keymap.set('n', '<leader>eI',
	':tabedit '            ..(vim.fn.stdpath('config')..'/lua/genja/')..'<CR>'
	..'<cmd>/init.lua<CR>'
	..'<cmd>nohl<CR>'
	..'<cmd>cd '           ..(vim.fn.stdpath('config')..'/lua/genja/').. '/../..<CR>',
	{ desc = 'edit Init'})

local function confdir(vimc, f) f=f or ""; return '<cmd>'..vimc..' '..vim.fn.stdpath('config')..'/lua/genja/'..f..'<CR>'; end
local function command(vimc) return '<cmd>' .. vimc .. '<CR>' end


-- Search for a file in the confdir.
vim.keymap.set('n', '<leader>ei',
	confdir('cd')..[[<cmd>cd ../..<cr>]]..
	confdir('tabedit')..
	command('/init.lua')..
	command('nohl')..
	[[/]], { desc = 'edit init'})

-- Open both map.lua and init-map.lua
vim.keymap.set('n', '<leader>em',
	confdir('tabedit', 'init-map.lua')..
	command('vsplit')..
	confdir('edit', 'map.lua')..
	[[<C-W>r<CR>]]
	, { desc = 'edit init'})

-- Only
vim.keymap.set('n', '<leader>o', ':only<CR>')

-- Redo!
vim.keymap.set('n', '!', ':<up><home><c-right>!<cr>') -- repeat last command with a bang
