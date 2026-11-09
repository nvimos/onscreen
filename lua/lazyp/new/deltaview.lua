-- Inline git diff in a separate read-only buffer (deleted lines are real lines you can yank), word-level highlights.
-- Upstream: kokusenz/deltaview.nvim (does not use the delta binary). Alternatives: unified.nvim, diffview.
-- To try: `:DeltaView [ref]` current file, `:Delta [path] [context] [ref]`, `:DeltaMenu[!] [ref]` file picker or quickfix.
-- Its default keybinds are made at startup by the plugin; lazy-loaded through `cmd` they don't exist until the first command.

---@type LazySpec
return {
	'kokusenz/deltaview.nvim',
	cmd = { 'DeltaView', 'Delta', 'DeltaMenu' },
	---@type table
	opts = {
		-- The defaults <leader>dm/dl/da would replace `<leader>dl` (dap: list breakpoints, map-plugin/dap-php.lua)
		-- once the plugin loads. Start it from the F2 items or the commands instead.
		keyconfig = {
			dm_toggle_keybind = '<Plug>(deltaview-menu)',
			dv_toggle_keybind = '<Plug>(deltaview-view)',
			d_toggle_keybind = '<Plug>(deltaview-delta)',
			-- next_hunk = '<Tab>', prev_hunk = '<S-Tab>', help_legend = 'd?', -- default, in diff buffers only
		},
	},
}
