-- vim: set foldmethod=marker foldlevel=1 foldnestmax=2 foldcolumn=2:
-- Stable mappings sourced early during init
local nosi = function(d) return { silent = true, noremap = true, desc = d } end
local function cmd(c) return '<cmd>' .. c .. '<cr>' end
local km = vim.keymap.set
local nv = { 'n', 'v' }
local n = { 'n' }
local n_ = n
local n__ = n
local n___ = n
local n____ = n
local n_____ = n
local n______ = n


-- Windows {{{
km('', '<C-W>`', cmd [[quit]], { desc = 'Window: quit' })
km('', '<leader>w`', cmd [[quit]], { desc = 'Window: quit' })
-- km('', '<leader>wn', cmd [[wincmd n]], { desc = 'Window: quit' })
-- km('', '<leader>ws', cmd [[wincmd n]], { desc = 'Window: quit' })

km('n', '<leader>`', cmd [[wincmd w]], nosi 'Window: next')
km(n______, '<C-q>', cmd [[wincmd w]], nosi 'Window: next') -- same as <c-w>w

km(n_, '<C-left>', cmd [[wincmd h]], nosi 'Window: left')
km(n_, '<C-down>', cmd [[wincmd j]], nosi 'Window: down')
km(n___, '<C-up>', cmd [[wincmd k]], nosi 'Window: up')
km(n, '<C-right>', cmd [[wincmd l]], nosi 'Window: right')
km(n___, '<C-w>1', cmd [[only]], { desc = 'Window: only' })

km(n__, '<c-w><s-right>', '<c-w>L', { desc = 'move window left' })
km(n__, '<c-w><s-left>', '<c-w>R', { desc = 'move window left' })
-- }}}

-- Tabs {{{
km('', '<M-]>', cmd [[tabnext]], { desc = 'Tab: next' })
km('', '<M-[>', cmd [[tabprev]], { desc = 'Tab: prev' })
km('n', '<leader>\\', cmd [[tabnext]], { desc = 'Tab: next' })
km('n', '<leader>|', cmd [[tabprev]], { desc = 'Tab: prev' })
-- km('n', '<leader>]',  cmd[[tabnext]],  {desc = 'Tab: next'})
-- km('n', '<leader>[',  cmd[[tabprev]],  {desc = 'Tab: prev'})
km('n', '<leader>t0', cmd [[tabmove 0]], { desc = 'Tab: move 0' })
km('n', '<leader>t-', cmd [[tabmove -1]], { desc = 'Tab: move ←' })
km('n', '<leader>t=', cmd [[tabmove +1]], { desc = 'Tab: move →' })
-- }}}

-- Buffers {{{
km('n', '<leader><space>', '<c-^>', { noremap = true, desc = 'rotate to alternative buffer' })
km('n', '<leader>bb2', '2<c-^>', { noremap = true, desc = 'rotate to alternative buffer' })
km('n', '<leader>bb3', '3<c-^>', { noremap = true, desc = 'rotate to alternative buffer' })

-- }}}

-- Scrolling {{{
-- Keep cursor midways on buffer (see scroll and startofline)
km('', '<C-d>', '<C-d>zz', { noremap = true, silent = true })
km('', '<PageDown>', '<c-d>zz', { noremap = true, silent = true })
km('', '<C-cr>', '<C-d>zz', { noremap = true, silent = true })
km('', '<C-u>', '<C-u>zz', { noremap = true, silent = true })
km('', '<PageUp>', '<c-u>zz', { noremap = true, silent = true })
km('', '<C-bs>', '<C-u>zz', { noremap = true, silent = true })
-- }}}

-- Paste from clipboard (+ register) in insert mode {{{
km('i', '<S-Insert>', '<C-R>+', { noremap = true })
-- paste filename? km('i', '<C-q>f', '<C-R>%', { noremap = true })
-- }}}

-- Comment code line {{{
km('n', '<C-/>', ':norm gcc<cr>j')
km('n', '<C-S-/>', ':norm gcc<cr>k')
km('v', '<C-/>', '<cmd>norm gc<cr>')
-- }}}

-- Telescope {{{
-- <SPACE>1 - Modules
-- <SPACE>2 - PickFolder
-- local function start_cl() require('lua.telescope._extensions.mylunsj').show_picker() end

vim.keymap.set('n', '<leader>1', cmd 'Telescope help_tags', nosi 'Vim help')
vim.keymap.set('n', '<leader>2', cmd 'Telescope',           nosi 'Telescope')
vim.keymap.set('n', '<leader>3', cmd 'Telescope mylunsj',   nosi 'Telescope')
vim.keymap.set('n', '<F3>',      cmd 'Telescope mylunsj',   nosi 'Telescope mylunsj')
vim.keymap.set('n', '<S-F3>',    cmd 'Telescope mydirs',    nosi 'Telescope mydirs')
-- }}}

-- Browse undo-history (plugin) {{{
vim.keymap.set("n", "<leader>u", cmd [[UndotreeToggle]])
-- }}}

-- Mouse opens links in a browser {{{
vim.keymap.set('n', '<c-leftmouse>', 'gx')
-- }}}

-- Idiosyncratic {{{
vim.keymap.set('n', '<leader>i.', 'a…<esc>', { noremap = true, desc = "Append: … (ellipsis)" })
vim.keymap.set('n', '<leader>j.', ':cd %:p:h<cr>:pwd<cr>', { desc = ':cd dirname(%)' })
vim.keymap.set('n', '<leader>j,', ':cd ..   <cr>:pwd<cr>', { desc = ':cd ..' })
-- }}}

-- Code actions {{{
km('n', '<leader>r0',       cmd 'mjgg=G<cr>`j',   { desc = 'reformat gg=G'   })
-- EasyAlign plugin
--- can be even more complex…
--- :EasyAlign * /\s\+/ l4r1
--- This aligns on all spaces (*), with 4 spaces left margin (l4) and 1 space right margin (r1).
km('n', '<leader>A<space>', cmd ':norm gaip*\\ ', { desc = 'Align on spaces' })
km('n', '<leader>A,',       cmd ':norm gaip*,',   { desc = 'Align on , all'  })
km('n', '<leader>Aa',       cmd ':norm gaip*,',   { desc = 'Align on , all'  })
km('n', '<leader>A=1',      cmd ':norm gaip1=',   { desc = 'Align on = 1st'  })
km('n', '<leader>A==',      cmd ':norm gaip*=',   { desc = 'Align on = all'  })
km('n', '<leader>A:1',      cmd ':norm gaip1:',   { desc = 'Align on : 1st'  })
km('n', '<leader>A:z',      cmd ':norm gaip1:',   { desc = 'Align on : last' })
km('v', '<leader>A<space>', cmd ':norm gaip*\\ ', { desc = 'Align on spaces' })
km('v', '<leader>A,',       cmd ':norm gaip*,',   { desc = 'Align on , all'  })
km('v', '<leader>Aa',       cmd ':norm gaip*,',   { desc = 'Align on , all'  })
km('v', '<leader>A=1',      cmd ':norm gaip1=',   { desc = 'Align on = 1st'  })
km('v', '<leader>A==',      cmd ':norm gaip*=',   { desc = 'Align on = all'  })
km('v', '<leader>A:1',      cmd ':norm gaip1:',   { desc = 'Align on : 1st'  })
km('v', '<leader>A:z',      cmd ':norm gaip1:',   { desc = 'Align on : last' })
-- }}}

-- Vim actions
-- {{{
-- vim.keymap.set('n', '<S-F5>', ':source %<cr>
km('n', '<S-F5>', ':source %<cr>' .. '<cmd>echo "{sourced}" resolve(expand("%:t"))<cr>')
km('', '<Esc>', '<cmd>nohlsearch<cr><Esc>')
km(nv, '<leader>.', '&', nosi 'Repeat last command')

--km('n', '<leader><Space>', ':nohlsearch<cr>')
-- }}}


-- Redo! {{{
km('n', '!', ':<up><home><c-right>!<cr>') -- repeat last command with a bang
-- }}}

km("n", "<leader>zz", 'write', { desc = 'write',       silent = true })
km("n", "<leader>zZ", ':x',    { desc = 'write, quit', silent = true })
-- }}}

-- km('', '<F3>', ':tabedit %:p:h<cr>')
-- {{{ quickly edit init

km('n', '<leader>ei', ':tabedit ' .. (vim.fn.stdpath('config') .. '/lua/genja/' .. '/init.lua<cr>'), { desc = 'edit Init' })

local function confdir(vimc, f) f = f or ""; return '<cmd>' .. vimc .. ' ' .. vim.fn.stdpath('config') .. '/lua/genja/' .. f .. '<cr>'; end
local function command(vimc) return '<cmd>' .. vimc .. '<cr>' end
-- Highlight init in the confdir.
km('n', '<leader>eI',
	command('lua Close_nerdtree_wins()') ..
	confdir('cd') ..
	command('cd ../..') ..
	confdir('tabedit') ..
	command('/init.lua') ..
	command('nohl') ..
	[[/]], { desc = 'edit init' })

-- -- Open both map.lua and init-map.lua
-- km('n', '<leader>ek',
-- 	confdir('tabedit', 'init-map.lua') ..
-- 	command('vsplit') ..
-- 	confdir('edit', 'map-zero.lua') ..
-- 	[[<C-W>r<cr>]]
-- 	, { desc = 'edit map' })


-- Search for a file in the confdir.
km('n', '<leader>ee', '<cmd>:edit %:p:h<cr>/',   { desc = 'serch in CWD' })
km('n', '<leader>e.', '<cmd>:edit %:p:h<cr>',    { desc = 'edit CWD %:h (dirname)' })
km('n', '<leader>et', '<cmd>:tabedit %:p:h<cr>', { desc = 'tabedit CWD' })


--
-- km('n', '<leader>lo', command('only'), { desc = 'only this window' })
-- km('n', '<leader>le', command('wincmd ='), { desc = 'equalize windows' })
-- km('n', '<leader>lm', command('resize | vertical resize'), { desc = 'maximize current' })
km('n', '<c-w>m', command('resize | vertical resize'), { desc = 'maximize current' })





------------------------------------------------------------------------

function Telemap(map)
	local ta = require [[telescope.actions]]
	map({ 'i', 'n' }, '<esc>', ta.close)
	map({ 'i', 'n' }, '<F2>', ta.move_selection_previous)
	map({ 'i', 'n' }, '<F3>', ta.move_selection_next)
	map({ 'i', 'n' }, '<S-F2>', ta.move_selection_previous)
	map({ 'i', 'n' }, '<S-F3>', ta.move_selection_next)

end
