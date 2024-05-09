-- https://github.com/google/vimscript-language-server
-- https://github.com/LuaLS/lua-language-server?tab=readme-ov-file
-- https://luals.github.io/#neovim-install
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#lua_ls
-- https://github.com/luals/lua-language-server {{loop}}
-- https://lsp-zero.netlify.app/v3.x/blog/you-might-not-need-lsp-zero.html
-- :help vim.diagnostic.*
-- :help lspconfig-setup

-- local err = vim.api.nvim_err_writeln; err("lsp.lua")


local M = {}

local err = vim.api.nvim_err_writeln

local nvims_capabilities = require('cmp_nvim_lsp').default_capabilities()


local lspconfig = require('lspconfig')
local util = require "lspconfig/util"

lspconfig.util.default_config = vim.tbl_extend('force',
lspconfig.util.default_config, {
	autostart = true,
	capabilities = vim.lsp.protocol.make_client_capabilities(),

	-- M.capabilities = vim.lsp.protocol.make_client_capabilities()
	-- capabilities = M.capabilities,
	-- capabilities = nvims_capabilities
	-- handlers = {
	-- 	["window/logMessage"] = function(err, method, params, client_id)
	-- 		if params and params.type <= vim.lsp.protocol.MessageType.Log then
	-- 			vim.lsp.handlers["window/logMessage"](err, method, params, client_id)
	-- 		end
	-- 	end,
	-- 	["window/showMessage"] = function(err, method, params, client_id)
	-- 		if params and params.type <= vim.lsp.protocol.MessageType.Warning.Error then
	-- 			vim.lsp.handlers["window/showMessage"](err, method, params, client_id)
	-- 		end
	-- 	end,
	-- }
})

-- https://github.com/NvChad/NvChad/blob/v2.5/lua/nvchad/configs/lspconfig.lua
M.capabilities = vim.lsp.protocol.make_client_capabilities()
M.capabilities.textDocument.completion.completionItem = {
	documentationFormat = { "markdown", "plaintext" },
	snippetSupport = true,
	preselectSupport = true,
	insertReplaceSupport = true,
	labelDetailsSupport = true,
	deprecatedSupport = true,
	commitCharactersSupport = true,
	tagSupport = { valueSet = { 1 } },
	resolveSupport = {
		properties = {
			"documentation",
			"detail",
			"additionalTextEdits",
		},
	},
}



M.setup_mason_lspconfig = function(set, zz)

	-- vim.notify [[setup mason]]
	-- vim.notify ([[caps cmp]] .. vim.inspect(  vim.tbl_keys(nvims_capabilities)))
	-- vim.notify ([[caps made]] .. vim.inspect( vim.tbl_keys(M.capabilities)))


	-- for i, e in pairs(set) do
		-- vim.notify( [[setup mason1 ]] .. i .. ': ' .. vim.inspect(e))
	-- end



	-- vim.notify( [[caps: ]]  .. vim.inspect(nvims_capabilities))


	-- local default_setup__bridge_cmp_with_lsp = function(server)
	-- 	require('lspconfig')[server].setup({
	-- 		capabilities = nvims_capabilities
	-- 	})
	-- end


	require('mason').setup({})
	require('mason-lspconfig').setup({
		automatic_installation = true,
		ensure_installed = { 'lua_ls', 'awk_ls', 'bashls', }
		-- 'gofumpt', 'gomodifytags', 'gopls', 'gospel', 'gotests', 
		-- 'iferr', 'impl', 'json-to-struct', 'nilaway', 'revive', 'staticcheck', 'templ',
		-- 'semgrep',
		-- 'snyk', 'trivy',
		-- 'sonarlint-language-server',
	})

	require('lspconfig').lua_ls.setup({
		settings = {
			Lua = {
				runtime = { version = 'LuaJIT' },
				diagnostics = { globals = { 'vim' } },
				workspace = {
					library = {
						[vim.fn.expand "$VIMRUNTIME/lua"] = true,
						[vim.fn.expand "$VIMRUNTIME/lua/vim/lsp"] = true,
						[vim.fn.stdpath "data" .. "/lazy/ui/nvchad_types"] = true,
						[vim.fn.stdpath "data" .. "/lazy/lazy.nvim/lua/lazy"] = true,
						[vim.fn.stdpath "data" .. "/lazy"] = true,
					},
					maxPreload = 100000,
					preloadFileSize = 10000,
				},
			}
		}
	})

	lspconfig.gopls.setup {
		-- on_attach = on_attach,
		-- capabilities = capabilities,
		cmd = {"gopls"},
		filetypes = { "go", "gomod", "gowork", "gotmpl" },
		root_dir = util.root_pattern("go.work", "go.mod", ".git"),
		settings = {
			gopls = {
				completeUnimported = true,
				usePlaceholders = true,
				analyses = {
					unusedparams = true,
				},
			},
		},
	}


	-- lspconfig.pyright.setup {}
	-- lspconfig.tsserver.setup {}
	-- lspconfig.rust_analyzer.setup { settings = { ['rust-analyzer'] = {}, }, }
	lspconfig.awk_ls.setup {}
	lspconfig.bashls.setup {}
	lspconfig.gopls.setup {}

end

return M


--[[ setup {}


Note: all entries passed to `setup {}` override the entry in the default
configuration. There is no composition.


- {root_dir}

    `function(filename, bufnr)`

    Returns either a filepath (string) or nil. The language server will only
    start if the function returns a filepath.

- {filetypes}

    `list[string] | nil`

- {autostart}

    `bool` (default: true)


- {on_new_config}

    `function(new_config, new_root_dir)`

    Function executed after a root directory is detected. This is used to
    modify the server configuration (including `cmd` itself). Most commonly,
    this is used to inject additional arguments into `cmd`.

    If overriding `on_new_config`, ensure that you read the
    `on_new_config` defined in the source file of the default configuration
    in `lspconfig`. The original `on_new_config` snippet for a given server
    should likely be included in your new override. Some configurations
    use `on_new_config` to dynamically set or modify `cmd`.


- {capabilities} `table <string, string|table|bool|function>`

  a table which represents the neovim client capabilities. Useful for
  broadcasting to the server additional functionality (snippets, off-protocol
  features) provided by plugins.

- {cmd} `list[string]`

  {'foo', '--bar', 'baz'}


- {on_attach} `function(client, bufnr)`

  Callback invoked by Nvim's built-in client when attaching a buffer to a
  language server. Often used to set Nvim (buffer or global) options or to
  override the Nvim client properties (`server_capabilities`) after a
  language server attaches. Most commonly used for settings buffer
  local keybindings. See |lspconfig-keybindings| for a usage example.

- {settings} `table <string, string|table|bool>`  

  The `settings` table is sent after initialization via a
  `workspace/didChangeConfiguration` notification from the Nvim client to
  the language server. These settings allow a user to change optional runtime
  settings of the language server. 


--

  local lspconfig = require'lspconfig'
  lspconfig.util.default_config = vim.tbl_extend(
    "force",
    lspconfig.util.default_config,
    {
      autostart = false,
      handlers = {
        ["window/logMessage"] = function(err, method, params, client_id)
            if params and params.type <= vim.lsp.protocol.MessageType.Log then
              vim.lsp.handlers["window/logMessage"](err, method, params, client_id)
            end
          end,
        ["window/showMessage"] = function(err, method, params, client_id)
            if params and params.type <= vim.lsp.protocol.MessageType.Warning.Error then
              vim.lsp.handlers["window/showMessage"](err, method, params, client_id)
            end
          end,
      }
    }
  )

]]--
