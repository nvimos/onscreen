---@type LazySpec
return {
	-- not used: 2026-10
	{ 'preservim/nerdtree',         -- file navigation reeplacing netrw
	enabled = false,
	lazy = true,
	config = function()
		vim.g.NERDTreeMinimalUI   = 1
		vim.g.NERDTreeMinimalMenu = 1
		vim.g.NERDTreeShowBookmarks = 0
		vim.g.NERDTreeQuitOnOpen = 1 -- :help nerdtreequitonopen
		vim.keymap.set('n',       '<F1>', '<cmd>NERDTreeToggle<CR>',                                    { desc = 'NERDTree sidebar', noremap = true }) -- override init-map
		vim.keymap.set('n', '<leader>e.', '<cmd>lua Close_nerdtree_wins()<cr><cmd>:edit %:p:h<CR>/',    { desc = 'edit CWD %:h (dirname)'})
		vim.keymap.set('n', '<leader>ee', '<cmd>lua Close_nerdtree_wins()<cr><cmd>:edit %:p:h<CR>/',    { desc = 'edit CWD' })
		vim.keymap.set('n', '<leader>et', '<cmd>lua Close_nerdtree_wins()<cr><cmd>:tabedit %:p:h<CR>/', { desc = 'tabedit CWD' })
		-- vim.keymap.set('',        '<F3>', '<cmd>lua Close_nerdtree_wins()<CR><cmd>:tabedit %:p:h<CR>/', { desc = 'tabedit CWD' }) -- override init-map
		-- vim.cmd[[ :command! NERDTx lua Close_nerdtree_wins() ]]
		-- user_comm( 'NERDTxAll',  [[:lua Close_nerdtree_wins()<cr>]],    { desc = "close all nerds" , bar = true })

		vim.api.nvim_create_user_command( 'NERDxAll',  '<cmd>lua Close_nerdtree_wins()<cr>',    { desc = "close all nerds" , bar = true })

		vim.cmd[[
        call NERDTreeAddKeyMap({
               \ 'key': 'a',
               \ 'callback': 'NERDTreeGitAdd',
               \ 'quickhelpText': 'Add file to git',
               \ 'scope': 'FileNode' })
        function! NERDTreeGitAdd(fil)
			let filepath = shellescape(a:fil.path.str())
			execute '!git add ' . filepath
        endfunction
		]]

	end,
	cmd = 'NERDTreeToggle',
	keys = {
		{ '<F1>', '<cmd>NERDTreeToggle<cr>', mode = {'n'} },
		{ '<leader>e.', nil },
		{ '<leader>ee', nil },
		{ '<leader>et', nil },
		-- { '<leader>ei', nil },
	}
},
}
