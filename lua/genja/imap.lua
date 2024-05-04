km = vim.keymap.set



vim.keymap.set("n", "<leader>zz", 'write', { desc = 'write', silent = true })
vim.keymap.set("n", "<leader>zZ", 'xit', { desc = 'write, quit', silent = true })


-- page up/down half page at a time
km('', '<PageUp>', '<c-u>zz', { silent = true })
km('', '<PageDown>', '<c-d>zz', { silent = true })

-- km('n', '<c-w><s-right>' , '<c-w>L', { desc = 'move window left'})
-- km('n', '<c-w><s-left>'  , '<c-w>R', { desc = 'move window left'})


vim.keymap.set('n', [[\]], [[l]])

-- vim.keymap.set('', '<F3>', ':tabedit %:p:h<CR>')
vim.keymap.set('n', '<S-F5>', ':source %<CR>:echo "{sourced}" resolve(expand("%:t")) <CR>')

vim.keymap.set('', '<Esc>', '<cmd>nohlsearch<cr><Esc>')
vim.keymap.set('', '<M-]>', ':tabnext<cr>')
vim.keymap.set('', '<M-[>', ':tabprevious<cr>')

-- vim.keymap.set('', '<leader>]', ':tabnext<cr>')
-- vim.keymap.set('', '<leader>[', ':tabprevious<cr>')

--vim.keymap.set('n', '<leader><Space>', ':nohlsearch<CR>')
vim.keymap.set('n', '<leader><space>', '<c-^>', { noremap = true, desc = 'rotate to alternative buffer' }) 
vim.keymap.set('n', '<leader>bb2', '2<c-^>', { noremap = true, desc = 'rotate to alternative buffer' }) 
vim.keymap.set('n', '<leader>bb3', '3<c-^>', { noremap = true, desc = 'rotate to alternative buffer' }) 


vim.keymap.set('n', '<leader>r', 'mjgg=G<CR>`j', { desc = 're-indent gg->G'})


-- {{{ quickly edit init

vim.keymap.set('n', '<leader>eI', -- :tabedit ::: VIMRT/lua/genja/*
	':tabedit '            ..(vim.fn.stdpath('config')..'/lua/genja/')..'<CR>'
	..'<cmd>/init.lua<CR>'
	..'<cmd>nohl<CR>'
	..'<cmd>cd '           ..(vim.fn.stdpath('config')..'/lua/genja/').. '/../..<CR>',
	{ desc = 'edit Init'})

local function confdir(vimc, f) f=f or ""; return '<cmd>'..vimc..' '..vim.fn.stdpath('config')..'/lua/genja/'..f..'<CR>'; end
local function command(vimc) return '<cmd>' .. vimc .. '<CR>' end


-- Search for a file in the confdir.
vim.keymap.set('n', '<leader>ei',
	command('lua Close_nerdtree_wins()')..
	confdir('cd')..
	command('cd ../..')..
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



--[[ LSP ]]--
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'diag prev' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'diag next' })
vim.keymap.set('n', '<leader>cd', vim.diagnostic.setloclist, { desc = 'diag setlocallist' })
vim.keymap.set('n', '<leader>c?', vim.diagnostic.open_float, { desc = 'diag open float' })
-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
	desc = 'LSP Actions',
	group = vim.api.nvim_create_augroup('UserLspConfig', {}),
	callback = function(ev)
		---- vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc' -- complete with <c-x><c-o>
		-- Buffer local mappings.
		-- local opts = { buffer = ev.buf }
		local o = function(desc) return {buffer = ev.buf, desc = desc} end

		vim.keymap.set('n',             '<F2>',    vim.lsp.buf.rename, o("rename"))
		vim.keymap.set({'n', 'i', 'v'}, '<F4>',    vim.diagnostic.goto_next, o("diag next"))
		vim.keymap.set({'n', 'i', 'v'}, '<S-F4>',  vim.diagnostic.goto_prev, o("diag prev"))

		vim.keymap.set('n', 'K', vim.lsp.buf.hover, o("hover/man"))
		vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, o("implementation"))
		vim.keymap.set('n', 'go', vim.lsp.buf.type_definition, o("type definition"))
		vim.keymap.set('n', 'gs', vim.lsp.buf.signature_help, o("signature help"))
		vim.keymap.set('n', 'gr', vim.lsp.buf.references, o("reference"))
		vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, o("declaration"))
		vim.keymap.set('n', 'gd', function() vim.cmd[[split]]; vim.lsp.buf.definition() end , o("definition"))
		vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, o("type definition"))

		vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder,    o("workspace add"))
		vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, o("workspace rm"))
		vim.keymap.set('n', '<space>wl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, o("workspace list"))

		vim.keymap.set('n', '<space>r', function() vim.lsp.buf.format { async = true } end, o("reformat"))

		--  vim.keymap.set('', '<leader>ttd', function() vim.diagnostic.enable(not vim.diagnostic.is_disabled()) end, o[[toggle diagnostics]])

		vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, { buffer = ev.buf, desc = 'Code action' })
		vim.keymap.set({ 'n', 'v' }, '<space>da', vim.lsp.buf.code_action, { buffer = ev.buf, desc = 'Code action' })
		vim.keymap.set({ 'n', 'v' }, '<space>d!', vim.lsp.buf.code_action, { buffer = ev.buf, desc = 'Code action' })
	end,
})

--[[ //LSP ]]--
