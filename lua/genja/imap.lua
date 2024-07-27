local km = vim.keymap.set
local vim = vim



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


vim.keymap.set('n', '<leader>ee', '<cmd>:edit %:p:h<cr>/',    { desc = 'edit CWD' })
vim.keymap.set('n', '<leader>e.', '<cmd>:edit %:p:h<cr>',    { desc = 'edit CWD %:h (dirname)'})
vim.keymap.set('n', '<leader>et', '<cmd>:tabedit %:p:h<cr>', { desc = 'tabedit CWD' })


--
-- vim.keymap.set('n', '<leader>lo', command('only'), { desc = 'only this window' })
-- vim.keymap.set('n', '<leader>le', command('wincmd ='), { desc = 'equalize windows' })
-- vim.keymap.set('n', '<leader>lm', command('resize | vertical resize'), { desc = 'maximize current' })
vim.keymap.set('n', '<c-w>m',     command('resize | vertical resize'), { desc = 'maximize current' })

-- Redo!
vim.keymap.set('n', '!', ':<up><home><c-right>!<cr>') -- repeat last command with a bang


--[[ LSP ]]--
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'diag prev' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'diag next' })
vim.keymap.set('n', '<leader>cd', vim.diagnostic.setloclist, { desc = 'diag setlocallist' })
vim.keymap.set('n', '<leader>c?', vim.diagnostic.open_float, { desc = 'diag open float' })
--[[ map keys when a server attaches to a buffer ]]--
vim.api.nvim_create_autocmd('LspAttach', {
	desc = 'LSP Actions',
	group = vim.api.nvim_create_augroup('UserLspConfig', {}),
	callback = function(ev)
		---- vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc' -- complete with <c-x><c-o>

		--[[ buffer local mappings ]]--
		local o = function(desc) return {buffer = ev.buf, desc = desc} end
		local vlb = vim.lsp.buf
		local split_and = function(fn)  return function() vim.cmd[[split]]; fn(); end end
		local list_workspaces = function() print(vim.inspect(vlb.list_workspace_folders())) end
		local reformat = function() vlb.format { async = true } end


		km('n',             '<F2>',    vlb.rename, o("rename"))
		km({'n', 'i', 'v'}, '<F4>',    vim.diagnostic.goto_next, o("diag next"))
		km({'n', 'i', 'v'}, '<S-F4>',  vim.diagnostic.goto_prev, o("diag prev"))

		km('n', 'gi',   vlb.implementation,                             o("implementation"))
		km('n', 'go',   vlb.type_definition,                            o("type definition"))
		km('n', 'gs',   vlb.signature_help,                             o("signature help"))
		km('n', 'gr',   vlb.references,                                 o("reference")) -- Telescope references?
		km('n', 'gDd',  vlb.declaration,                                o("declaration"))
		km('n', 'gDt',  vlb.type_definition,                            o("type definition"))
		km('n', 'gDs',  split_and(vlb.definition),                      o("definition"))
		km('n', 'gd',   vlb.definition,                                 o("definition"))
		km('n', 'gl',   '<cmd>Telescope diagnostics<cr>',                   o("Telescope diagnostics"))

		km('n', '<space>wa', vlb.add_workspace_folder,                   o("workspace add"))
		km('n', '<space>wr', vlb.remove_workspace_folder,                o("workspace rm"))
		km('n', '<space>wl', list_workspaces,                            o("workspace list"))

		km('n', '<space>r', reformat,  o("reformat"))
		km('n', '<space>k', vlb.hover,                                   o("hover/man"))
		km('n', '<space>?', vlb.hover,                                   o("hover/man"))
		km('n', 'K',        vlb.hover,                                   o("hover/man"))

		--  km('', '<leader>ttd', function() vim.diagnostic.enable(not vim.diagnostic.is_disabled()) end, o[[toggle diagnostics]])

		-- Telescope code-actions?
		km({ 'n', 'v' }, '<space>ca', vlb.code_action, { buffer = ev.buf, desc = 'Code action' })
		km({ 'n', 'v' }, '<space>da', vlb.code_action, { buffer = ev.buf, desc = 'Code action' })
		km({ 'n', 'v' }, '<space>d!', vlb.code_action, { buffer = ev.buf, desc = 'Code action' })

		--[[ nvchad:

		map("n", "gD", vim.lsp.buf.declaration, opts "Go to declaration")
		map("n", "gd", vim.lsp.buf.definition, opts "Go to definition")
		map("n", "K", vim.lsp.buf.hover, opts "hover information")
		map("n", "gi", vim.lsp.buf.implementation, opts "Go to implementation")
		map("n", "<leader>sh", vim.lsp.buf.signature_help, opts "Show signature help")
		map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts "Add workspace folder")
		map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts "Remove workspace folder")

		map("n", "<leader>wl", function()
		print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
		end, opts "List workspace folders")

		map("n", "<leader>D", vim.lsp.buf.type_definition, opts "Go to type definition")

		map("n", "<leader>ra", function()
		require "nvchad.lsp.renamer"()
		end, opts "NvRenamer")

		map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts "Code action")
		map("n", "gr", vim.lsp.buf.references, opts "Show references")


		]]--
	end,
})

--[[ //LSP ]]--
