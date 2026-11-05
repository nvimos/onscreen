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

			-- clang-cl from «winget install LLVM.LLVM» builds the parsers. The tree-sitter CLI splits CC at
			-- spaces, so LLVM's bin goes on PATH and CC is the bare name; only when it's installed.
			local llvm_bin = [[C:\Program Files\LLVM\bin]]
			if vim.uv.fs_stat(llvm_bin .. [[\clang-cl.exe]]) then
				vim.env.PATH = llvm_bin .. ';' .. vim.env.PATH
				vim.env.CC = 'clang-cl.exe'
			end

			-- Alternatively, ensure Neovim looks for a "cl" compatible toolchain
			-- require('nvim-treesitter.install').compilers = { 'clang-cl.exe' }
			-- require('nvim-treesitter.install').compilers = { 'cl' }

			-- Parsers are built with the tree-sitter CLI. npm puts only .cmd/.ps1 shims on PATH, which
			-- libuv can't spawn (ENOENT); the package's own tree-sitter.exe can.
			if vim.fn.has('win32') == 1 and vim.fn.exepath('tree-sitter.exe') == '' then
				local cli_dir = vim.fs.joinpath(vim.env.APPDATA, 'npm', 'node_modules', 'tree-sitter-cli')
				if vim.uv.fs_stat(vim.fs.joinpath(cli_dir, 'tree-sitter.exe')) then
					vim.env.PATH = cli_dir .. ';' .. vim.env.PATH
				end
			end


			-- Without a C compiler every missing parser fails to build at each start; install only
			-- when one is there. The parsers already built keep working either way. zig doesn't count: the
			-- tree-sitter CLI passes --target=x86_64-pc-windows-msvc, which zig rejects.
			local has_compiler = false
			for _, cc in ipairs({ vim.env.CC or '', 'cc', 'gcc', 'clang', 'clang-cl', 'cl' }) do
				if cc ~= '' and vim.fn.executable(cc) == 1 then
					has_compiler = true
				end
			end
			if has_compiler then
				require('nvim-treesitter').install({
					'bash',
					'powershell',
					-- 'batch',
					-- 'bat',

					'xml',
					'html',
					'css',
					'scss',
					'json',

					'php',
					'php_only', -- PHP injected into blade and others
					'phpdoc',
					'blade',
					'twig', -- Symfony and Drupal templates
					'vue', -- blade-nav.nvim wants it

					'yaml',

					'go',
					'gomod',
					'gosum',
					'gotmpl', -- text/template and html/template files

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
					'jsdoc', -- /** */ comments in JS and TS
					'regex', -- regex literals in JS, TS and others
				})
			end

			vim.api.nvim_create_autocmd('FileType', {
				callback = function(args)
					pcall(vim.treesitter.start, args.buf)
				end,
			})
		end,
	},

}
