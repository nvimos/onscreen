-- https://github.com/google/vimscript-language-server
-- https://github.com/LuaLS/lua-language-server?tab=readme-ov-file
-- https://luals.github.io/#neovim-install
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#lua_ls
-- https://github.com/luals/lua-language-server {{loop}}
-- https://lsp-zero.netlify.app/v3.x/blog/you-might-not-need-lsp-zero.html
-- :help vim.diagnostic.*
-- :help lspconfig-setup

-- local err = vim.api.nvim_err_writeln; err("lsp.lua")

local vim = vim
local err = vim.api.nvim_err_writeln


return {
	--[[ You might not need lsp-zero
	     It's important that you set up the plugins in the following order:
		     1. mason.nvim
			 2. mason-lspconfig.nvim
			 3. Setup servers via lspconfig
	--]]
	{ 'williamboman/mason.nvim',
		config = true, -- require('mason').setup({})
		priority = 70,
		lazy = false,
		cmd = 'Mason',
		},
	{ 'williamboman/mason-lspconfig.nvim',
		config = false,
		-- config = function()
			-- require('mason-lspconfig').setup( mason_lspconfig_setup )
			-- require('mason-lspconfig').setup({})
		-- end,
		priority = 71,
		lazy = false,
		},
	{ 'neovim/nvim-lspconfig',
		priority = 72,
		lazy = false,
		config = false
		},

}

-- vim.list_extend(P or {}, plugs)
-- return P
