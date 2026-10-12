(function()
	-- Bootstrap the lazy plugin manager
	local LazyData, Github = '' ..
	vim.fn.stdpath('data')..'/lazy/lazy.nvim',
	'https://github.com/folke/lazy.nvim.git'
	if not vim.uv.fs_stat(LazyData) then
		vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=stable',
			Github, LazyData })
	end;
	vim.opt.rtp:prepend(LazyData) -- prepend to runtime path to autoload plugins
	--[[
	vim.api.nvim_create_autocmd('FileType', {
		pattern = 'lazy',
		callback = function(ev)
			local mo, bkm, quit = { noremap = true, silent = true },
			vim.api.nvim_buf_set_keymap,
			'<cmd>quit<cr>'
			bkm(ev.buf, 'n', '<esc>', quit, mo)
			bkm(ev.buf, 'n', '<c-w>', quit, mo)
			bkm(ev.buf, 'n', 'q',     quit, mo);
		end
	})
	--]]
end)()
