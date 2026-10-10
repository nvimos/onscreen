local km, bkm = vim.keymap.set, vim.api.nvim_buf_set_keymap ---@diagnostic disable-line: unused-local
local nosi    = function(d) return { silent = true, noremap = true, desc = d } end


-- {{{ plugins

-- {{{ luasnip
km({ 'i', 's' }, '<C-n>', '<Plug>luasnip-next-choice', nosi 'Luasnip: next')
km({ 'i', 's' }, '<C-p>', '<Plug>luasnip-prev-choice', nosi 'Luasnip: next')
-- }}}

-- {{{ prettier plug
km({ 'n' }, '<leader>r2', '<Plug>(Prettier)', nosi 'Prettier')
km({ 'v' }, '<leader>r2', ':PrettierFragment<cr>', nosi 'Prettier (frag)')
-- }}}

-- {{{ genja-completion011: lsp check
-- global, not in LspAttach: it has to work when no server is attached
km({ 'n' }, '<leader>ch', '<Plug>CheckHealthLspSimple', nosi 'LSP: check server is attached')
-- }}}
-- }}}






-- {{{ lsp attach autocommand

-- {{{ mode variables
local niv, nv_, n__   = { 'n', 'i', 'v' }, { 'n', 'v' }, { 'n' }
local i__   = { 'i', }
-- }}}

-- {{{ buf-local keymap functions
local vlb       = vim.lsp.buf
local reformat  = function() vlb.format { async = true } end
local split_and = function(fn) return function() vim.cmd.split(); fn(); end end                                                                     -- vim.cmd[[split]]
local goto_prev = function() vim.diagnostic.jump({ count = -1, float = true }) end
local goto_next = function() vim.diagnostic.jump({ count = 1,  float = true }) end

local list_workspaces     = function() print(vim.inspect(vlb.list_workspace_folders())) end
local toggle_diagnostics  = function() vim.diagnostic.enable(not vim.diagnostic.is_enabled()) end
local toggle_inline_hints = function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({})) end
-- }}}


-- map keys when a server attaches to a buffer
vim.api.nvim_create_autocmd('LspAttach', {
	desc = 'LSP keymaps',
	-- group = vim.api.nvim_create_augroup('UserLspConfig', { clear = false }),
	group = 'UserLspConfig',
	callback = function(ev)
		local o = function(desc) return { silent = true, noremap = true,  desc = desc, buffer = ev.buf } end -- buffer-local mappings

		-- {{{ Actions
		km(n__, '<F2>',      vlb.rename, o 'LSP: rename')
		km(n__, '<space>r1', reformat,   o 'LSP: reformat')

		km(nv_, '<space>ca', vlb.code_action, o 'LSP: Code action')
		km(nv_, '<space>!', vlb.code_action, o 'LSP: Code action')
		-- }}}

		-- {{{ Man or Doc or Hover
		km(n__, 'K',         vlb.hover, o 'LSP: hover/man')
		km(n__, '<space>k',  vlb.hover, o 'LSP: hover/man')
		km(n__, '<space>c?', vlb.hover, o 'LSP: hover/man')
		km(i__, '<c-?>',     vlb.hover, o 'LSP: hover/man') -- testing 2026-10
		-- }}}

		-- {{{ Jumps or navigation
		km(n__, 'gi',  vlb.implementation,        o 'LSP: implementation')
		km(n__, 'g<up>',  vlb.implementation,        o 'LSP: implementation') --  new
		km(n__, 'gs',  vlb.signature_help,        o 'LSP: signature help')
		km(n__, 'g?',  vlb.signature_help,        o 'LSP: signature help') -- new
		km(n__, 'gr',  vlb.references,            o 'LSP: reference')

		km(n__, 'gDd', vlb.declaration,           o 'LSP: declaration')
		km(n__, 'gDt', vlb.type_definition,       o 'LSP: type definition')
		km(n__, 'gDs', split_and(vlb.definition), o 'LSP: definition (split)')

		km(n__, 'gd',  vlb.definition,            o 'LSP: definition')
		km(n__, '<space>]', vlb.definition, o 'LSP: definition')
		-- }}}

		-- {{{ Diagnostics
		km(n__, '[d',          goto_next,                        o 'Diagnostic: prev') -- rename bind
		km(n__, ']d',          goto_prev,                        o 'Diagnostic: next')  -- rename bind
		km(n__, '<f4>',        goto_next,                        o 'Diagnostic: prev')
		km(n__, '<s-f4>',      goto_prev,                        o 'Diagnostic: next')
		km(n__, '<leader>cdd', vim.diagnostic.setloclist,        o 'Diagnostic: loc list')
		km(n__, '<leader>cdt', '<cmd>Telescope diagnostics<cr>', o 'Diagnostic: in telescope ')
		km(n__, '<leader>cc?',  vim.diagnostic.open_float,        o 'Diagnostic: open float')
		km(n__, '<leader>ccc',  vim.diagnostic.open_float,        o 'Diagnostic: open float')
		-- }}}

		-- {{{ Workspace dirs
		km(n__, '<space>cWa', vlb.add_workspace_folder, o 'LSP: workspace add')
		km(n__, '<space>cWr', vlb.remove_workspace_folder, o 'LSP: workspace rm')
		km(n__, '<space>cWl', list_workspaces, o 'LSP: workspace list')
		-- }}}


		-- {{{ Toggle noise
		km('', '<leader>ttt', toggle_diagnostics,  o('Toggle: diagnostics'))
		km('', '<leader>tth', toggle_inline_hints, o('Toggle: inlay hints')) -- arg names, types, [1] [2] indices; off by default
		-- }}}

		if vim.bo[ev.buf].filetype == 'php' then
			-- PHP: add @param & @return in file or selection, all at once
			km(nv_, '<space>cAp', ':PhpDocParams<cr>', o 'LSP: PHP: add @param and @return tags')
		end

	end,
})

-- }}}
