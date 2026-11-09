-- Inline unified diff in the buffer itself (virtual lines for deleted text), plus a changed-files tree.
-- Upstream: axkirillov/unified.nvim. Alternatives: deltaview.nvim (separate read-only buffer), diffview.
-- To try: `:Unified` (`:Unified -t` in a new tab); see the plugin README for the rest. File tree icons want a Nerd Font.

---@type LazySpec
return {
	'axkirillov/unified.nvim',
	cmd = { 'Unified' },
	---@type table
	opts = {
		-- file_tree = { enabled = true, width = 30, focus = false }, -- default
		-- tab = false, -- default; true opens the diff in a new tab
		-- auto_refresh = true, -- default
	},
}
