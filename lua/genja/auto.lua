
-- vim.api.nvim_create_autocmd(
--     { "BufWritePre" },
--     { pattern = { "*.py" }, command = "!your_command_here" }
-- )


-- vim.api.nvim_create_autocmd("VimEnter", {
--     pattern = "*",
--     command = "MRU"
--     -- command = "if vim.fn.argc() == 0 then vim.cmd('Dashboard') end"
-- })


-- vim.api.nvim_create_autocmd('UIEnter', {
--   group = vim.api.nvim_create_augroup('Dashboard', { clear = true }),
--   callback = function()
--     if vim.fn.argc() == 0 and vim.api.nvim_buf_get_name(0) == '' then
--       require('dashboard'):instance()
--     end
-- 	vim.cmd("MRU")
--   end,
-- })

vim.api.nvim_create_autocmd('BufWritePost', {
	group = vim.api.nvim_create_augroup('conf-reload', { clear = true }),
	pattern = pattern,
	callback = function()
		-- 
	end
})


vim.cmd [[
autocmd BufReadPost *
\ if line("'\"") > 0 && line("'\"") <= line("$") |
\   exe "normal! g`\"" |
\ endif
]]

vim.cmd [[
augroup _general_settings
autocmd!
autocmd FileType qf,help,man,lspinfo nnoremap <silent> <buffer> q :close<CR> 
autocmd TextYankPost * silent!lua require('vim.highlight').on_yank({higroup = 'Visual', timeout = 200}) 
autocmd BufWinEnter * :set formatoptions-=cro
autocmd FileType qf set nobuflisted
augroup end

augroup _git
autocmd!
autocmd FileType gitcommit setlocal wrap
autocmd FileType gitcommit setlocal spell
augroup end

augroup _markdown
autocmd!
autocmd FileType markdown setlocal wrap
autocmd FileType markdown setlocal spell
augroup end

" augroup _auto_resize
"   autocmd!
"   autocmd VimResized * tabdo wincmd = 
" augroup end
" augroup _alpha
"   autocmd!
"   autocmd User AlphaReady set showtabline=0 | autocmd BufUnload <buffer> set showtabline=2
" augroup end
]]
