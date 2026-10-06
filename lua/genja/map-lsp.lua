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
	-- group = vim.api.nvim_create_augroup('UserLspConfig', { clear = false }),
	group = 'UserLspConfig',
	callback = function(ev)

		local vlb = vim.lsp.buf
		local o               = function(desc) return { noremap = true, buffer = ev.buf, desc = desc} end
		local reformat        = function() vlb.format { async = true } end
		local list_workspaces = function() print(vim.inspect(vlb.list_workspace_folders())) end
		local split_and       = function(fn) return function() vim.cmd.split(); fn(); end end -- vim.cmd[[split]]
		local niv, nv_, n__ = {'n', 'i', 'v'}, { 'n', 'v' }, { 'n' }


		-- buffer-local mappings
		km('n',             '<F2>',    vlb.rename,            o 'rename')
		km(niv, '<F4>',    vim.diagnostic.goto_next,          o 'diag next')
		km(niv, '<S-F4>',  vim.diagnostic.goto_prev,          o 'diag prev')

		km(n__, 'gi',   vlb.implementation,                   o 'LSP: implementation')
		km(n__, 'go',   vlb.type_definition,                  o 'LSP: type definition')
		km(n__, 'gs',   vlb.signature_help,                   o 'LSP: signature help')
		km(n__, 'gr',   vlb.references,                       o 'LSP: reference')
		km(n__, 'gDd',  vlb.declaration,                      o 'LSP: declaration')
		km(n__, 'gDt',  vlb.type_definition,                  o 'LSP: type definition')
		km(n__, 'gDs',  split_and(vlb.definition),            o 'LSP: definition (split)')
		km(n__, 'gd',   vlb.definition,                       o 'LSP: definition')
		km(n__, 'gl',   '<cmd>Telescope diagnostics<cr>',     o 'Telescope diagnostics')

		km(n__, '<space>]',  vlb.definition,                  o 'LSP: definition')


		km(n__, '<space>Wa', vlb.add_workspace_folder,        o 'LSP: workspace add')
		km(n__, '<space>Wr', vlb.remove_workspace_folder,     o 'LSP: workspace rm')
		km(n__, '<space>Wl', list_workspaces,                 o 'LSP: workspace list')

		km(n__, '<space>r1', reformat,                        o 'LSP: reformat')
		km(n__, '<space>k', vlb.hover,                        o 'LSP: hover/man')
		km(n__, '<space>?', vlb.hover,                        o 'LSP: hover/man')
		km(n__, 'K',        vlb.hover,                        o 'LSP: hover/man')

		-- maybe: integrate with Telescope code-actions
		km(nv_, '<space>ca', vlb.code_action, o 'Code action')

		km('', '<leader>ttt', function(s) vim.diagnostic.enable(not vim.diagnostic.is_enabled()) end, o('toggle diagnostics'))
		-- parameter names, types, [1] table indexes shown inline; off by default
		km('', '<leader>tth', function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({})) end, o('toggle inlay hints'))


		-- -- close hover window
		-- km('n', '<esc>', function()
		-- 		local win = vim.api.nvim_get_current_win()
		-- 		if vim.api.nvim_win_get_config(win).relative == 'win' then
		-- 			vim.api.nvim_win_close(win, false)
		-- 		else
		-- 			vim.cmd ':norm <C-w>'
		-- 		end
		-- 	end)

	end,
})
