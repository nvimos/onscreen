-- Action menu (idea #17): g. and <LocalLeader>/ open a telescope list of what can be
-- done here. `cur:` items act on the item under the cursor (LSP symbol, diagnostic,
-- word, oil entry); unprefixed ones act on the buffer or wider. The list is built
-- when the menu opens, from what is available then.

local M = {}

---@class genja.Action
---@field label string
---@field run fun()
---@field cur? boolean acts on the item under the cursor

-- any LSP client of the buffer supports `method`
local function lsp_has(method, bufnr)
	for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
		if client:supports_method(method, bufnr) then
			return true
		end
	end
	return false
end

local function telescope(picker)
	return function() require('telescope.builtin')[picker]() end
end

---@param list genja.Action[]
local function add(list, label, run, cur)
	table.insert(list, { label = label, run = run, cur = cur })
end

-- {{{ cursor item

local function lsp_cursor_actions(list, bufnr)
	local lsp = vim.lsp.buf
	local methods = {
		{ 'textDocument/definition', 'go to definition', lsp.definition },
		{ 'textDocument/declaration', 'go to declaration', lsp.declaration },
		{ 'textDocument/implementation', 'go to implementation', lsp.implementation },
		{ 'textDocument/typeDefinition', 'go to type definition', lsp.type_definition },
		{ 'textDocument/references', 'references', telescope('lsp_references') },
		{ 'textDocument/rename', 'rename', lsp.rename },
		{ 'textDocument/codeAction', 'code actions', lsp.code_action },
		{ 'textDocument/hover', 'hover docs', lsp.hover },
		{ 'textDocument/signatureHelp', 'signature help', lsp.signature_help },
		{ 'textDocument/prepareCallHierarchy', 'incoming calls', lsp.incoming_calls },
		{ 'textDocument/prepareCallHierarchy', 'outgoing calls', lsp.outgoing_calls },
	}
	for _, m in ipairs(methods) do
		if lsp_has(m[1], bufnr) then
			add(list, m[2], m[3], true)
		end
	end
end

local function diagnostic_cursor_actions(list, bufnr)
	local row = vim.api.nvim_win_get_cursor(0)[1] - 1
	if #vim.diagnostic.get(bufnr, { lnum = row }) > 0 then
		add(list, 'line diagnostics', function() vim.diagnostic.open_float() end, true)
	end
end

local function oil_cursor_actions(list)
	local oil_fn = require('genja.oil')
	add(list, 'git add', oil_fn.git_add, true)
	add(list, 'git unstage (keeps changes)', oil_fn.git_unstage, true)
	add(list, 'diff preview', oil_fn.toggle_diff_preview, true)
	add(list, 'hide via .oily', function() require('genja-oily').hide() end, true)
end

local function word_cursor_actions(list)
	local word = vim.fn.expand('<cword>')
	if word == '' then
		return
	end
	add(list, 'grep "' .. word .. '"', function() require('telescope.builtin').grep_string({ search = word }) end, true)
	add(list, 'inspect highlight (:Inspect)', function() vim.cmd.Inspect() end, true)
end
-- }}}

-- {{{ buffer and wider

local function lsp_buffer_actions(list, bufnr)
	if #vim.lsp.get_clients({ bufnr = bufnr }) == 0 then
		return
	end
	if lsp_has('textDocument/formatting', bufnr) then
		add(list, 'format buffer', function() vim.lsp.buf.format({ async = true }) end)
	end
	if lsp_has('textDocument/documentSymbol', bufnr) then
		add(list, 'document symbols', telescope('lsp_document_symbols'))
	end
	if lsp_has('workspace/symbol', bufnr) then
		add(list, 'workspace symbols', telescope('lsp_dynamic_workspace_symbols'))
	end
	if lsp_has('textDocument/inlayHint', bufnr) then
		add(list, 'toggle inlay hints', function()
			vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
		end)
	end
	add(list, 'LSP health (:checkhealth vim.lsp)', function() vim.cmd('checkhealth vim.lsp') end)
end

local function general_actions(list, bufnr)
	add(list, 'diagnostics (telescope)', telescope('diagnostics'))
	add(list, 'diagnostics to quickfix', function() vim.diagnostic.setqflist() end)
	add(list, 'toggle diagnostics', function() vim.diagnostic.enable(not vim.diagnostic.is_enabled()) end)
	if vim.bo.filetype == 'oil' then
		add(list, 'git commit (popup)', require('genja.oil').git_commit)
	end
	add(list, 'context picker (<F2>: adhoc, git, make)', function() require('genja.f2').open() end)
	add(list, 'find files', function() require('genja-finder').live_find() end)
	add(list, 'grep files', function() require('genja-finder').live_grep() end)
	add(list, 'recent files', telescope('oldfiles'))
	add(list, 'keymaps', telescope('keymaps'))
	add(list, 'commands', telescope('commands'))
	add(list, 'help tags', telescope('help_tags'))
	-- get_parser errors or returns nil without a parser, depending on the nvim version
	local has_parser, parser = pcall(vim.treesitter.get_parser, bufnr)
	if has_parser and parser then
		add(list, 'syntax tree (:InspectTree)', function() vim.cmd.InspectTree() end)
	end
	add(list, 'task list (overseer)', function() vim.cmd('OverseerToggle') end)
end
-- }}}

---@return genja.Action[]
local function collect()
	local bufnr = vim.api.nvim_get_current_buf()
	local list = {}
	if vim.bo.filetype == 'oil' then
		oil_cursor_actions(list)
	else
		lsp_cursor_actions(list, bufnr)
		diagnostic_cursor_actions(list, bufnr)
		word_cursor_actions(list)
	end
	lsp_buffer_actions(list, bufnr)
	general_actions(list, bufnr)
	return list
end

function M.open()
	local list = collect()
	local actions = require('telescope.actions')
	local action_state = require('telescope.actions.state')
	local opts = require('telescope.themes').get_dropdown({ layout_config = { height = 0.6 } })
	require('telescope.pickers').new(opts, {
		prompt_title = 'Actions',
		finder = require('telescope.finders').new_table({
			results = list,
			entry_maker = function(action)
				local text = action.label
				if action.cur then
					text = 'cur: ' .. text
				end
				return { value = action, display = text, ordinal = text }
			end,
		}),
		sorter = require('telescope.config').values.generic_sorter({}),
		attach_mappings = function(bufnr)
			actions.select_default:replace(function()
				local entry = action_state.get_selected_entry()
				actions.close(bufnr)
				if entry then
					vim.schedule(entry.value.run) -- back in the original window first
				end
			end)
			return true
		end,
	}):find()
end

return M
