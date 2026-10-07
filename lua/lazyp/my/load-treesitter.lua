-- «configs» is deprecated!
--
--		require'nvim-treesitter.configs'.setup { compilers = { "gcc" }, }

return {
	{
		'nvim-treesitter/nvim-treesitter',
		branch = 'main',
		lazy = false,
		build = ':TSUpdate',

		opts = {
			install_dir = vim.fn.stdpath('data') .. '/site',
		},

		config = function(_, opts)
			opts = opts
			require('nvim-treesitter').setup()


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
				'yaml',

				'go',

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

	{
		'windwp/nvim-ts-autotag',
		opts = {},
	},
}
