
vim.cmd[[
	:command! -nargs=* T       tabedit <args>
	:command! -nargs=* Te      tabedit <args>
	:command! -nargs=* Tabedit tabedit <args>
]]

vim.cmd([[
	:command! QQQ tabdo write | qa
	:command! JJJ tabdo write | qa
	:command! QQ qa
	:command! JJ qa
	:command! O only
	:command! Tm tabmove +1
	:command! TM tabmove -1
	:command! -nargs=* W write <args>
	:command! -nargs=* So source <args>
]])

vim.cmd[[
	:command! Lspclients :lua =vim.lsp.get_clients()
]]

vim.cmd[[
	:command! NERDTx lua Close_nerdtree_wins()
]]

vim.cmd[[
	:command! -nargs=* M MRU <args>
]]
