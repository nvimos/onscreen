-- smart-splits.nvim: resize/move across splits, also into wezterm/kitty/tmux panes (idea 28).
-- not used: 2026-10 — lua/genja/winsize.lua covers resizing for now; enable to compare.
-- Keys: <M-h/j/k/l> resize (normal mode; free there), <leader>wR its own resize mode.

---@class SmartSplitsOpts
---@field ignored_buftypes? string[]
---@field ignored_filetypes? string[]
---@field default_amount? integer cells per resize step
---@field at_edge? 'wrap'|'split'|'stop' moving the cursor past the last window
---@field move_cursor_same_row? boolean
---@field cursor_follows_swapped_bufs? boolean
---@field resize_mode? table
---@field multiplexer_integration? false|'wezterm'|'kitty'|'tmux'
---@field log_level? string

---@type LazySpec
return {
	'mrjones2014/smart-splits.nvim',
	enabled = false,
	keys = {
		{ '<M-h>', function() require('smart-splits').resize_left() end, desc = 'Window: resize left (smart-splits)' },
		{ '<M-j>', function() require('smart-splits').resize_down() end, desc = 'Window: resize down (smart-splits)' },
		{ '<M-k>', function() require('smart-splits').resize_up() end, desc = 'Window: resize up (smart-splits)' },
		{ '<M-l>', function() require('smart-splits').resize_right() end, desc = 'Window: resize right (smart-splits)' },
		{ '<leader>wR', function() require('smart-splits').start_resize_mode() end, desc = 'Window: resize mode (smart-splits)' },
		{ '<leader>w<left>', function() require('smart-splits').swap_buf_left() end, desc = 'Window: swap buffer left' },
		{ '<leader>w<right>', function() require('smart-splits').swap_buf_right() end, desc = 'Window: swap buffer right' },
	},
	---@type SmartSplitsOpts
	opts = {
		ignored_buftypes = { 'nofile', 'quickfix', 'prompt' },
		ignored_filetypes = { 'oil', 'aerial', 'Trouble' },
		default_amount = 8, -- like winsize's fixed step
		at_edge = 'stop',
		move_cursor_same_row = false,
		cursor_follows_swapped_bufs = true,
		resize_mode = {
			quit_key = '<Esc>',
			resize_keys = { 'h', 'j', 'k', 'l' },
			silent = true,
		},
		multiplexer_integration = false, -- nvim-qt and Windows Terminal: none to talk to
		log_level = 'warn',
	},
}
