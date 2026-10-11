-- vim: set foldmethod=marker foldlevel=0 foldnestmax=2 foldcolumn=2:

-- {{{ aliases
local aucmd, augrp = vim.api.nvim_create_autocmd, vim.api.nvim_create_augroup ---@diagnostic disable-line: unused-local
local err, notify  = vim.api.nvim_err_writeln, vim.notify ---@diagnostic disable-line: unused-local
local km, bkm      = vim.keymap.set, vim.api.nvim_buf_set_keymap ---@diagnostic disable-line: unused-local
local nosi         = function(d) return { silent = true, noremap = true, desc = d } end
-- }}}

-- {{{ Mylsp module
Mylsp              = {}
Mylsp.Augroup      = augrp('UserLspConfig', { clear = true })
Mylsp.Servers      = {}
function Mylsp.emerge(...)
	for _, e in ipairs({ ... })
	do table.insert(Mylsp.Servers, e) end
	return Mylsp.Servers
end

-- }}}


local function lspconfig_other()

	require('lspconfig').powershell_es.setup {}

end

Mylsp.emerge(
	'powershell_es',
	'emmet_language_server',
	'dockerls',
	'pyright',
	'textlsp',
	'efm'
)

-- emerge…  ensure_installed… {{{
-- emerge…  lua, bash, yaml {{{
Mylsp.emerge('lua_ls', 'bashls', 'yamlls') -- }}}
-- emerge…  html, css {{{
Mylsp.emerge('html', 'cssls')              -- }}}
-- emerge… jevascrapts {{{
Mylsp.emerge('ts_ls', 'eslint', 'jsonls')  -- }}}

-- {{{ ansible: needs more work. maybe setup in WSL
--- vermaden (perfect ansible setup)
--- at this point im thinking it's better to run vim from wsl for ansible work.
--- Mylsp.emerge('ansiblels') -- pip  install --user ansible-lint
--- Mylsp.emerge('ansible-lint') -- not supported on windows (2024-09)
--- }}}

-- }}}

-- lspconfig… efm {{{
local function lspconfig_efmls()
	local luacheck    = require('efmls-configs.linters.luacheck')
	local flake8      = require('efmls-configs.linters.flake8')
	local eslint_d    = require('efmls-configs.linters.eslint_d')
	local shellcheck  = require('efmls-configs.linters.shellcheck')
	local alex        = require('efmls-configs.linters.alex')
	local hadolint    = require('efmls-configs.linters.hadolint')
	local solhint     = require('efmls-configs.linters.solhint')
	-- local ansible_lint = require('efmls-configs.linters.ansible_lint')
	local stylua      = require('efmls-configs.formatters.stylua')
	local black       = require('efmls-configs.formatters.black')
	local prettierd   = require('efmls-configs.formatters.prettier_d')
	local fixjson     = require('efmls-configs.formatters.fixjson')
	local shfmt       = require('efmls-configs.formatters.shfmt')
	local efmls_langs = {
		-- lua             = { luacheck,    stylua    },
		python          = { flake8, black },
		typescript      = { eslint_d, prettierd },
		json            = { eslint_d, fixjson },
		jsonc           = { eslint_d, fixjson },
		sh              = { shellcheck, shfmt },
		javascript      = { eslint_d, prettierd },
		javascriptreact = { eslint_d, prettierd },
		typescriptreact = { eslint_d, prettierd },
		svelte          = { eslint_d, prettierd },
		vue             = { eslint_d, prettierd },
		markdown        = { alex, prettierd },
		docker          = { hadolint, prettierd },
		solidity        = { solhint },
		-- NOT ON WIN 2024-09 -- ansible         = { ansible_lint }, -- double check...
	}
	-- configure efm server
	require('lspconfig').efm.setup({
		filetypes = {
			-- "lua",
			"python",
			"json",
			"jsonc",
			"sh",
			"javascript",
			"javascriptreact",
			"typescript",
			"typescriptreact",
			"svelte",
			"vue",
			"markdown",
			"docker",
			"solidity",
			-- "ansible", -- double check...
		},
		init_options = {
			documentFormatting = true,
			documentRangeFormatting = true,
			hover = true,
			documentSymbol = true,
			codeAction = true,
			completion = true,
		},
		settings = {
			languages = efmls_langs,
		},
	})
end
-- }}}

-- {{{ lspconfig… yaml
local function lspconfig_yaml()

	-- require('lspconfig').ansiblels.setup({}) -- windows not supported...

	require('lspconfig').yamlls.setup {
		settings = {
			yaml = {
				schemas = {
					-- Add any YAML schemas you want to use here
					-- For example:
					["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
					["https://json.schemastore.org/ansible-playbook.json"] = { "*playbook.yml", "*playbook.yaml" },
					["https://raw.githubusercontent.com/instrumenta/kubernetes-json-schema/master/v1.18.0-standalone-strict/all.json"] = "/*.k8s.yaml",
				}
			}
		}
	}
end
-- }}}

-- {{{ lspconfig… lua
local function lspconfig_lua()
	local libs = {}
	for _, e in pairs({
		vim.fn.expand "$VIMRUNTIME/lua",
		vim.fn.expand "$VIMRUNTIME/lua/vim/lsp",
		vim.fn.stdpath 'config' .. '/lua',
		vim.fn.stdpath 'data' .. '/lazy',
		vim.fn.stdpath 'data' .. '/lazy/lazy.nvim/lua/lazy',
		vim.fn.stdpath 'data' .. '/lazy/nvim-cmp/lua',
	}) do
		e = vim.fs.normalize(e)
		local stat = vim.uv.fs_stat(e)
		if stat ~= nil and stat.type == 'directory' then
			libs[e] = true
		end
	end
	local plugs = vim.fn.stdpath 'data' .. '/lazy/*/lua'
	for _, e in pairs(vim.fn.glob(plugs, false, true)) do
		libs[e] = true
	end
	require('lspconfig').lua_ls.setup({
		filetypes = { 'lua' },
		settings = {
			Lua = {
				-- runtime = {
				-- version = 'LuaJIT'
				-- },
				completion = {
					displayContext = true,
					keywordSnippet = 'Both',
				},
				diagnostics = {
					disable = {
						'lowercase-global'
					},
					globals = {
						'vim',
						'IsDir'
					}
				},
				workspace = {
					-- library = {
					-- 	-- [im.fn.stdpath "data" .. "/lazy/ui/nvchad_types"] = true,
					-- 	-- ["C:/Games/OpenMW.master/resources/lua_api/openmw"] = true,
					-- 	-- ["C:/Games/OpenMW.master/resources/vfs"] = true,
					-- },
					ignoreDir = { '.vscode', '.git' },
					library = libs,
					-- maxPreload = 100000,
					-- preloadFileSize = 10000,
					maxPreload = 7000, -- max open files ?
					preloadFileSize = 400, -- kib
					useGitIgnore = true,
				},
				runtime = {
					path = { '?.lua', '?/init.lua' },
					pathStrict = false,
				},
			}
		}
	})
end
-- }}}

-- {{{ textlsp… lua
local function lspconfig_textls()

	local
	En = {}

	En.languagetool = false
	En.languagetool = true

	En.ollama = false
	En.ollama = true

	En.gramformer = true
	En.gramformer = false

	En.hf_checker = true
	En.hf_checker = false

	En.hf_instruction_checker = true
	En.hf_instruction_checker = false

	En.hf_completion = true
	En.hf_completion = false

	require('lspconfig').textlsp.setup({
		filetypes = { 'text', 'markdown', 'asciidoc' },
		settings = {
			textLSP = {
				analysers = {
					languagetool = {
						enabled = En.languagetool,
						check_text = {
							on_open = false,
							on_save = true,
							on_change = false,
						}
					},
					ollama = {
						enabled = En.ollama,
						check_text = {
							on_open = false,
							on_save = true,
							on_change = false,
						},
						model = "llama3.2", -- smaller but faster model
						-- model = "phi3:3.8b-instruct", -- smaller but faster model
						-- model = "phi3:14b-instruct",  -- more accurate
						max_token = 50,
					},
					gramformer = { -- needs to be installed manually
						enabled = En.gramformer,
						gpu = true,
						check_text = {
							on_open = false,
							on_save = true,
							on_change = false,
						}
					},

					hf_checker = {
						enabled = En.hf_checker,
						gpu = true,
						quantize = 32,
						model = 'pszemraj/flan-t5-large-grammar-synthesis',
						-- pszemraj/grammar-synthesis-small
						-- pszemraj/grammar-synthesis-large
						-- pszemraj/flan-t5-large-grammar-synthesis
						-- pszemraj/flan-t5-xl-grammar-synthesis
						-- pszemraj/bart-base-grammar-synthesis
						min_length = 40,
						check_text = {
							on_open = false,
							on_save = true,
							on_change = false,
						}
					},
					hf_instruction_checker = {
						enabled = En.hf_instruction_checker,
						gpu = true,
						quantize = 32,
						model = 'grammarly/coedit-large',
						min_length = 40,
						check_text = {
							on_open = false,
							on_save = true,
							on_change = false,
						}
					},
					hf_completion = {
						enabled = En.hf_completion,
						gpu = true,
						quantize = 32,
						model = 'bert-base-multilingual-cased',
						topk = 5,
					},

					-- openai = {
					-- 	enabled = false,
					-- 	api_key = '<MY_API_KEY>',
					-- 	-- url = '<CUSTOM_URL>'  -- optional to use an OpenAI-compatible server
					-- 	check_text = {
					-- 		on_open = false,
					-- 		on_save = false,
					-- 		on_change = false,
					-- 	},
					-- 	model = 'gpt-3.5-turbo',
					-- 	max_token = 16,
					-- },

					-- grammarbot = {
					-- 	enabled = false,
					-- 	api_key = '<MY_API_KEY>',
					-- 	-- longer texts are split, this parameter sets the maximum number of splits per analysis
					-- 	input_max_requests = 1,
					-- 	check_text = {
					-- 		on_open = false,
					-- 		on_save = false,
					-- 		on_change = false,
					-- 	}
					-- },
				},
				documents = {
					-- the language of the documents, could be set to `auto` of `auto:<fallback>`
					-- to detect automatically, default: auto:en
					language = "auto:en",
					-- do not autodetect documents with fewer characters
					min_length_language_detect = 20,
					org = {
						org_todo_keywords = {
							'TODO',
							'IN_PROGRESS',
							'DONE'
						},
					},
					txt = {
						parse = true,
					},
				},
			}
		}
	})
end
-- }}}

--- -- {{{ lspconfig… html, css,
--- local function lspconfig_html_css()
--- 	-- -- https://nathan-long.com/blog/modern-javascript-tooling-in-neovim/
--- 	-- local caps = require('cmp_nvim_lsp').default_capabilities()
--- 	-- caps.textDocument.completion.completionItem.snippetSupport = true
--- 	-- -- 2024-08 looks to me like snippetSupport is already enabled.
--- 	-- require('lspconfig').tailwindcss.setup { capabilities = caps }
--- 	-- require('lspconfig').ts_ls.setup { capabilities = caps }
--- 	-- require('lspconfig').jsonls.setup { capabilities = caps }
--- 	-- require('lspconfig').eslint.setup { capabilities = caps }
--- 	-- require('lspconfig').cssls.setup { capabilities = caps }
--- 	-- require('lspconfig').html.setup { capabilities = caps }
--- 	require('lspconfig').html.setup({})
--- 	require('lspconfig').cssls.setup({})
--- 	-- require('lspconfig').tailwindcss.setup({})
--- end
--- -- }}}

-- {{{ lspconfig… jevascrapts
local function lspconfig_jevascrapts()
	require('lspconfig').eslint.setup({})
	require('lspconfig').ts_ls.setup({})
	require('lspconfig').jsonls.setup({})
end
-- }}}

-- {{{ lspconfig… golang
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
-- }}}

--[[ {{{ main setup for mason and mason-lspconfig and lspconfig.{{SERVERs}}
The lazy-plugin-definition in load-lsp.lua for the
    plugins "neovim/nvim-lspconfig" calls
	this setup_mason_lspconfig()

 { neovim/nvim-lspconfig
   , config() -> setup_mason_lspconfig() }

load-lsp.lua is in
   %AppData%/Local/nvim/lua/lazyp or
         ~/.config/nvim/lua/lazyp (ItHINK)
 }}} ]]
Mylsp.setup_mason_lspconfig = function(set, zz)
	require('mason').setup {
		max_concurrent_installers = 12,
		registries = {
			'github:mason-org/mason-registry',
		},
		ui = {
			border = 'double'
		}
	}

	require('mason-lspconfig').setup {
		automatic_installation = true,
		ensure_installed = Mylsp.Servers
	}

	-- lspconfig_html_css()
	-- require'lspconfig'.superhtml.setup { filetypes = { 'superhtml' } }
	require('lspconfig').html.setup { filetypes = { 'html', 'templ', '.tpl', '.twig', '.smarty' } }
	require('lspconfig').cssls.setup {}
	require('lspconfig').emmet_language_server.setup {}

	lspconfig_jevascrapts()

	lspconfig_lua()

	lspconfig_go()

	lspconfig_yaml()

	lspconfig_efmls()

	lspconfig_textls()

	lspconfig_other()

	require('lspconfig').pyright.setup {}
	require('lspconfig').bashls.setup { filetypes = { 'bash', 'sh' } }

	require('lspconfig').dockerls.setup {}



	-- {{{ autocmd: set omnifunc and tagfunc if available
	aucmd('LspAttach', {
		desc = 'LSP capabilities',
		group = Mylsp.Augroup,
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
	-- disable omnifunc and tagfunc when client detaches {{{
	vim.api.nvim_create_autocmd("LspDetach", {
		callback = function(args)
			-- local client = vim.lsp.get_client_by_id(args.data.client_id)
			vim.cmd("setlocal tagfunc< omnifunc<")
		end,
	})
	-- }}} }}}

	-- {{{ todo: configure how to toggle harper in markdown
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
	-- }}}

	-- {{{ more lsp servers
	-- require('lspconfig').tsserver.setup {}
	-- require('lspconfig').rust_analyzer.setup { settings = { ['rust-analyzer'] = {}, }, }
	-- require('lspconfig').awk_ls.setup {}

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
	-- }}}
end


Mylsp.debug = function()
	-- vim.lsp.get_active_clients()
	for i, e in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
		print("client[" .. i .. "] = " .. e.name)
	end
end

return Mylsp


--[[{{{ :help lspconfig-quickstart

1. install server executable to PATH
2. enable the server: `require'lspconfig'.clangd.setup{}`
3. projects must a root marker for a given language server
4. open a file within that project, such as `main.c`.
5. more info about servers' configuration is in |lspconfig-all|.

See |lspconfig-all| for the complete list of language server configurations.
-- }}} ]]

-- {{{ a single SERVERs config parameters
--[[

- setup {}
  Note: There is no composition.
        All entries passed to `setup {}` override
		the entry in the default configuration.

- {root_dir} `function(filename, bufnr)`
  Returns either a filepath (string) or nil. The language server will only
  start if the function returns a filepath.

- {filetypes} `list[string] | nil`
- {autostart} `bool` (default: true)
- {cmd} `list[string]` {'foo', '--bar', 'baz'}

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
-- }}}

-- {{{ overriding some lspconfig defaults

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

]] -- }}}
