-- Side-by-side diffs and file history in a tab.
-- Fork of sindrets/diffview.nvim (no updates since 2024-06); same module and commands.

local Maps = require('genja.map-plugin')

-- Keys in the file / history panel that scroll the diff windows instead of the panel.
-- diffview's scroll_view(n): n lines (n < 0 up), or a fraction of the window height (not 1.0, that is one line).
-- It is required when the key is pressed: diffview is not loaded when this file is.
---@param distance number
---@return fun()
local function scroll_diff(distance)
	return function() require('diffview.actions').scroll_view(distance)() end
end

local panel_scroll_keys = {
	{ 'n', '<C-e>',      scroll_diff(1),    { desc = 'Scroll the diff down a line' } },
	{ 'n', '<C-y>',      scroll_diff(-1),   { desc = 'Scroll the diff up a line' } },
	{ 'n', '<PageDown>', scroll_diff(0.9),  { desc = 'Scroll the diff down a page' } },
	{ 'n', '<PageUp>',   scroll_diff(-0.9), { desc = 'Scroll the diff up a page' } },
}

-- File panel only: moving over a file opens its diff (lua/genja/ext/diffview-autopreview.lua).
local function preview_move(direction)
	return function() require('genja.ext.diffview-autopreview').move(direction) end
end

local file_panel_keys = vim.list_extend({
	{ 'n', 'j',      preview_move(1),  { desc = 'Next file, open its diff' } },
	{ 'n', '<Down>', preview_move(1),  { desc = 'Next file, open its diff' } },
	{ 'n', 'k',      preview_move(-1), { desc = 'Previous file, open its diff' } },
	{ 'n', 'J',      preview_move(-1), { desc = 'Previous file, open its diff' } },
	{ 'n', '<LeftMouse>', function() require('genja.ext.diffview-autopreview').click() end, { desc = 'Click a file, open its diff' } },
	{ 'n', '<ScrollWheelDown>', preview_move(1),  { desc = 'Next file, open its diff' } },
	{ 'n', '<ScrollWheelUp>',   preview_move(-1), { desc = 'Previous file, open its diff' } },
	{ 'n', '<Up>',   preview_move(-1), { desc = 'Previous file, open its diff' } },
}, panel_scroll_keys)

---@type LazySpec
return {
	'dlyongemallo/diffview.nvim',
	cmd = {
		'DiffviewOpen', 'DiffviewClose', 'DiffviewToggleFiles', 'DiffviewFocusFiles',
		'DiffviewRefresh', 'DiffviewFileHistory',
	},
	keys = Maps:keys(),
	---@type DiffviewConfig
	opts = {
		enhanced_diff_hl = true,
		show_help_hints = false,
		use_icons = false, -- no devicons
		view = {
			-- winbar_info: diffview labels each pane (`WORKING TREE - path`, `<sha>:path`);
			-- off, genja-statusline's winbar shows the bare file name on both panes
			default = { layout = 'diff2_horizontal', winbar_info = true },
			merge_tool = { layout = 'diff3_mixed', disable_diagnostics = true, winbar_info = true },
			file_history = { winbar_info = false },
			-- the F2 item `diffview toggle mode` cycles through these two
			cycle_layouts = { default = { 'diff2_horizontal', 'diff1_inline' } },
		},
		file_panel = {
			listing_style = 'tree',
			tree_options = { flatten_dirs = true, folder_statuses = 'only_folded' },
			win_config = { position = 'left', width = 35 },
		},
		file_history_panel = { win_config = { position = 'bottom', height = 14 } },
		keymaps = {
			file_panel = file_panel_keys,
			file_history_panel = panel_scroll_keys,
		},
		hooks = {
			diff_buf_win_enter = function(_, winid, ctx)
				-- branch / commit names in the winbar instead of hashes: lua/genja/ext/diffview-labels.lua
				require('genja.ext.diffview-labels').set(winid, ctx)
				-- red/green sides; goes away with the fold in lua/genja/hilite.lua
				local hilite = require('genja.hilite')
				if hilite.diffview_sides then
					hilite.diffview_sides(ctx)
				end
			end,
		},
	},
}
