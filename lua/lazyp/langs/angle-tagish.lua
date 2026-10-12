---@type LazySpec
-- todo: test-me-2026-10
return {
	'windwp/nvim-ts-autotag',
	event = 'BufEnter *.html,*.xml,*.php,*.jsx',

	-- Automatically close and rename <> tags
	-- Useful for HTML, JSX/TSX, Vue, Svelte, PHP, Markdown, etc
	---@type nvim-ts-autotag.Opts
	opts = {
		enable_close = true,     -- insert matching closing tag after `>`
		enable_rename = true,    -- rename closing tag when opening tag changes
		enable_close_on_slash = false, -- typing `/` converts an open tag to self-closing
	},
}
