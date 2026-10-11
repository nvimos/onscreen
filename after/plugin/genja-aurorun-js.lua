
local function SetupRunit()
	local bufnr, old
	-- local ag = -1
	-- ag = vim.api.nvim_create_autocmd('BufWritePost', {
	-- 	pattern = { 'zexp-nodejs-run.lua', '*.js', },
	-- 	callback = function(ev)
	-- 		bufnr = ev.buf
	-- 	end,
	-- })

	-- local m = { 'i', 'n', 'v' }
	-- local mo = { noremap = true, silent = true, buffer = bufnr }
	-- vim.keymap.set(m, '<F1>', '<cmd>FloatermNew --autoclose=0 node %<cr>', mo)
	-- vim.keymap.set(m, '<S-F1>', function()
	-- 	vim.keymap.del(m, '<F1>', mo)
	-- 	vim.keymap.del(m, '<S-F1>', mo)
	-- 	vim.api.nvim_del_autocmd(ag)
	-- end, mo)


	old = vim.api.nvim_get_current_buf()
	vim.cmd [[vsplit|enew]]
	bufnr = vim.api.nvim_get_current_buf()
	-- vim.api.nvim_set_current_buf(old)
	vim.cmd [[wincmd w]]

	vim.api.nvim_create_autocmd('BufWritePost', {
		group = vim.api.nvim_create_augroup('GenjaAutorun', { clear = true }),
		pattern = { 'zexp-nodejs-run.lua', '*.js', },
		callback = function(ev)
			local argv = { 'node', ev.file }
			vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {})
			vim.fn.jobstart(argv, {
				stdout_buffered = true,
				on_stdout = function(_, data)
					if data then
						vim.api.nvim_buf_set_lines(
							bufnr, 0, 0, false, data)
					end
				end,
				on_stderr = function(_, data)
					if data then
						vim.api.nvim_buf_set_lines(
							bufnr, 0, 0, false, data)
					end
				end,
			})
		end
	})
end


vim.api.nvim_create_user_command('RunitJs', SetupRunit, { desc = 'run file on save', bar = false })
