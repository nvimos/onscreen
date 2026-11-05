local Wip = require('genja.plug-wip')

---@type LazySpec
return {
	'tox2ik/genja-finder.nvim',
	dir = Wip.dir('genja-finder.nvim'),
	dependencies = {
		'nvim-telescope/telescope.nvim',
		{ 'tox2ik/genja-util.nvim', dir = Wip.dir('genja-util.nvim') },
	},
	-- lazy (default), no trigger: loads on the first require('genja-finder'),
	-- i.e. <F1> / <S-F1> / <leader>jj from genja/map-telescope.lua

	---@type genja-finder.Opts
	opts = {
		exclude = { 'node_modules', 'vendor', 'dist', 'go/pkg/mod' },
		exclude_files = { '*.min.js', '*.min.css' },
		attach = function(map) require('genja-finder.telemap').Telemap(map) end,
		hidden = false,
		-- telescope defaults, only pickers with attach_shared_keys (A2); global list (A1):
		-- after/plugin/telescope-after.lua. Uncomment a line to switch that key off.
		unmap = {
			-- { 'i', '<C-n>' }, -- move_selection_next
			-- { 'i', '<C-p>' }, -- move_selection_previous
			-- { 'i', '<C-c>' }, -- close
			-- { 'i', '<Down>' }, -- move_selection_next
			-- { 'i', '<Up>' }, -- move_selection_previous
			-- { 'i', '<CR>' }, -- select_default
			-- { 'i', '<C-x>' }, -- select_horizontal
			-- { 'i', '<C-v>' }, -- select_vertical
			-- { 'i', '<C-t>' }, -- select_tab
			-- { 'i', '<C-u>' }, -- preview_scrolling_up
			-- { 'i', '<C-d>' }, -- preview_scrolling_down
			-- { 'i', '<C-f>' }, -- preview_scrolling_left
			-- { 'i', '<C-k>' }, -- preview_scrolling_right
			-- { 'i', '<PageUp>' }, -- results_scrolling_up
			-- { 'i', '<PageDown>' }, -- results_scrolling_down
			-- { 'i', '<M-f>' }, -- results_scrolling_left (refine uses it)
			-- { 'i', '<M-k>' }, -- results_scrolling_right
			-- { 'i', '<Tab>' }, -- toggle_selection + move_selection_worse
			-- { 'i', '<S-Tab>' }, -- toggle_selection + move_selection_better
			-- { 'i', '<C-q>' }, -- send_to_qflist + open_qflist (map-telescope sets it)
			-- { 'i', '<M-q>' }, -- send_selected_to_qflist + open_qflist (map-telescope sets it)
			-- { 'i', '<C-l>' }, -- complete_tag (map-telescope: loclist)
			-- { 'i', '<C-/>' }, -- which_key (key list)
			-- { 'i', '<C-_>' }, -- which_key (terminals send it for <C-/>)
			-- { 'i', '<C-w>' }, -- delete word
			-- { 'i', '<C-r><C-w>' }, -- insert_original_cword
			-- { 'i', '<C-r><C-a>' }, -- insert_original_cWORD
			-- { 'i', '<C-r><C-f>' }, -- insert_original_cfile
			-- { 'i', '<C-r><C-l>' }, -- insert_original_cline
			-- { 'i', '<C-j>' }, -- nop
			-- { 'n', '<esc>' }, -- close (Telemap sets it)
			-- { 'n', '<CR>' }, -- select_default
			-- { 'n', '<C-x>' }, -- select_horizontal
			-- { 'n', '<C-v>' }, -- select_vertical
			-- { 'n', '<C-t>' }, -- select_tab
			-- { 'n', '<Tab>' }, -- toggle_selection + move_selection_worse
			-- { 'n', '<S-Tab>' }, -- toggle_selection + move_selection_better
			-- { 'n', '<C-q>' }, -- send_to_qflist + open_qflist (map-telescope sets it)
			-- { 'n', '<M-q>' }, -- send_selected_to_qflist + open_qflist (map-telescope sets it)
			-- { 'n', 'j' }, -- move_selection_next
			-- { 'n', 'k' }, -- move_selection_previous
			-- { 'n', 'H' }, -- move_to_top
			-- { 'n', 'M' }, -- move_to_middle
			-- { 'n', 'L' }, -- move_to_bottom
			-- { 'n', '<Down>' }, -- move_selection_next
			-- { 'n', '<Up>' }, -- move_selection_previous
			-- { 'n', 'gg' }, -- move_to_top
			-- { 'n', 'G' }, -- move_to_bottom
			-- { 'n', '<C-u>' }, -- preview_scrolling_up
			-- { 'n', '<C-d>' }, -- preview_scrolling_down
			-- { 'n', '<C-f>' }, -- preview_scrolling_left
			-- { 'n', '<C-k>' }, -- preview_scrolling_right
			-- { 'n', '<PageUp>' }, -- results_scrolling_up
			-- { 'n', '<PageDown>' }, -- results_scrolling_down
			-- { 'n', '<M-f>' }, -- results_scrolling_left (refine uses it)
			-- { 'n', '<M-k>' }, -- results_scrolling_right
			-- { 'n', '?' }, -- which_key (key list)
		},
	},

	config = function(_, opts)
		require('genja-finder').setup(opts)
	end,
}
