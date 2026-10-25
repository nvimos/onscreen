-- Stable mappings sourced early during init

local cfg, cmd, nosi = require'genja.api'.cfg, require'genja.api'.cmd, require'genja.api'.nosi


local IsDir = require 'genja.fn'.IsDir

-- {{{ aliases, alignment
local km = vim.keymap.set
local nv = { 'n', 'v' }
local ic = {'i', 'c'}
local nvo = { 'n', 'v', 'o' }
local d = ''  -- default :map, modes n v o (normal, visual, operator pending)
local n = { 'n' }
local v = { 'v' }
local nx = { 'n', 'x' }
local nxo = { 'n', 'x', 'o' }
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
-- sizes in big steps, share cycle, resize mode (lua/genja/winsize.lua)
local function ws() return require('genja.winsize') end
km(n, '<M-=>',      function() ws().resize(1) end,  nosi 'Window: grow (big step)')
km(n, '<M-->',      function() ws().resize(-1) end, nosi 'Window: shrink (big step)')
km(n, '<M-0>',      function() ws().cycle() end,    nosi 'Window: split share 50/30/70/60')
km(n, '<leader>wr', function() ws().mode() end,     nosi 'Window: resize mode (h j k l = 0, <Esc>)')
km(n, '<leader>Wh', function() ws().resize(-1, 'width') end,  nosi 'Resize: narrower')
km(n, '<leader>Wl', function() ws().resize(1, 'width') end,   nosi 'Resize: wider')
km(n, '<leader>Wj', function() ws().resize(-1, 'height') end, nosi 'Resize: lower')
km(n, '<leader>Wk', function() ws().resize(1, 'height') end,  nosi 'Resize: taller')
km(n, '<leader>W=', '<C-w>=',                                  nosi 'Resize: equal')
km(n, '<leader>W0', function() ws().cycle() end,              nosi 'Resize: split share cycle')
km(n, '<leader>Ws', function() ws().toggle_step() end,        nosi 'Resize: step percent/cells')
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
-- ~ swaps true/false, on/off, +/-, </> … under the cursor, else plain ~ (lua/genja/tilde.lua)
km('n', '~', function() require('genja.tilde').toggle() end, nosi 'Toggle: switch word or case')
km('n', '<M-~>', '~', nosi 'Toggle: case (plain ~)')
-- }}}

-- Folds {{{
-- built-ins mapped to themselves, only to give which-key a description;
-- noremap keeps counts and the zf operator working.
-- which-key sorts by description: the word after `Fold: ` is the group.
-- Modes follow :h fold-commands: x for {Visual} forms, x and o for the motions.
km(nx, 'zc',     'zc', nosi 'Fold: x close')
km(nx, 'z<left>', 'zc', nosi 'Fold: x close (zc)')
km(n, 'zM',      'zM', nosi 'Fold: x close all')
km(nx, 'zC',     'zC', nosi 'Fold: x close recursively')

km(n, 'zf',      'zf', nosi 'Fold: create (operator)')
-- visual zf asks for a title and writes {{{ title / }}} markers; empty title: built-in
km('x', 'zf', function() require('genja.wrapfold').visual() end, nosi 'Fold: create with title markers')
km(n, '<leader>wwf', function() require('genja.wrapfold').paragraph() end, nosi 'Fold: wrap paragraph in title markers')
km('x', '<leader>wwf', function() require('genja.wrapfold').visual() end, nosi 'Fold: wrap selection in title markers')
km(n, 'zF',      'zF', nosi 'Fold: create for N lines')

km(nx, 'zd',     'zd', nosi 'Fold: delete')
km(n, 'zE',      'zE', nosi 'Fold: delete all (eliminate)')
km(nx, 'zD',     'zD', nosi 'Fold: delete recursively')

km(n, 'zn',      'zn', nosi 'Fold: fen off')
km(n, 'zN',      'zN', nosi 'Fold: fen on')
km(n, 'zi',      'zi', nosi 'Fold: fen toggle')

km(nxo, ']z',    ']z', nosi 'Fold: jump to open fold end')
km(nxo, '[z',    '[z', nosi 'Fold: jump to open fold start')
km(nxo, 'zj',    'zj', nosi 'Fold: jump to next start')
km(nxo, 'zk',    'zk', nosi 'Fold: jump to previous end')

km(n, 'zr',      'zr', nosi 'Fold: level less (foldlevel +1)')
km(n, 'zm',      'zm', nosi 'Fold: level more (foldlevel -1)')

km(nx, 'zo',     'zo', nosi 'Fold: open')
km(n, 'zR',      'zR', nosi 'Fold: open all')
km(nx, 'zO',     'zO', nosi 'Fold: open recursively')

km(n, 'za',      'za', nosi 'Fold: toggle')
km(n, 'zA',      'zA', nosi 'Fold: toggle recursively')

km(n, 'zX',      'zX', nosi 'Fold: update')
km(n, 'zx',      'zx', nosi 'Fold: update, view cursor line')

km(n, 'zv',      'zv', nosi 'Fold: view cursor line')
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
km(ic, '<S-Insert>', '<c-r>+', nosi 'Paste: clipboard (<c-r>+)')
-- nvim_paste sends the text to the job as a bracketed paste, so shells don't run each line
km('t', '<S-Insert>', function()
	vim.api.nvim_paste(vim.fn.getreg('+'), true, -1)
end, nosi 'Paste: clipboard into terminal')
km(n,  '<leader>yf', '"%p',    nosi 'Paste: filename  ("%p)')
km(nv, '<leader>y=', '"+yy',   nosi 'Yank: into clipboard   ("+yy)')
km(nv, '<leader>y8', '"*yy',   nosi 'Yank: into x11:primary ("*yy)')
km(v,  '<leader>yy', '"+y',    nosi 'Yank: into clipboard   ("+yy)' )

-- km('x', '<leader>sv', require('genja.fn-keys').SubstituteVisualSelection, { desc = 'Edit Substitute visual selection' })

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
vim.keymap.set('n', '<leader>1', cmd 'Telescope help_tags', nosi 'Telescope: vim help') -- dup-help-tags
vim.keymap.set('n', '<leader>2', cmd 'Telescope',           nosi 'Telescope: builtins')
vim.keymap.set('n', '<leader>3', cmd 'Telescope mylunsj',   nosi 'Telescope: mylunsj')
vim.keymap.set('n', '<F3>',      cmd 'Telescope mylunsj',   nosi 'Telescope: mylunsj')
vim.keymap.set('n', '<S-F3>',    cmd 'Telescope mydirs',    nosi 'Telescope: mydirs')
-- }}}

-- UI toggles, plugins {{{
-- ui Browse undo-history (plugin) {{{
vim.keymap.set("n", "<leader>mu", cmd [[UndotreeToggle]], nosi 'UI: UndooTree') -- }}}
-- ui claude in a float term {{{
vim.keymap.set("n", "<leader>mc", cmd [[ClaudeFterm]], nosi 'UI: ClaudeFterm') -- }}}
-- <leader>mg (Neogit) and the other git keys: lua/genja/map-plugin/neogit.lua, diffview.lua, gitsigns.lua
-- }}}

-- Mouse opens links in a browser {{{
vim.keymap.set('n', '<c-leftmouse>', 'gx')
-- }}}

-- Idiosyncratic {{{
vim.keymap.set('n', '<leader>i.', 'a…<esc>',                                nosi 'Append: … (ellipsis)')
vim.keymap.set('n', '<leader>id', [[a<C-r>=strftime('%Y-%m-%d')<CR><esc>]], nosi 'Append: ymd date')
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
km("n", "<leader>zz", '<cmd>write<cr>', { desc = 'Vim: write', silent = true })
-- :w<CR> without the command line, so cmp's cmdline popup can't flash.
-- ':' now waits for the next key (timeoutlen) before the cmdline opens;
-- which-key skips ':' mappings (filter in lazyp/my/which-key.lua), else it would claim ':'.
km('n', ':w<cr>', '<cmd>write<cr>', { desc = 'Vim: write (no cmdline, no completion popup)' })
km("n", "<leader>zZ", '<cmd>x<cr>', { desc = 'Vim: write, quit', silent = true })
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
