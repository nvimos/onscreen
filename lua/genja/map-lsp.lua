local km = vim.keymap.set
local nosi = function(d) return { silent = true, noremap = true, desc = d} end

km('n', '[d',         vim.diagnostic.goto_prev,  nosi 'diag prev' )
km('n', ']d',         vim.diagnostic.goto_next,  nosi 'diag next' )
km('n', '<leader>cd', vim.diagnostic.setloclist, nosi 'diag setlocallist' )
km('n', '<leader>c?', vim.diagnostic.open_float, nosi 'diag open float' )
km('n', '<leader>cc', vim.diagnostic.open_float, nosi 'diag open float' )


km({ 'i', 's' }, '<C-n>',       '<Plug>luasnip-next-choice', nosi 'Luasnip: next')
km({ 'i', 's' }, '<C-p>',       '<Plug>luasnip-prev-choice', nosi 'Luasnip: next')
km({ 'n'      }, '<leader>r2',  '<Plug>(Prettier)',          nosi 'Prettier')
km({ 'v'      }, '<leader>r2',  ':PrettierFragment<cr>',     nosi 'Prettier (frag)')


-- map keys when a server attaches to a buffer
vim.api.nvim_create_autocmd('LspAttach', {
	desc = 'LSP keymaps',
	group = require('genja.lspm').lspConfAugroup,
	callback = function(ev)

		local vlb = vim.lsp.buf
		local o               = function(desc) return { noremap = true, buffer = ev.buf, desc = desc} end
		local reformat        = function() vlb.format { async = true } end
		local list_workspaces = function() print(vim.inspect(vlb.list_workspace_folders())) end
		local split_and       = function(fn) return function() vim.cmd.split(); fn(); end end -- vim.cmd[[split]]
		local niv = {'n', 'i', 'v'}
		local nv = { 'n', 'v' }

		-- buffer-local mappings
		km('n',             '<F2>',    vlb.rename,            o 'rename')
		km(niv, '<F4>',    vim.diagnostic.goto_next,          o 'diag next')
		km(niv, '<S-F4>',  vim.diagnostic.goto_prev,          o 'diag prev')

		km('n', 'gi',   vlb.implementation,                   o 'LSP: implementation')
		km('n', 'go',   vlb.type_definition,                  o 'LSP: type definition')
		km('n', 'gs',   vlb.signature_help,                   o 'LSP: signature help')
		km('n', 'gr',   vlb.references,                       o 'LSP: reference')
		km('n', 'gDd',  vlb.declaration,                      o 'LSP: declaration')
		km('n', 'gDt',  vlb.type_definition,                  o 'LSP: type definition')
		km('n', 'gDs',  split_and(vlb.definition),            o 'LSP: definition (split)')
		km('n', 'gd',   vlb.definition,                       o 'LSP: definition')
		km('n', 'gl',   '<cmd>Telescope diagnostics<cr>',     o 'Telescope diagnostics')

		km('n', '<space>Wa', vlb.add_workspace_folder,        o 'LSP: workspace add')
		km('n', '<space>Wr', vlb.remove_workspace_folder,     o 'LSP: workspace rm')
		km('n', '<space>Wl', list_workspaces,                 o 'LSP: workspace list')

		km('n', '<space>r1', reformat,                        o 'LSP: reformat')
		km('n', '<space>k', vlb.hover,                        o 'LSP: hover/man')
		km('n', '<space>?', vlb.hover,                        o 'LSP: hover/man')
		km('n', 'K',        vlb.hover,                        o 'LSP: hover/man')

		-- Telescope code-actions?
		km(nv, '<space>ca', vlb.code_action, o 'Code action')
		km(nv, '<space>da', vlb.code_action, o 'Code action')
		km(nv, '<space>d!', vlb.code_action, o 'Code action')

		km('', '<leader>ttd', function(s)
			s = vim.diagnostic.is_enabled()
			vim.diagnostic.enable(not s) end, o('toggle diagnostics'))

	end,
})
