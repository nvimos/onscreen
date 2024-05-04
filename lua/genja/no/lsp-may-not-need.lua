
-- https://github.com/google/vimscript-language-server


-- https://github.com/LuaLS/lua-language-server?tab=readme-ov-file
-- https://luals.github.io/#neovim-install
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#lua_ls
-- https://github.com/luals/lua-language-server {{loop}}


-- https://lsp-zero.netlify.app/v3.x/blog/you-might-not-need-lsp-zero.html

-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set('n', 'gl', vim.diagnostic.open_float, { desc = 'diag open float' })
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'diag prev' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'diag next' })
vim.keymap.set('n', '<space>dq', vim.diagnostic.setloclist, { desc = 'diag setlocallist' })
vim.keymap.set('n', '<space>de', vim.diagnostic.open_float, { desc = 'diag open float' })
-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
	desc = 'LSP Actions',
	group = vim.api.nvim_create_augroup('UserLspConfig', {}),
	callback = function(ev)
		---- vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc' -- complete with <c-x><c-o>
		-- Buffer local mappings.
		local opts = { buffer = ev.buf }
		vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
		vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
		vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
		vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
		vim.keymap.set('n', 'go', vim.lsp.buf.type_definition, opts)
		vim.keymap.set('n', 'gs', vim.lsp.buf.signature_help, opts)
		vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)

		vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
		vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
		vim.keymap.set('n', '<space>wl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, opts)

		vim.keymap.set('n', '<space>r', function() vim.lsp.buf.format { async = true } end, opts)

		vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
		vim.keymap.set('n', '<F2>', vim.lsp.buf.rename, opts)
		vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, { buffer = ev.buf, desc = 'Code action' })
	end,
})

----
local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()
local default_setup = function(server)
	require('lspconfig')[server].setup({
		capabilities = lsp_capabilities,
	})
end

print('mason setup')

require('mason').setup({})
require('mason-lspconfig').setup({
	ensure_installed = {},
	handlers = {
		default_setup,
		lua_ls = function()
			-- :help lspconfig-setup
			print('setup lua, vimruntime')
			print('setup lua, vimruntime')
			print('setup lua, vimruntime')
			print('setup lua, vimruntime')
			print('setup lua, vimruntime')

			require('lspconfig').lua_ls.setup({
				-- capabilities = lsp_capabilities,
				cmd = { [[A:\workspace\_ls\lua-language-server-3.7.4-win32-x64\bin\lua-language-server.exe]] },
				settings = {
					Lua = {
						runtime = { version = 'LuaJIT' },
						diagnostics = { globals = { 'vim' } },
						workspace = { library = { vim.env.VIMRUNTIME } }
					}
				}
			})
		end,
		awk_ls = function()
			require 'lspconfig'.awk_ls.setup { cmd = { "awk-language-server" } }
		end
	},
})
---


--local function init_lua_ls(client)
--	local path = client.workspace_folders[1].name
--	if vim.loop.fs_stat(path..'/.luarc.json') or vim.loop.fs_stat(path..'/.luarc.jsonc') then
--		return
--	end
--	local more = {
--		runtime = {
--			version = 'LuaJIT'
--		},
--		-- Make the server aware of Neovim runtime files
--		workspace = {
--			checkThirdParty = false,
--			library = {
--				vim.env.VIMRUNTIME
--				-- "${3rd}/luv/library", ${3rd}/busted/library",
--			}
--			-- or pull in all of 'runtimepath'. NOTE: this is a lot slower
--			-- library = vim.api.nvim_get_runtime_file("", true)
--		}
--	}
--	client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, more)
--end
-----
--require'lspconfig'.lua_ls.setup {
--	--cmd = { 'lua-language-server' },
--	cmd = { [[A:\workspace\_ls\lua-language-server-3.7.4-win32-x64\bin\lua-language-server.exe]]  },
--	on_init = init_lua_ls ,
--	settings = {
--		Lua = {
--			runtime = { version = 'LuaJIT' },
--			diagnostics = { globals = { 'vim' }},
--			workspace = { checkThirdParty = false, library = { vim.env.VIMRUNTIME }}
--		}
--	}
--}

-- -- Setup language servers.
-- local lspconfig = require('lspconfig')
-- lspconfig.pyright.setup {}
-- lspconfig.tsserver.setup {}
-- lspconfig.rust_analyzer.setup {
--   -- Server-specific settings. See `:help lspconfig-setup`
--   settings = {
--     ['rust-analyzer'] = {},
--   },
-- }

-- require 'lspconfig'.awk_ls.setup { cmd = { "awk-language-server" } }


-- vim.cmd([[
-- if executable('vimscript-language-server')
--   au User lsp_setup call lsp#register_server({
--           \ 'name': 'vimscript-language-server',
--           \ 'cmd': {server_info->['vimscript-language-server']},
--           \ 'whitelist': ['vim'],
--           \ })
-- endif
-- ]])

---------------require 'genja.lsp-cmp' -- must be after lsp
-------------------------------------------------------
-------------------------------------------------------
-------------------------------------------------------

-- https://github.com/LunarVim/Neovim-from-scratch/blob/master/lua/user/cmp.lua
-- yank tab and luasnip setup from above
--

-- v1 -- local ok, cmp = pcall(require, 'cmp')
-- v1 -- if ok then
-- v1 -- 	cmp.setup({
-- v1 -- 		snippet = {
-- v1 -- 			-- REQUIRED - you must specify a snippet engine
-- v1 -- 			expand = function(args)
-- v1 -- 				vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
-- v1 -- 				-- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
-- v1 -- 				-- require('snippy').expand_snippet(args.body) -- For `snippy` users.
-- v1 -- 				-- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
-- v1 -- 				-- vim.snippet.expand(args.body) -- For native neovim snippets (Neovim v0.10+)
-- v1 -- 			end,
-- v1 -- 		},
-- v1 -- 		window = {
-- v1 -- 			-- completion = cmp.config.window.bordered(),
-- v1 -- 			-- documentation = cmp.config.window.bordered(),
-- v1 -- 		},
-- v1 -- 		mapping = cmp.mapping.preset.insert({
-- v1 -- 			['<C-b>'] = cmp.mapping.scroll_docs(-4),
-- v1 -- 			['<C-f>'] = cmp.mapping.scroll_docs(4),
-- v1 -- 			['<C-Space>'] = cmp.mapping.complete(),
-- v1 -- 			-- ['<Tab>'] = cmp.mapping.complete(),
-- v1 -- 			['<C-e>'] = cmp.mapping.abort(),
-- v1 -- 			['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
-- v1 -- 		}),
-- v1 -- 		sources = cmp.config.sources({
-- v1 -- 			{ name = 'nvim_lsp' },
-- v1 -- 			{ name = 'vsnip' }, -- For vsnip users.
-- v1 -- 			-- { name = 'luasnip' }, -- For luasnip users.
-- v1 -- 			-- { name = 'ultisnips' }, -- For ultisnips users.
-- v1 -- 			-- { name = 'snippy' }, -- For snippy users.
-- v1 -- 		}, {
-- v1 -- 			{ name = 'buffer' },
-- v1 -- 		})
-- v1 -- 	})
-- v1 -- 
-- v1 -- 	-- Set configuration for specific filetype.
-- v1 -- 	cmp.setup.filetype('gitcommit', {
-- v1 -- 		sources = cmp.config.sources({
-- v1 -- 			{ name = 'git' }, -- You can specify the `git` source if [you were installed it](https://github.com/petertriho/cmp-git).
-- v1 -- 		}, {
-- v1 -- 			{ name = 'buffer' },
-- v1 -- 		})
-- v1 -- 	})
-- v1 -- 
-- v1 -- 	-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
-- v1 -- 	cmp.setup.cmdline({ '/', '?' }, {
-- v1 -- 		mapping = cmp.mapping.preset.cmdline(),
-- v1 -- 		sources = {
-- v1 -- 			{ name = 'buffer' }
-- v1 -- 		}
-- v1 -- 	})
-- v1 -- 
-- v1 -- 	-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
-- v1 -- 	cmp.setup.cmdline(':', {
-- v1 -- 		mapping = cmp.mapping.preset.cmdline(),
-- v1 -- 		sources = cmp.config.sources({
-- v1 -- 			{ name = 'path' }
-- v1 -- 		}, {
-- v1 -- 			{ name = 'cmdline' }
-- v1 -- 		}),
-- v1 -- 		matching = { disallow_symbol_nonprefix_matching = false }
-- v1 -- 	})
-- v1 -- 
-- v1 -- 	-- -- Set up lspconfig.
-- v1 -- 	-- local capabilities = require('cmp_nvim_lsp').default_capabilities()
-- v1 -- 	-- -- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
-- v1 -- 	-- require('lspconfig')['<YOUR_LSP_SERVER>'].setup {
-- v1 -- 	--     capabilities = capabilities
-- v1 -- 	-- }
-- v1 -- end

local ok, cmp = pcall(require, 'cmp'); if not ok then return end


cmp.setup({
  sources = {
    {name = 'nvim_lsp'},
  },
  mapping = cmp.mapping.preset.insert({
    ['<CR>'] = cmp.mapping.confirm({select = false}),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<Tab>'] = function(fallback) if cmp.visible() then cmp.select_next_item() else fallback() end end,
  }),
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
})


--  cmp.setup {
--    mapping = {
--      ['<Tab>'] = function(fallback)
--        if cmp.visible() then
--          cmp.select_next_item()
--        else
--          fallback()
--        end
--      end
--    }
--  }

-- -- If you didn't select any item and the option table contains `select = true`,
-- -- nvim-cmp will automatically select the first item.
-- -- `behavior=cmp.ConfirmBehavior.Insert`: inserts the selected item and
-- cmp.setup {
--   mapping = {
--     ["<CR>"] = cmp.mapping.confirm({ select = true, behavior = cmp.ConfirmBehavior.Replace }),
--   }
-- }
