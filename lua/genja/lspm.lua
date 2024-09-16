-- https://github.com/google/vimscript-language-server
-- https://github.com/LuaLS/lua-language-server?tab=readme-ov-file
-- https://luals.github.io/#neovim-install
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#lua_ls
-- https://github.com/luals/lua-language-server {{loop}}
-- https://lsp-zero.netlify.app/v3.x/blog/you-might-not-need-lsp-zero.html
-- https://github.com/kkalamarski/neovim-config/blob/main/lua/kkalamarski/lsp.lua
-- https://www.freecodecamp.org/news/a-guide-to-modern-web-development-with-neo-vim-333f7efbf8e2/

-- :help vim.diagnostic.*
-- :help lspconfig-setup

-- https://nathan-long.com/blog/modern-javascript-tooling-in-neovim/

-- local err = vim.api.nvim_err_writeln; err("lsp.lua")


local err = vim.api.nvim_err_writeln
local notify = vim.notify

local eils = {}
--[[
	'prettier',
	'awk_ls', -- requires a c compiler?
	'gofumpt',
	'gomodifytags',
	'gopls',
	'gospel',
	'gotests',
	'harper_ls', -- disable spellcheck, works with js?
	'iferr',
	'impl',
	'json-to-struct',
	'nilaway',
	'revive',
	'semgrep',
	'snyk',
	'sonarlint-language-server',
	'staticcheck',
	'templ',
	'trivy',
	]]
local function ei(ls)
	if ls then table.insert(eils, ls) end
	return eils
end

local M = {
	lspConfAugroup = vim.api.nvim_create_augroup('UserLspConfig', {}),
	ensure_installs = ei
}




-- local nvims_capabilities = require('cmp_nvim_lsp').default_capabilities()


-- require('lspconfig').util.default_config = vim.tbl_extend('force',
-- 	require('lspconfig').util.default_config, {
-- 		autostart = true,
-- 		capabilities = vim.lsp.protocol.make_client_capabilities(),
-- 	})


-- -- https://github.com/NvChad/NvChad/blob/v2.5/lua/nvchad/configs/lspconfig.lua
-- M.capabilities = vim.lsp.protocol.make_client_capabilities()
-- -- capabilities.textDocument.completion.completionItem.snippetSupport = true -- required for the visualstudio lsps (css, html, etc)
-- M.capabilities.textDocument.completion.completionItem = {
-- 	documentationFormat = { "markdown", "plaintext" },
-- 	snippetSupport = true,
-- 	preselectSupport = true,
-- 	insertReplaceSupport = true,
-- 	labelDetailsSupport = true,
-- 	deprecatedSupport = true,
-- 	commitCharactersSupport = true,
-- 	tagSupport = { valueSet = { 1 } },
-- 	resolveSupport = {
-- 		properties = {
-- 			"documentation",
-- 			"detail",
-- 			"additionalTextEdits",
-- 		},
-- 	},
-- }
--

local function lspconfig_lua()
	require('lspconfig').lua_ls.setup({
		filetypes = { 'lua' },
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
end

local function lspconfig_ts_js_css_html()
	-- https://nathan-long.com/blog/modern-javascript-tooling-in-neovim/
	local caps = require('cmp_nvim_lsp').default_capabilities()
	caps.textDocument.completion.completionItem.snippetSupport = true
	require('lspconfig').tailwindcss.setup { capabilities = caps }
	require('lspconfig').ts_ls.setup { capabilities = caps }
	require('lspconfig').jsonls.setup { capabilities = caps }
	require('lspconfig').eslint.setup { capabilities = caps }
	require('lspconfig').cssls.setup { capabilities = caps }
	require('lspconfig').html.setup { capabilities = caps }
end


local function lspconfig_go()
	require('lspconfig').gopls.setup {
		-- on_attach = on_attach,
		-- capabilities = capabilities,
		cmd = { 'gopls' },
		filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
		root_dir = require('lspconfig/util').root_pattern('go.work', 'go.mod', '.git'),
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
end


-- ◍ typescript-language-server

-- ei('eslint')


-- this is called from NVIM/lua/lazyp/lsp
-- when neovim/nvim-lspconfig is loaded
M.setup_mason_lspconfig = function(set, zz)
	require('mason').setup({})
	vim.api.nvim_create_autocmd('FileType', {
		pattern = 'mason',
		callback = function()
			vim.api.nvim_buf_set_keymap(0, 'n', '<esc>', ':close<cr>', { noremap = true, silent = true })
			vim.api.nvim_buf_set_keymap(0, 'n', '<c-w>', ':close<cr>', { noremap = true, silent = true })
		end
	})


	ei('lua_ls')
	ei('bashls')
	-- ei('biome')
	ei('ts_ls')
	-- nathan long
	ei('jsonls')
	ei('eslint')
	ei('cssls')
	ei('html')
	require('mason-lspconfig').setup({
		automatic_installation = true,
		ensure_installed = ei()
	})

	-- set omnifunc and tagfunc if available
	vim.api.nvim_create_autocmd('LspAttach', {
		desc = 'LSP capabilities',
		group = M.lspConfAugroup,
		callback = function(args)
			local bufnr = args.buf
			local client = vim.lsp.get_client_by_id(args.data.client_id)
			if client then
				if client.server_capabilities.completionProvider then
					vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc' -- complete with <c-x><c-o>
				end
				if client.server_capabilities.definitionProvider then
					vim.bo[bufnr].tagfunc = 'v:lua.vim.lsp.tagfunc'
				end
			end
		end,
	})
	-- disable omnifunc and tagfunc when client detaches
	vim.api.nvim_create_autocmd("LspDetach", {
		callback = function(args)
			-- local client = vim.lsp.get_client_by_id(args.data.client_id)
			vim.cmd("setlocal tagfunc< omnifunc<")
		end,
	})

	lspconfig_ts_js_css_html()

	lspconfig_lua()

	lspconfig_go()





	--local fuck_off_with_your_spellcheck_in_code = false
	--require('lspconfig').harper_ls.setup({
	--	autostart = false,
	--	-- filetypes = { 'javascript' },
	--	settings = {
	--		['harper-ls'] = {
	--			diagnosticSeverity = 'hint', -- hint, information, warning, error
	--			userDictPath = [[C:\tmp\harper_ls.dict]],
	--			linters = {
	--				spell_check = fuck_off_with_your_spellcheck_in_code,
	--				sentence_capitalization = fuck_off_with_your_spellcheck_in_code,
	--				spelled_numbers = false,
	--				an_a = true,
	--				unclosed_quotes = true,
	--				wrong_quotes = false,
	--				long_sentences = true,
	--				repeated_words = true,
	--				spaces = true,
	--				matcher = true,
	--				correct_number_suffix = true,
	--				number_suffix_capitalization = true,
	--				multiple_sequential_pronouns = true,
	--				linking_verbs = false
	--			}
	--		}
	--	},
	--})


	-- require('lspconfig').pyright.setup {}
	-- require('lspconfig').tsserver.setup {}
	-- require('lspconfig').rust_analyzer.setup { settings = { ['rust-analyzer'] = {}, }, }
	-- require('lspconfig').awk_ls.setup {}

	-- require('lspconfig').bashls.setup {}
	-- require('lspconfig').gopls.setup {}
	-- require('lspconfig').biome.setup {
	-- 	filetypes = 'javascript',
	-- 	-- root_dir = require('lspconfig/util').root_pattern('index.js'),
	-- 	root_dir = function(filename, bufnr)
	-- 		vim.notify("biome", filename, bufnr)
	-- 		-- return [[A:\workspace\doodles\js]]
	-- 		return filename
	-- 	end,
	-- }

	-- require('lspconfig').eslint.setup {
	-- filetypes = 'javascript',
	-- -- root_dir = require('lspconfig/util').root_pattern('index.js'),
	-- }
end


M.debug = function()
	-- vim.lsp.get_active_clients()

	for i, e in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
		print("client[" .. i .. "] = " .. e.name)
	end
end

return M


--[[ setup {}


Note: all entries passed to `setup {}` override the entry in the default configuration. There is no composition.


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

]] --
