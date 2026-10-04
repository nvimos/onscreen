-- This file bootstraps the lazy plugin manager.
(function(LazyData, Github)
	LazyData, Github = '' ..
		vim.fn.stdpath('data') .. '/lazy/lazy.nvim',
		'https://github.com/folke/lazy.nvim.git'
	if not vim.loop.fs_stat(LazyData) then
		vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=stable',
			Github, LazyData })
	end;
	vim.opt.rtp:prepend(LazyData) -- prenpend to runtime path (to autoload plugins?)
	vim.api.nvim_create_autocmd('FileType', {
		pattern = 'lazy',
		callback = function(ev)
			local mo = { noremap = true, silent = true }
			local bkm = vim.api.nvim_buf_set_keymap
			bkm(ev.buf, 'n', '<esc>', '<cmd>quit<cr>', mo)
			bkm(ev.buf, 'n', '<c-w>', '<cmd>quit<cr>', mo)
			bkm(ev.buf, 'n', 'q', '<cmd>quit<cr>', mo);
		end
	})
end)()

