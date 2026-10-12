-- «configs» is deprecated!
--
--		require'nvim-treesitter.configs'.setup { compilers = { "gcc" }, }

---@type LazySpec
return {
	{
		'nvim-treesitter/nvim-treesitter',
		branch = 'main',
		lazy = false,
		build = ':TSUpdate',

		---@type TSConfig
		opts = {
			install_dir = vim.fn.stdpath('data') .. '/site',
		},

		---@param opts TSConfig
		config = function(_, opts)
			require('nvim-treesitter').setup(opts)


			--   require('nvim-treesitter.install').compilers = { "clang" } -- force compiler from «winget install LLVM.LLVM»

			-- Force Neovim to expose your clang-cl path to the underlying Tree-sitter process
			vim.env.CC = [[C:\Program Files\LLVM\bin\clang-cl.exe]]

			-- Alternatively, ensure Neovim looks for a "cl" compatible toolchain
			-- require('nvim-treesitter.install').compilers = { 'clang-cl.exe' }
			-- require('nvim-treesitter.install').compilers = { 'cl' }


			require('nvim-treesitter').install({
				'bash',
				'powershell',
				-- 'batch',
				-- 'bat',

				'xml',
				'html',
				'json',

				'php',
				'php_only', -- PHP injected into blade and others
				'phpdoc',
				'blade',
				'vue', -- blade-nav.nvim wants it

				'yaml',

				'go',

				'make',

				'git_config', -- .gitconfig, .git/config, .gitmodules
				'gitignore',
				'gitattributes',
				'gitcommit',
				'git_rebase',
				'diff', -- injected into gitcommit (verbose commit)

				'ssh_config', -- ~/.ssh/config, ssh_config (not sshd_config: vim syntax)

				'vim',
				'vimdoc',

				'lua',

				'markdown',
				'markdown_inline',

				'typescript',
				'javascript',
				'tsx',
			})

			vim.api.nvim_create_autocmd('FileType', {
				callback = function(args)
					pcall(vim.treesitter.start, args.buf)
				end,
			})
		end,
	},

}
