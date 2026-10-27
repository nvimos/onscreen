-- blink.cmp keys in insert mode (plug-wip/genja-completion011.nvim/lua/genja/completion/keymaps.lua).
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

-- words for the buffer source, so every case has a menu without a language server
local WORDS = { 'zebra zebrafish zebu', '' }

---Scratch conf buffer with WORDS, `zeb` typed, menu open with buffer items.
local function menu()
	C.scratch('conf', 'zeb', WORDS)
	C.labels('buffer')
end

T['the menu opens while typing'] = function()
	C.scratch('conf', 'zeb', WORDS)
	eq(C.wait_menu(), true)
end

T['<CR> accepts the preselected first item'] = function()
	menu()
	eq(C.selected(), 1)
	child.type_keys('<CR>')
	eq(C.line():match('^zeb%a+$') ~= nil, true)
end

T['<CR> with the menu closed is a newline'] = function()
	C.scratch('conf', 'one two')
	child.lua('require("blink.cmp").hide()')
	child.type_keys('<CR>')
	eq(child.lua('return vim.api.nvim_buf_line_count(0)'), 2)
end

T['<Tab> / <S-Tab> walk the menu'] = function()
	menu()
	child.type_keys('<Tab>')
	eq(C.selected(), 2)
	child.type_keys('<S-Tab>')
	eq(C.selected(), 1)
end

T['<F2> / <F3> walk the menu'] = function()
	menu()
	child.type_keys('<F2>')
	eq(C.selected(), 2)
	child.type_keys('<F3>')
	eq(C.selected(), 1)
end

T['<Tab> after text opens the menu'] = function()
	C.scratch('conf', 'zeb', WORDS)
	child.lua('require("blink.cmp").hide()')
	child.type_keys('<Tab>')
	eq(C.wait_menu(), true)
end

T['<Tab> at line start is a real <Tab>'] = function()
	C.scratch('conf', '', WORDS)
	child.type_keys('<Tab>')
	eq(C.line():match('^%s+$') ~= nil, true)
end

T['<C-k> (jolemak <C-e>) cancels and restores the typed text'] = function()
	menu()
	child.type_keys('<Tab>')
	child.type_keys('<C-k>')
	eq(child.lua('return require("blink.cmp").is_menu_visible()'), false)
	eq(C.line(), 'zeb')
end

T['<Tab> / <S-Tab> jump between snippet fields'] = function()
	C.scratch('conf')
	child.lua([[vim.snippet.expand('f(${1:a}, ${2:b})')]])
	-- on field 1: nothing before it
	eq(child.lua('return vim.snippet.active({ direction = -1 })'), false)
	child.type_keys('<Tab>')
	eq(child.lua('return vim.snippet.active({ direction = -1 })'), true)
	child.type_keys('<S-Tab>')
	eq(child.lua('return vim.snippet.active({ direction = -1 })'), false)
	eq(C.line(), 'f(a, b)') -- jumping changes no text
	child.lua('vim.snippet.stop()')
end

return T
