local function run_lazygit()
	local Terminal = require('toggleterm.terminal').Terminal
	local lazygit  = Terminal:new({
		close_on_exit = true,
		display_name = 'Lazygit',
		cmd = 'lazygit',
		hidden = false,
		dir = 'git_dir',
		direction = 'float',
		float_opts = {
			width = function() return math.floor(vim.o.columns * 0.9) end,
			height = function() return math.floor(vim.o.lines * 0.8) end,
			border = 'curved',
			title_pos = 'center',
		},
		on_close = function(term)
			vim.cmd('startinsert!')
		end,
		on_open = function(term)
			-- Automatically enter insert mode after opening
			-- Focus the terminal window
			vim.schedule(function()
				vim.api.nvim_set_current_buf(term.bufnr)
				vim.api.nvim_set_current_win(term.window)
				vim.cmd('startinsert!')
				-- vim.api.nvim_buf_set_keymap(term.bufnr, 'n', 'q', '<cmd>close<CR>', {noremap = true, silent = true})
				-- vim.api.nvim_buf_set_keymap(term.bufnr, 'n', 'q', '<cmd>close<CR>', {noremap = true, silent = true})
				-- vim.api.nvim_buf_set_keymap(term.bufnr, 'i', '<esc>', '<cmd>close<CR>', {noremap = true, silent = true})
				vim.api.nvim_buf_set_keymap(term.bufnr, 'i', 'x', '<cmd>close<CR>', { noremap = true, silent = true })
			end)
		end
	})
	lazygit:toggle()
end

return {
	run_lazygit = run_lazygit
}
