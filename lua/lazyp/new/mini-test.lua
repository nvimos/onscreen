-- mini.test: test runner for the in-repo code (tests/, see tests/minimal_init.lua).
-- Only installed here; tests/minimal_init.lua puts it on the rtp itself.
-- Upstream moved from echasnovski/mini.test to nvim-mini/mini.test.
---@type LazySpec
return {
	'nvim-mini/mini.test',
	lazy = true, -- no trigger: never loaded in the editor
}
