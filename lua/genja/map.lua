-- https://github.com/LunarVim/Neovim-from-scratch/blob/master/lua/user/keymaps.lua
local function cmd(c) return '<cmd>'..c..'<cr>' end

-- *default-mappings*
-- nnoremap Y y$
-- nnoremap <C-L> <Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>
-- inoremap <C-U> <C-G>u<C-U>
-- inoremap <C-W> <C-G>u<C-W>
-- xnoremap * y/\V<C-R>"<CR>
-- xnoremap # y?\V<C-R>"<CR>
-- nnoremap & :&&<CR>


-- todo visual select -> :norm ^xx ; :norm I//
--      this would comment / uncomment a block.
--      q: how to get the comment prefix for current language?

--[[
		MAIN MAP
]]


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

local KM = vim.keymap.set 

-- KM('', ':help', ':vert help<cr>', { noremap = true, desc = 'split help vertically by default'})

-- vim.cmd[[ nnoremap <silent> :help :vert help ]]


vim.keymap.set('', '<leader>`', cmd[[wincmd w]], {desc = 'next win'})
vim.keymap.set('', '<C-a>',     cmd[[wincmd w]], {desc = 'next win'})



vim.keymap.set('n', '<leader>v<F1>', cmd[[Telescope help_tags]], { desc = 'Ts help tags'})
vim.keymap.set('n', '<leader>v<F1>', cmd[[Telescope help_tags]], { desc = 'Ts help tags'})
vim.keymap.set('n', '<leader>v1',    cmd[[Telescope help_tags]], { desc = 'Ts help tags'})


-- vim.keymap.set('', '<c-r>', ':redo<cr>')
-- vim.keymap.set('', '<C-d>', ':redo<CR>')

vim.keymap.set('', '<C-d>', '<C-d>zz',   { noremap = true, silent = true })
vim.keymap.set('', '<C-u>', '<C-u>zz',   { noremap = true, silent = true })

-- :set indentexpr=indent('.') + 2

if vim.fn.has('windows') then
	-- with a custom keymap, pressing the keys with control does not generate the expected key-symbol. so I force this. I want do use <C-d> because thats what I remember. and I don't care where <C-d> ~  is on the qwerty layout.
	-- vim.keymap.set('', '', ':redo<CR>', { noremap = true, silent = true })
	-- vim.keymap.set('', '', '<C-d>zz',   { noremap = true, silent = true })
	vim.keymap.set('', '', ':redo<CR>', { noremap = true, silent = true })
	vim.keymap.set('', '', '<C-d>zz',   { noremap = true, silent = true })


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


-- print(vim.fn.has('macunix'))
-- print(vim.loop.os_uname().sysname) -- Windows_NT


vim.keymap.set("n", "<leader>az1", function()
    require("zen-mode").setup {
        window = {
            width = 90,
            options = { }
        },
    }
    require("zen-mode").toggle()
    vim.wo.wrap = false
    vim.wo.number = true
    vim.wo.rnu = true
    -- ColorMyPencils()
end)
vim.keymap.set("n", "<leader>az2", function()
    require("zen-mode").setup {
        window = {
            width = 80,
            options = { }
        },
    }
    require("zen-mode").toggle()
    vim.wo.wrap = false
    vim.wo.number = false
    vim.wo.rnu = false
    vim.opt.colorcolumn = "0"
    -- ColorMyPencils()
end)



vim.keymap.set('n', '<C-/>', ':norm gcc<CR>j')
vim.keymap.set('v', '<C-/>', '<cmd>norm gc<CR>')

--vim.keymap.set('n', '<M-/>', ':norm gcb<CR>')

--vim.keymap.set('v', '<M-/>', ':norm gcb<CR>')


-- vim.keymap.set('v', '<C-/>', ':norm 0i//<CR>')
-- vim.keymap.set('v', '<M-/>', ':norm 0xx<CR>')

vim.keymap.set('n', '<leader>fml-', '<cmd>CellularAutomaton make_it_rain<CR>')
vim.keymap.set('n', '<leader>fml=', '<cmd>CellularAutomaton scramble<CR>')

-- vim.api.nvim_set_keymap('n', '<leader>w"', [[:%s/"/'/g<CR>]], {noremap = true})
vim.keymap.set({'n', 'v'},  '<leader>wsb', [[:'<,'>g/^$/d<cr> <cmd>let @/=''<cr>]],    {noremap = true, desc = [[remove empty lines in visual block]]})
vim.keymap.set({'n', 'v'},  '<leader>wss', [[:%s,\s\+$,,<cr>]],                        {noremap = true, desc = [[remove trailing space]]})
vim.keymap.set({'n', 'v'},  '<leader>w"', [[:s/"/'/g<cr>]],                           {noremap = true, desc = [[replace " with ' on current line]]})

vim.keymap.set('v',  '<leader>w"', [[$A",<esc>gvI"<esc>]],              {noremap = true, desc = [[wrap selection with " ",]]})
--vim.keymap.set('v',  '<leader>w"', [[$o0I"<esc>$A",<esc>]],              {noremap = true, desc = [[wrap selection with " ",]]})

vim.keymap.set('i', '<S-Insert>', '<C-R>+', { noremap = true })

vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)



--vim.keymap.set('n', '<leader>pv', vim.cmd.Ex)
--vim.keymap.set('n', '<leader>ee', vim.cmd.Ex)

--vim.keymap.set('n', '<leader>ep', ':tabedit %:p:h<CR>')

function EdInit()
	local cdir = vim.fn.stdpath('config') .. '/lua/genja/'
	-- vim.cmd(':cd '      .. cdir)
	vim.cmd(':tabedit ' .. cdir)
	vim.cmd[[/init.lua]]
	vim.cmd[[nohl]]
	vim.cmd[[/.]]
	--vim.cmd('/init.lua')
	--vim.cmd(':nohl')

	-- /init<CR><cmd>nohl<CR><cmd>cd ' ..myConf.. '/../..<cr>', { desc = 'edit init'}
end
--

-- local myConf = vim.fn.stdpath('config') .. '/lua/genja/'


-------------------

-- :nnoremap <silent> <Space> :nohlsearch<Bar>:echo<CR>

vim.keymap.set('n', "<leader>t0", "<cmd>tabmove 0<cr>", { desc = "tabmove 0" })
vim.keymap.set('n', "<leader>t-", "<cmd>tabmove -1<cr>", { desc = "tabmove left" })
vim.keymap.set('n', "<leader>t=", "<cmd>tabmove +1<cr>", { desc = "tabmove right" })

vim.keymap.set('n', "<leader>ft", "<cmd>Neotree toggle<cr>", { desc = "NeoTree" })
vim.keymap.set('n', "<leader>fw", "<cmd>Neotree toggle<cr>", { desc = "NeoTree" })



local function init_harpoon()
	local ok, _ = pcall( require, "harpoon")
	if not ok then
		return
	end
	local mark = require("harpoon.mark")
	local ui = require("harpoon.ui")
	-- local function toggle_file_mark() harpoon_mark.add_file() end

	vim.keymap.set("n", "<leader>ea", mark.toggle_file, { desc = 'harpoon mark on/off' })
	vim.keymap.set("n", "<leader>ej", function() ui.toggle_quick_menu() end, { desc = 'harpoon quickmenu'})

	-- vim.keymap.set("n", "<M-e>", function() ui.toggle_quick_menu() end, { desc = 'harpoon quickmenu'})
	-- vim.keymap.set("n", "<M-j>", function() ui.nav_file(1) end, { desc = 'harpoon 1'})
	-- vim.keymap.set("n", "<M-w>", function() ui.nav_file(2) end, { desc = 'harpoon 2'})
	-- vim.keymap.set("n", "<M-f>", function() ui.nav_file(3) end, { desc = 'harpoon 3'})
	-- vim.keymap.set("n", "<M-p>", function() ui.nav_file(4) end, { desc = 'harpoon 4'})
end; init_harpoon()


vim.keymap.set('', '<leader>w`', ':quit<CR>', { desc = ':quit' } )
vim.keymap.set('',     '<C-W>`', ':quit<CR>', { desc = ':quit' } )

-- move to plugin spec -- vim.keymap.set('', '<leader>jD', vim.cmd.Dashboard, { desc = 'Dashboard' } )
vim.keymap.set('', '<leader>jm', vim.cmd.MRU, { desc = 'MRU' } )

--- vim.keymap.set('', '<S-F2>', ':edit ~/AppData/Local/nvim/lua/mymap.lua<CR>')
--- vim.keymap.set('', '<S-F1>', ':edit ~/AppData/Local/nvim/lua/plugins.lua<CR>')
--- vim.keymap.set('',   '<F1>', ':edit ~/AppData/Local/nvim/init.lua<CR>')




-- vim.keymap.set('n', '<S-F5>', ':source %<CR>
-- :echo "{sourced}" resolve(expand("%:t")) <CR>')

-- vim.keymap.set('n', '<leader>jA', '<cmd>cd %:p:h<cr><cmd>echo "{cd} "expand("%:p:h")<cr>', { desc = ':cd %:h'})
--vim.keymap.set('n', '<leader>j.', cmd[[cd %:p:h]]..cmd[[echo expand('{cd} %:t')]],                                             { desc = ':cd %:h'})
--vim.keymap.set('n', '<leader>j.', ':cd %:p:h<CR>',                   {cd}                           { desc = ':cd %:h'})
-- vim.keymap.set('n', '<leader>j.', ':cd %:p:h<CR>',                                             { desc = ':cd %:h'})
--vim.keymap.set('n', '<leader>j.', cmd[[cd %:p:h]]..cmd[[echo  '{cd}'expand('%:p:h')]], { desc = ':cd %:h'})


vim.keymap.set('n', '<leader>j.', ':cd %:p:h<cr>:pwd<cr>', { desc = ':cd dirname(%)'})
vim.keymap.set('n', '<leader>j,', ':cd ..   <cr>:pwd<cr>', { desc = ':cd ..'})


--  n o v
-- vim.keymap.set('n',        '<F3>', ':CycleDirs<cr>', { desc = 'tabedit CWD' }) -- override init-map
vim.keymap.set('n',        '<F3>', ':Telescope mydirs<cr>', { desc = 'tabedit CWD' }) -- override init-map


local ok, te = pcall(require, 'telescope.builtin')
if ok then
	local km = vim.keymap.set

	-- km('n', '<leader>jj', te.live_grep, { desc = '() live_grep 󰵃'})
	km('n', '<leader>jj', te.live_grep, { desc = '() live 󰵃'})
	km('n', '<leader>jg', te.git_files, { desc = '() git_files'})
	km('n', '<leader>jh', te.help_tags, { desc = '() help_tags'})
	km('n', '<leader>j?', te.builtin,   { desc = '() builtin'})
	km('n', '<leader>jb', te.buffers,   { desc = '() buffers'})
	km('n', '<leader>jr', te.registers,     { desc = '() registers'})
	km('n', '<leader>jo', te.oldfiles,  { desc = '() oldfiles'})
	km('n', '<leader>jd', Telescope_find_dirs, { desc = '() dirs󰅲'})

	km('n', '<leader>jm', te.marks,     { desc = '() marks'})

	km('n', '<leader>jq', te.quickfix,  { desc = '() quickfix'})
	km('n', '<leader>jl', te.loclist,  { desc = '() loclist'})
	km('n', '<leader>jv', te.vim_options,  { desc = '() vim_options'})
	km('n', '<leader>jC', te.colorscheme,   { desc = '() colorscheme'})
	km('n', '<leader>jM', te.keymaps,     { desc = '() keymaps'})
	km('n', '<leader>jA', te.autocommands,     { desc = '() autocommands'})


	km('n', '<leader>js', function()
		te.grep_string({ search = vim.fn.input("Grep: ") })
	end, {  desc = '() grep'})

	km('n', '<F1>', te.find_files,                    { desc = '() find_files'})
	km('n', '<S-F1>', te.oldfiles,                    { desc = '() oldfiles'})
	km('n', '<leader>j/.', te.find_files,                    { desc = '() find_files'})
	km('n', '<leader>j//', ':lua Telescope_find_dirs()<CR>', { desc = '() dirs()'})
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
end







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
