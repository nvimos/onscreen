-- Completion engine. All configuration lives in plug-wip/genja-completion011.nvim
-- (lua/genja/completion/), which calls require('blink.cmp').setup() through
-- require('genja.comps').setup(); so no opts here.
---@type LazySpec
return {
	'saghen/blink.cmp',
	-- a release tag: blink downloads its prebuilt Rust fuzzy matcher for it
	version = '1.*',
	lazy = true, -- loaded as a dependency of genja-completion011
}
