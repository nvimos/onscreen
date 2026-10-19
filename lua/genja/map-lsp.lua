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

-- {{{ LSP float (hover, signature, diagnostic): <Esc> closes, <C-f>/<C-b> scroll
-- global maps: the float is found through the source buffer, so no LspAttach needed

-- window id set on the source buffer by vim.lsp.util.open_floating_preview
local function lsp_float_win()
	local win = vim.b.lsp_floating_preview
	if win and vim.api.nvim_win_is_valid(win) then
		return win
	end
	return nil
end

-- scroll the float by half its height, else run the key as usual
local function scroll_lsp_float(float_key, fallback_key)
	return function()
		local win = lsp_float_win()
		if not win then
			vim.cmd('normal! ' .. vim.v.count1 .. vim.keycode(fallback_key))
			return
		end
		local half = math.max(math.floor(vim.api.nvim_win_get_height(win) / 2), 1)
		vim.api.nvim_win_call(win, function()
			vim.cmd('normal! ' .. half .. vim.keycode(float_key))
		end)
	end
end
km('n', '<C-f>', scroll_lsp_float('<C-e>', '<C-f>'), nosi 'LSP: scroll float down, else page down')
km('n', '<C-b>', scroll_lsp_float('<C-y>', '<C-b>'), nosi 'LSP: scroll float up, else page up')

-- works from the source buffer and from inside a focused float
local function close_lsp_float()
	local win = lsp_float_win()
	if vim.w.lsp_floating_bufnr then
		win = vim.api.nvim_get_current_win() -- cursor is inside the float
	end
	if win and vim.api.nvim_win_is_valid(win) then
		vim.api.nvim_win_close(win, true)
	end
	-- fed as keys ('n' = noremap): :nohlsearch has no effect inside a function,
	-- and a remapped <Esc> would re-enter this mapping
	vim.api.nvim_feedkeys(vim.keycode('<Cmd>nohlsearch<CR><Esc>'), 'n', false)
end
-- replaces map-zero.lua's normal-mode <Esc>, keeps its nohlsearch
km('n', '<Esc>', close_lsp_float, nosi 'LSP: close float, nohlsearch')
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

-- code actions of one kind and its subkinds ('refactor.extract' also matches
-- 'refactor.extract.function'); in visual mode the selection is the range
local action_kind = function(kind) return function() vlb.code_action({ context = { only = { kind } } }) end end
-- }}}


-- map keys when a server attaches to a buffer
vim.api.nvim_create_autocmd('LspAttach', {
	desc = 'LSP keymaps',
	-- group = vim.api.nvim_create_augroup('UserLspConfig', { clear = false }),
	group = 'UserLspConfig',
	callback = function(ev)
		local o = function(desc) return { silent = true, noremap = true,  desc = desc, buffer = ev.buf } end -- buffer-local mappings

		-- {{{ Actions
		-- km(n__, '<F2>',      vlb.rename, o 'LSP: rename') -- <F2> is the context picker (genja/f2/)
		km(n__, '<leader>r1', reformat,   o 'LSP: reformat')

		km(nv_, '<leader>ca', vlb.code_action, o 'LSP: Code action')
		km(nv_, '<leader>!', vlb.code_action, o 'LSP: Code action')

		-- by kind. Extract needs a visual selection (statements, or one expression);
		-- rewrite, quickfix and source work at the cursor.
		-- search & replace is <leader>cS (map-convoluted.lua)
		km(nv_, '<leader>cq', action_kind('quickfix'),         o 'LSP: Code action: quickfix')
		km(nv_, '<leader>ce', action_kind('refactor.extract'), o 'LSP: Code action: extract (select first)')
		km(nv_, '<leader>cr', action_kind('refactor.rewrite'), o 'LSP: Code action: rewrite')
		km(nv_, '<leader>cs', action_kind('source'),           o 'LSP: Code action: source (imports, docs, tests)')
		-- }}}

		-- {{{ Man or Doc or Hover
		km(n__, 'K',         vlb.hover, o 'LSP: hover/man')
		km(n__, '<leader>k',  vlb.hover, o 'LSP: hover/man')
		km(n__, '<leader>c?', vlb.hover, o 'LSP: hover/man')
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
		km(n__, '<leader>]', vlb.definition, o 'LSP: definition')
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
		km(n__, '<leader>cWa', vlb.add_workspace_folder, o 'LSP: workspace add')
		km(n__, '<leader>cWr', vlb.remove_workspace_folder, o 'LSP: workspace rm')
		km(n__, '<leader>cWl', list_workspaces, o 'LSP: workspace list')
		-- }}}


		-- {{{ Toggle noise
		km('', '<leader>ttt', toggle_diagnostics,  o('Toggle: diagnostics'))
		km('', '<leader>tth', toggle_inline_hints, o('Toggle: inlay hints')) -- arg names, types, [1] [2] indices; off by default
		-- }}}

		if vim.bo[ev.buf].filetype == 'php' then
			-- PHP: add @param & @return in file or selection, all at once
			km(nv_, '<leader>cAp', ':PhpDocParams<cr>', o 'LSP: PHP: add @param and @return tags')
		end

	end,
})

-- }}}
