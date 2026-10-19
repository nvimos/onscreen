function Cd_fzf()
	vim.cmd('cd %:p:h')
	vim.cmd('FZF')
end
---@type LazySpec
return {
	{ 'junegunn/fzf',     lazy = false, build = function() vim.cmd 'call fzf#install()' end },
	{ 'junegunn/fzf.vim', lazy = false,
		cmd = { 'FZF', 'Buffers' },
		keys = {
			{ '<S-F2>', Cd_fzf, noremap = true, silent = true },
		}
	},
}
