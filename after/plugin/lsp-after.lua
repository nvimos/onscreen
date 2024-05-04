

-- local plugs = {
-- require('genja.log').log.warn('lazy-plug/lsp.lua')

-- err("im a log.")

--[[ lsp default ]]--
local default_setup__bridge_cmp_with_lsp = function(server)
	-- err("server: "..server)
	require('lspconfig')[server].setup({
		capabilities = require('cmp_nvim_lsp').default_capabilities()
	})
end

-- --[[ lsp lua_ls ]]--
local lua_ls = function()
	-- local masonBin = vim.fn.stdpath('data') .. '/mason/bin'
	require('lspconfig').lua_ls.setup({
		capabilities = require('cmp_nvim_lsp').default_capabilities(),
		-- cmd = { [[A:\applications\_ls\lua-language-server-3.7.4-win32-x64\bin\lua-language-server.exe]] },
		-- cmd = { masonBin..'/lua-language-server.cmd' },
		settings = {
			Lua = {
				runtime = { version = 'LuaJIT' },
				diagnostics = { globals = { 'vim' } },
				workspace = { library = { vim.env.VIMRUNTIME } }
			}
		}
	})
end

--[[ Other language servers ]]--
local setup_language_servers = function() 
	local lspconfig = require('lspconfig')
	-- lspconfig.pyright.setup {}
	-- lspconfig.tsserver.setup {}
	-- lspconfig.rust_analyzer.setup {
		-- settings = {
			-- ['rust-analyzer'] = {},
		-- },
	-- }
	lspconfig.awk_ls.setup {
		cmd = { "awk-language-server" }}
end


-- default_setup__bridge_cmp_with_lsp()
-- lua_ls()
-- setup_language_servers()

local mason_lspconfig_setup = {
	automatic_installation = true,
	ensure_installed = { 'lua_ls', 'awk_ls', 'gopls',
	-- 'gofumpt', 'gomodifytags', 'gopls', 'gospel', 'gotests', 'iferr', 'impl', 'json-to-struct', 'nilaway', 'revive', 'staticcheck', 'templ',
	-- 'semgrep',
	-- 'snyk', 'trivy',
	-- 'sonarlint-language-server',
						},
	handlers = {
		default_setup__bridge_cmp_with_lsp,
		lua_ls,
		setup_language_servers
	}
}

require('mason-lspconfig').setup( mason_lspconfig_setup )

-- vim.cmd([[
-- if executable('vimscript-language-server')
--   au User lsp_setup call lsp#register_server({
--           \ 'name': 'vimscript-language-server',
--           \ 'cmd': {server_info->['vimscript-language-server']},
--           \ 'whitelist': ['vim'],
--           \ })
-- endif
-- ]])


	-- v1 -- 'neovim/nvim-lspconfig',
	-- v1 -- 'hrsh7th/nvim-cmp',
	-- v1 -- 'hrsh7th/cmp-nvim-lsp',
	-- v1 -- 'hrsh7th/cmp-buffer',
	-- v1 -- 'hrsh7th/cmp-path',
	-- v1 -- 'hrsh7th/cmp-cmdline',
	-- v1 -- -- For vsnip users.
	-- v1 -- 'hrsh7th/cmp-vsnip',
	-- v1 -- 'hrsh7th/vim-vsnip',
