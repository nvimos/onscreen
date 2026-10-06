return {
	dir = require('genja.api').CONFIG .. '/plug-wip/genja-completion011.nvim/',
	-- BufReadPre/BufNewFile: servers are enabled before the first file's FileType.
	-- VeryLazy: cmdline completion is ready on an empty start screen too.
	cmd = 'Mason',
	event = { 'BufReadPre', 'BufNewFile', 'VeryLazy' },
	dependencies = {
		'hrsh7th/nvim-cmp', -- lua/lazyp/comps/nvim-cmp.lua
		'neovim/nvim-lspconfig', -- lua/lazyp/comps/nvim-lspconfig.lua
	},

	opts = {
		lsp = {
			enabled = {
				-- files from lua/genja/lang/ sans .lua
				bash = true,
				lua = true,
				c_cpp = false,
				go = false,
				php = false,
				powershell = false,
				python = false,
				typescript = false,
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
				'buffer',
				'lazydev',
				'cmdline',
				'appearance'
			},
		},
	},

	config = function(_, opts)
		Safeload = require('genja.api').Safeload
		Safeload('genja.comps', function(genja_comps)
			genja_comps.setup(opts)
		end)
	end
}
