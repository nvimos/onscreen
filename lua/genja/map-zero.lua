-- Stable mappings sourced early during init

local cfg, cmd, nosi = require'genja.api'.cfg, require'genja.api'.cmd, require'genja.api'.nosi


local IsDir = require 'genja.fn'.IsDir

-- {{{ aliases, alignment
local km = vim.keymap.set
local nv = { 'n', 'v' }
local nvo = { 'n', 'v', 'o' }
local d = ''  -- default :map, modes n v o (normal, visual, operator pending)
local n = { 'n' }
local v = { 'v' }
local n_ = n
local n__ = n
local n___ = n
local n____ = n
local n_____ = n
local n______ = n
-- }}}

-- Windows {{{
km(d, '<c-w>`',         cmd [[quit]],       nosi 'Window: quit')
km(d, '<leader>w`',     cmd [[quit]],       nosi 'Window: quit')
km(n, '<leader>`',      cmd [[wincmd w]],   nosi 'Window: next')
km(n, '<C-q>',          cmd [[wincmd w]],   nosi 'Window: next') -- same as <c-w>w
km(n, '',             cmd [[wincmd q]],   nosi 'Window: next') -- same as <c-w>w
km(n, '<C-left>',       cmd [[wincmd h]],   nosi 'Window: left')
km(n, '<C-down>',       cmd [[wincmd j]],   nosi 'Window: down')
km(n, '<C-up>',         cmd [[wincmd k]],   nosi 'Window: up')
km(n, '<C-right>',      cmd [[wincmd l]],   nosi 'Window: right')
km(n, '<C-w>1',         cmd [[only]]..'zz', nosi 'Window: only') -- center on line
km(n, '<c-w><s-right>', '<c-w>L',           nosi 'Window: move left')
km(n, '<c-w><s-left>',  '<c-w>R',           nosi 'Window: move left')
-- }}}

-- Tabs {{{
km('', '<M-]>', cmd [[tabnext]], nosi 'Tab: next')
km('', '<M-[>', cmd [[tabprev]], nosi 'Tab: prev')
km('n', '<leader>\\', cmd [[tabnext]], nosi 'Tab: next')
km('n', '<leader>|', cmd [[tabprev]], nosi 'Tab: prev')
km('n', '<leader>t0', cmd [[tabmove 0]], nosi 'Tab: move 0')
km('n', '<leader>t-', cmd [[tabmove -1]], nosi 'Tab: move ←')
km('n', '<leader>t=', cmd [[tabmove +1]], nosi 'Tab: move →')
-- }}}

-- {{{ Toggles
km('n', '<leader>tw', function() vim.o.wrap = ! vim.o.wrap end, nosi 'Toggle: wrap')
km('n', '<leader>tn', function() vim.o.number = ! vim.o.number end, nosi 'Toggle: number')
-- }}}

-- Folds {{{
km(n__, 'z<left>', 'zc', nosi 'Fold: close')
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
-- on the jolemak layout Y is where qwerty-P is
-- on the jolemak layout E is where qwerty-K is
km('n', '', '<C-y>', { silent = true, noremap = true, desc = 'Scroll: extra lines reverse' })
km('n', '', '<C-e>', { silent = true, noremap = true, desc = 'Scroll: extra lines' })
-- }}}

-- Yank & Paste {{{
-- Paste from clipboard ("+ register) in insert mode
km('i', '<S-Insert>', '<c-r>+', nosi 'Paste (shift+insert)')
km(nv, '<leader>y=', '"+yy', nosi 'Vim: yank into clipboard ("+yy)')
km(nv, '<leader>y8', '"*yy', nosi 'Vim: yank into x11:primary  ("*yy)')
km(v, '<leader>yy', '"+y', { desc = 'Vim: yank into clipboard visual ("+yy)' })
km(n, '<leader>yf', '"%p', nosi 'Vim: yank filename')
-- PRIMARY   *
-- CLIPBOARD +
-- }}}

-- Comment code line {{{
km('n', '<C-/>', ':norm gcc<cr>j', nosi 'Edit: Comment and move down')
km('n', '<C-S-/>', ':norm gcc<cr>k', nosi 'Edit: Comment and move up')
km('v', '<C-/>', '<cmd>norm gc<cr>', nosi 'Edit: Comment and move down (visual)')
-- }}}

-- Telescope {{{
-- <SPACE>1 - Telescope Modules
-- <SPACE>2 - Telescope PickFolder
-- local function start_cl() require('lua.telescope._extensions.mylunsj').show_picker() end
vim.keymap.set('n', '<leader>1', cmd 'Telescope help_tags', nosi 'Vim help') -- dup-help-tags
vim.keymap.set('n', '<leader>2', cmd 'Telescope', nosi 'Telescope')
vim.keymap.set('n', '<leader>3', cmd 'Telescope mylunsj', nosi 'Telescope')
vim.keymap.set('n', '<F3>', cmd 'Telescope mylunsj', nosi 'Telescope mylunsj')
vim.keymap.set('n', '<S-F3>', cmd 'Telescope mydirs', nosi 'Telescope mydirs')
-- }}}

-- Browse undo-history (plugin) {{{
vim.keymap.set("n", "<leader>u", cmd [[UndotreeToggle]])
-- }}}

-- Mouse opens links in a browser {{{
vim.keymap.set('n', '<c-leftmouse>', 'gx')
-- }}}

-- Idiosyncratic {{{
vim.keymap.set('n', '<leader>i.', 'a…<esc>', { noremap = true, desc = "Append: … (ellipsis)" })
-- }}}

-- Code actions {{{
km('n', '<leader>r0', cmd 'mjgg=G<cr>`j', { desc = 'reformat gg=G' })
-- EasyAlign plugin
--- can be even more complex…
--- :EasyAlign * /\s\+/ l4r1
--- This aligns on all spaces (*), with 4 spaces left margin (l4) and 1 space right margin (r1).
km('n', '<leader>A<space>', cmd ':norm gaip*\\ ', { desc = 'Align on spaces' })
km('n', '<leader>A,', cmd ':norm gaip*,', { desc = 'Align on , all' })
km('n', '<leader>Aa', cmd ':norm gaip*,', { desc = 'Align on , all' })
km('n', '<leader>A=1', cmd ':norm gaip1=', { desc = 'Align on = 1st' })
km('n', '<leader>A==', cmd ':norm gaip*=', { desc = 'Align on = all' })
km('n', '<leader>A:1', cmd ':norm gaip1:', { desc = 'Align on : 1st' })
km('n', '<leader>A:z', cmd ':norm gaip1:', { desc = 'Align on : last' })
km('v', '<leader>A<space>', cmd ':norm gaip*\\ ', { desc = 'Align on spaces' })
km('v', '<leader>A,', cmd ':norm gaip*,', { desc = 'Align on , all' })
km('v', '<leader>Aa', cmd ':norm gaip*,', { desc = 'Align on , all' })
km('v', '<leader>A=1', cmd ':norm gaip1=', { desc = 'Align on = 1st' })
km('v', '<leader>A==', cmd ':norm gaip*=', { desc = 'Align on = all' })
km('v', '<leader>A:1', cmd ':norm gaip1:', { desc = 'Align on : 1st' })
km('v', '<leader>A:z', cmd ':norm gaip1:', { desc = 'Align on : last' })
km('n', '<leader>w<right>', cmd ':norm gqj', nosi 'Text: conform to width')
-- }}}

-- Vim actions {{{
-- vim.keymap.set('n', '<S-F5>', ':source %<cr>
km('', '<Esc>', '<cmd>nohlsearch<cr><Esc>')
km('n', '<S-F5>', ':source %<cr><cmd>echo "{sourced}" resolve(expand("%:t"))<cr>', nosi 'source current file')
--
km(nv, '<leader>.', '&', nosi 'Vim: Repeat last command')
--km('n', '<leader><Space>', ':nohlsearch<cr>')
-- }}}

-- Jump dirs {{{
local function cd_dot()
	if vim.bo.filetype == 'oil' then
		require 'genja.fn'.Cd(require 'oil'.get_current_dir())
	else
		vim.cmd ':lcd %:p:h'
		vim.cmd ':pwd'
	end
end
vim.keymap.set('n', '<leader>j..', cd_dot, { desc = ':lcd dirname(%)' })
vim.keymap.set('n', '<leader>j.,', ':lcd ..   <cr>:pwd<cr>', { desc = ':lcd ..' })
-- }}}

-- Redo! {{{
km('n', '!', ':<up><home><c-right>!<cr>') -- repeat last command with a bang
-- }}}

-- Write, Quit {{{
km("n", "<leader>zz", 'write', { desc = 'write', silent = true })
km("n", "<leader>zZ", ':x', { desc = 'write, quit', silent = true })
-- }}}

-- Edit my init file {{{
km('n', '<leader>eI', cfg('tabedit', 'init.lua'), nosi 'edit init file')
-- }}}


-- Spelling {{{
km(nv, '<leader><space>sa', 'zg', nosi 'Spell: add word to dict')
km(nv, '<leader><space>ss', ']s', nosi 'Spell: spell next')
km(nv, '<leader><space>sS', '[s', nosi 'Spell: spell next')
-- }}}

-- Edit notes {{{
km('n', '<leader>en', require('genja.fn-keys').EditFindNotes, nosi 'edit notes')
-- km('n', '<leader>en', '', nosi 'edit notes')
-- }}}

-- {{{ Edit dir of buffer.
--
-- -- Open both map.lua and init-map.lua
-- km('n', '<leader>ek',
-- 	confdir('tabedit', 'init-map.lua') ..
-- 	command('vsplit') ..
-- 	confdir('edit', 'map-zero.lua') ..
-- 	[[<C-W>r<cr>]]
-- 	, { desc = 'edit map' })

-- Search in dir-listing of current file {{{
local function search_dir_of_file()
	vim.cmd 'edit %:p:h'
	vim.schedule(function()
		local slash = vim.api.nvim_replace_termcodes('/', true, true, true)
		vim.api.nvim_feedkeys(slash, 'n', false)
	end)
end
km('n', '<leader>ee', '<cmd>:edit %:p:h<cr>/', nosi 'seek in `dirname`')
km('n', '<leader>ee', search_dir_of_file, nosi 'seek in `dirname`') -- for Oil
-- }}}

-- Edit in dir-listing of current file {{{
km('n', '<leader>e.', '<cmd>:edit %:p:h<cr>', nosi 'edit in `dirname`')
km('n', '<c-->', '<cmd>:edit %:p:h<cr>', nosi 'edit in `dirname`')
km('n', '<leader>et', '<cmd>:tabedit %:p:h<cr>', nosi 'tabedit `dirname`')

--}}}

-- edit lazy conf {{{
km('n', '<leader>eh', cmd('tabedit ' .. (vim.env.user_home_dir or '')), nosi 'edit home dir')
km('n', '<leader>el', cfg('tabedit', '../lazyp/'), nosi 'edit lazyp dir')
-- }}}


-- Highlight init in the confdir. {{{
km('n', '<leader>ei',
	cmd('lua pcall(Close_nerdtree_wins)') ..
	cfg('cd', '../..') ..
	cfg('tabedit') ..
	cmd('/init.lua') ..
	cmd('nohl') ..
	[[/]], { desc = 'edit init dir' })
-- }}}



--
-- km('n', '<leader>lo', command('only'), { desc = 'only this window' })
-- km('n', '<leader>le', command('wincmd ='), { desc = 'equalize windows' })
-- km('n', '<leader>lm', command('resize | vertical resize'), { desc = 'maximize current' })
km('n', '<c-w>m', cmd('resize | vertical resize'), { desc = 'maximize current' })


-- vim: set foldmethod=marker foldlevel=0 foldnestmax=2 foldcolumn=2:
