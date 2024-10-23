--[[

== From docs
	:help default-mappings
	(…)
	nnoremap Y y$
	nnoremap <C-L> <Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>
	nnoremap & :&&<CR>
	inoremap <C-U> <C-G>u<C-U>
	inoremap <C-W> <C-G>u<C-W>
	xnoremap * y/\V<C-R>"<CR>
	xnoremap # y?\V<C-R>"<CR>

== :map is same as vim.keymap.set('', …)
	:map (mapmode-nvo) means normal, visual and operator-pending
== Inspiration
	- https://github.com/LunarVim/Neovim-from-scratch/blob/master/lua/user/keymaps.lua

]]



F = require'genja.api'.fn
local cfg, cmd, nosi = F.cfg, F.cmd, F.nosi

-- local function cmd(c) return '<cmd>' .. c .. '<cr>' end


local nosi = function(d) return { silent = true, noremap = true, desc = d } end
local km = vim.keymap.set
local nv = { 'n', 'v' }
local v = { 'v' }


--vim.keymap.set(nv, '<leader>wT',  cmd 'mj'..[[]]..cmd 'nohl'..cmd '`j', nosi 'title-case buffer')

vim.keymap.set(nv, '<leader>wT',  'mjgg=G' .. [[:%s/\<./\U&/g<cr>]] .. '`j' .. cmd 'nohl', nosi 'title-case buffer')


-- Magical and convoluted macros
vim.keymap.set(nv, '<leader>wsb', [[:'<,'>g/^$/d<cr> <cmd>let @/=''<cr>]], nosi 'remove empty lines in visual block')
vim.keymap.set(nv, '<leader>wss', [[:%s,\s\+$,,<cr>]],                     nosi 'remove trailing space')
vim.keymap.set(nv, '<leader>w"',  [[:s/"/'/g<cr>j]],                       nosi 'replace " with \' on current line')
vim.keymap.set(v,  '<leader>w"',  [[$A",<esc>gvI"<esc>]],                  nosi 'wrap selection with " "')
--vim.keymap.set('v',  '<leader>w"', [[$o0I"<esc>$A",<esc>]],              {noremap = true, desc = [[wrap selection with " ",]]})
-- vim.api.nvim_set_keymap('n', '<leader>w"', [[:%s/"/'/g<CR>]], {noremap = true})

-- Instant search/replace on the cursor
km('n', '<leader>cs', [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<left><left><left>]], nosi 'search & replace')



-- Plugin (move to spec…)
-- vim.keymap.set('', '<leader>jD', vim.cmd.Dashboard, { desc = 'Dashboard' } )
km('', '<leader>jm',  cmd 'MRU',  nosi 'MRU')

km('n', '<leader>sf', cmd 'set guifont=*', nosi 'Vim: set guifont')
km('n', '<F7>',       cmd 'set guifont=*', nosi 'Vim: set guifont')


-- -- Remap for dealing with word wrap
-- vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
-- vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })



-- transform «Plug "foo/bar"» to «{ 'foo/bar' },»
km('n',
	'<leader>wL',
	cmd [[silent! s/use *{ *\([^}]*\)}/\1/]] ..
	cmd [[silent! s/Plug *//]] ..
	cmd [[silent! s/"//g]] ..
	[[^ciW{ '' },<esc>hhhhp]]..
	cmd [[silent! s/''/'/g]]
	,nosi 'transform to Lazy')


-- Zen Mode (folke/zen-mode)
local wo = vim.wo
local function zm(width, opts)
	require('zen-mode').setup { window = { width = width, options = opts } }
	require('zen-mode').toggle()
end
local function z0()
	vim.wo.wrap, vim.wo.number, vim.wo.rnu = false, false, false
	vim.opt.colorcolumn = '0'
	zm(0, {})
end
local function z1()
	vim.wo.wrap, vim.wo.number, vim.wo.rnu = false, false, false
	vim.opt.colorcolumn = '0'
	zm(120, {})
end
local function z2()
	wo.wrap, wo.number, wo.rnu = false, true, true
	vim.opt.colorcolumn = '4,8,80'
	zm(80, {})
end
vim.keymap.set('n', '<leader>z0', z0, { desc = 'Zen mode off' })
vim.keymap.set('n', '<leader>z1', z1, { desc = 'Zen Mode' })
vim.keymap.set('n', '<leader>z2', z2, { desc = 'Zen Mode (relnum)' })

--------------------------------------
--------------------------------------
--------------------------------------

function EdInit()
	local cdir = vim.fn.stdpath('config') .. '/lua/genja/'
	-- vim.cmd(':cd '      .. cdir)
	vim.cmd(':tabedit ' .. cdir)
	vim.cmd [[/init.lua]]
	vim.cmd [[nohl]]
	vim.cmd [[/.]]
	--vim.cmd('/init.lua')
	--vim.cmd(':nohl')

	-- local myConf = vim.fn.stdpath('config') .. '/lua/genja/'
	-- /init<CR><cmd>nohl<CR><cmd>cd ' ..myConf.. '/../..<cr>', { desc = 'edit init'}
end

--




--[[

-- some "very clever" maps by other people, keeping here for inspiration

-- replace word under cursor
-- utils.nnoremap(leader .. 'r', ':lua require("spectre").open()<cr>')
-- utils.vnoremap(leader .. 'r', ':lua require("spectre").open()<cr>')
-- utils.nnoremap('R', ':%s/\\<<C-r><C-w>\\>//g<Left><Left><C-r><C-w>')

-- -- Replace/Delete words quick! ONE BY ONE.
-- -- c. c, d. d,
-- utils.nnoremap('c.', "/\\<<C-R>=expand('<cword>')<CR>\\>\\C<CR>``cgn")
-- utils.nnoremap('c,', "?\\<<C-R>=expand('<cword>')<CR>\\>\\C<CR>``cgN")
-- utils.nnoremap('d.', "/\\<<C-r>=expand('<cword>')<CR>\\>\\C<CR>``dgn")
-- utils.nnoremap('d,', "?\\<<C-r>=expand('<cword>')<CR>\\>\\C<CR>``dgN")

-- -- Resize our splits with <leader> ;/'/,/.- easily
-- set_keymap("n", "<Leader>.", ":exe \"resize \" . (winheight(0) * 4/3)<CR>", { silent = true, noremap = true, })
-- set_keymap("n", "<Leader>,", ":exe \"resize \" . (winheight(0) * 3/4)<CR>", { silent = true, noremap = true, })
-- set_keymap("n", "<leader>;", ":exe \"vertical resize \" . (winwidth(0) * 3/4)<CR>", { silent = true, noremap = true, })
-- set_keymap("n", "<leader>'", ":exe \"vertical resize \" . (winwidth(0) * 4/3)<CR>", { silent = true, noremap = true, })
--

-- -- CHANGE A SPLIT ORENTATION FROM HORIZONTAL TO VERTICAL AND VICE VERSA
-- set_keymap("n", "<leader>[", "<c-w>H", { silent = true, noremap = true, })
-- set_keymap("n", "<leader>]", "<c-w>K", { silent = true, noremap = true, })

]]



if vim.fn.has('windows') then
	-- with a custom keymap, pressing the keys with control does not generate
	-- the expected key-symbol. so I force this. I want do use <C-d> because
	-- thats what I remember. and I don't care where <C-d> ~  is on the
	-- qwerty layout.

	-- vim.keymap.set('', '', ':redo<CR>', { noremap = true, silent = true })
	-- vim.keymap.set('', '', '<C-d>zz',   { noremap = true, silent = true })
	vim.keymap.set('', '', ':redo<CR>', { noremap = true, silent = true })
	vim.keymap.set('', '', '<C-d>zz', { noremap = true, silent = true })


	vim.keymap.set('', '', '<C-i>', { noremap = true, silent = true }) -- does not work?
	vim.keymap.set('', '', '<C-o>', { noremap = true, silent = true })

	-- // 
	-- // 
	-- // 

	-- jwfp: uo
	-- jwfp: uo
	-- qwer: io

	-- oooooiii
	-- uuuuuooo

	-- also CTRL+E (scroll)
	-- also CTRL+I (previous buffer)
end


-----------------------------------------------------------
-----------------------------------------------------------
-----------------------------------------------------------
-----------------------------------------------------------


-- Adjust for colemak?
-- local mode = { 'n', 'x', 'o' }
-- vim.keymap.set(mode, 'm', 'h', { desc = 'Left' })
-- vim.keymap.set(mode, 'M', 'H', { desc = 'Top line of window' })
-- vim.keymap.set(mode, 'h', 'i', { desc = 'Insert' })
-- vim.keymap.set(mode, 'H', 'I', { desc = 'Insert at line start' })
-- vim.keymap.set(mode, 'n', 'j', { desc = 'Down' })
-- vim.keymap.set(mode, 'N', 'J', { desc = 'Join below line' })
-- vim.keymap.set(mode, 'k', 'n', { desc = 'Find next' })
-- vim.keymap.set(mode, 'K', 'N', { desc = 'Find previous' })
-- vim.keymap.set(mode, 'e', 'k', { desc = 'Up' })

--- function! FoldedLines()
--- 	if HasFoldedLines() == 1
--- 		:set foldcolums=1
--- 	else
--- 		:set foldcolums=0
--- 	endif
--- endfu
---
--- function! HasFoldedLines()
--- 	let lnum=1
--- 	while lnum <= line("$")
--- 		if (foldclosed(lnum) > -1)
--- 			return 1
--- 		endif
--- 		let lnum+=1
--- 	endwhile
--- 	return 0
--- endfu


-- maybe -- require('refactoring').setup({})
-- maybe -- vim.api.nvim_set_keymap("v", "<leader>ri", [[ <Esc><Cmd>lua require('refactoring').refactor('Inline Variable')<CR>]], {noremap = true, silent = true, expr = false})

-------------------
-------------------
-------------------
-- :echo "{sourced}" resolve(expand("%:t")) <CR>')
-- vim.keymap.set('n', '<leader>jA', '<cmd>cd %:p:h<cr><cmd>echo "{cd} "expand("%:p:h")<cr>', { desc = ':cd %:h'})
--vim.keymap.set('n', '<leader>j.', cmd[[cd %:p:h]]..cmd[[echo expand('{cd} %:t')]],                                             { desc = ':cd %:h'})
--vim.keymap.set('n', '<leader>j.', ':cd %:p:h<CR>',                   {cd}                           { desc = ':cd %:h'})
-- vim.keymap.set('n', '<leader>j.', ':cd %:p:h<CR>',                                             { desc = ':cd %:h'})
--vim.keymap.set('n', '<leader>j.', cmd[[cd %:p:h]]..cmd[[echo  '{cd}'expand('%:p:h')]], { desc = ':cd %:h'})
-------------------
-------------------
-------------------
