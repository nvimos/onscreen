---@type LazySpec
return {
	dir = vim.fn.stdpath('config') .. '/plug-wip/genja-completion011.nvim/',
	-- BufReadPre/BufNewFile: servers are enabled before the first file's FileType.
	-- VeryLazy: cmdline completion is ready on an empty start screen too.
	cmd = 'Mason',
	event = { 'BufReadPre', 'BufNewFile', 'VeryLazy' },
	dependencies = {
		'hrsh7th/nvim-cmp', -- lua/lazyp/comps/nvim-cmp.lua
		'neovim/nvim-lspconfig', -- lua/lazyp/comps/nvim-lspconfig.lua
	},

	---@type genja.Opts
	opts = {
		lsp = {
			enabled = {
				-- files from lua/genja/lang/ sans .lua
				bash = true,
				lua = true,
				c_cpp = false,
				go = false,
				json = true,
				php = false,
				powershell = false,
				python = false,
				typescript = false,
				vim = true,
			},
			mason = { ui = { border = 'double' } }, -- for require('mason').setup()
			-- for vim.diagnostic.config()
			diagnostics = {
				virtual_text = true,
				severity_sort = true
			},
		},
		completion = {
			features = {
				'keymaps',
				'snippets',
				'lsp',
				'path',
				'gitignore',
				'sshconfig',
				'gitcommit',
				'dictionary',
				'buffer',
				'lazydev',
				'cmdline',
				'appearance'
			},
		},
	},

	---@param opts genja.Opts
	config = function(_, opts)
		local Safeload = require('genja.api').Safeload
		Safeload('genja.comps', function(genja_comps)
			genja_comps.setup(opts)
		end)
	end
}
