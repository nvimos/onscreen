-- blink.cmp setup in the real config: matcher, look, and where completion stays off.
-- `make test D=completion` in tests/.
local Helpers = require('helpers.completion')
local child = MiniTest.new_child_neovim()
local C = Helpers.new(child)
local eq = MiniTest.expect.equality

local T = MiniTest.new_set({
	hooks = {
		pre_once = C.boot,
		post_case = C.esc,
		post_once = function() child.stop() end,
	},
})

T['fuzzy matcher: the prebuilt Rust one'] = function()
	-- implementation_type is set on the first completion only; the config and the download are not
	eq(child.lua('return require("blink.cmp.config").fuzzy.implementation'), 'prefer_rust_with_warning')
	local lib = vim.fn.stdpath('data') .. '/lazy/blink.cmp/target/release/libblink_cmp_fuzzy'
	local found = vim.uv.fs_stat(lib .. '.dll') or vim.uv.fs_stat(lib .. '.so') or vim.uv.fs_stat(lib .. '.dylib')
	eq(found ~= nil, true)
end

T['nvim-cmp is not loaded'] = function()
	eq(child.lua('return package.loaded.cmp == nil and package.loaded.cmp_nvim_lsp == nil'), true)
end

T['default sources: lsp, path, buffer, minuet'] = function()
	-- minuet (lua/genja/completion/minuet.lua) is listed but only answers <M-y> until :Minuet blink toggle
	eq(child.lua('return require("blink.cmp.config").sources.default'), { 'lsp', 'path', 'buffer', 'minuet' })
end

T['minuet stays out of a normal request, answers <M-y>'] = function()
	eq(child.lua([[
		local provider = require('blink.cmp.config').sources.providers.minuet
		local trigger = require('blink.cmp.completion.trigger')
		local saved = trigger.context
		trigger.context = { providers = { 'lsp', 'path', 'buffer', 'minuet' } }
		local normal = provider.enabled()
		trigger.context = { providers = { 'minuet' } }
		local alone = provider.enabled()
		trigger.context = saved
		return { normal, alone }
	]]), { false, true })
end

T['LSP capabilities ask for snippets'] = function()
	eq(child.lua([[
		local caps = vim.lsp.config['*'].capabilities or {}
		return vim.tbl_get(caps, 'textDocument', 'completion', 'completionItem', 'snippetSupport')
	]]), true)
end

T['menu in the StatusLine colours, docs shown'] = function()
	local menu = child.lua('return require("blink.cmp.config").completion.menu.winhighlight')
	eq(vim.startswith(menu, 'Normal:StatusLine'), true)
	eq(child.lua('return require("blink.cmp.config").completion.documentation.auto_show'), true)
end

T['off in prompt buffers (telescope)'] = function()
	child.lua('vim.bo.buftype = "prompt"')
	eq(child.lua('return require("blink.cmp.config").enabled()'), false)
	child.cmd('enew!')
end

T['off in the ask popup'] = function()
	child.lua([[require('genja-ask').open()]])
	eq(child.lua('return vim.b.completion'), false)
	child.type_keys('<Esc>', 'q')
end

T['copilot leaves <Tab> to blink'] = function()
	eq(child.lua('return vim.g.copilot_no_tab_map'), true)
end

return T
