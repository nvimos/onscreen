function Cd_fzf()
	vim.cmd('cd %:p:h')
	vim.cmd('FZF')
end
return {
	-- Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
	-- Plug 'junegunn/fzf.vim'

	{
		'junegunn/fzf',
		lazy = false,
		-- lazy = true,
		-- cmd = 'FZF',
		build = function()
			vim.cmd 'call fzf#install()'
		end
	},
	{
		'junegunn/fzf.vim',
		lazy = false,
		-- lazy = true,
		-- cmd = 'FZF',
		keys = {
			-- { '<F2>', Cd_fzf, noremap = true, silent = true },
			{ '<S-F2>', Cd_fzf, noremap = true, silent = true },
		}
	},
}
