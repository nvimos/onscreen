-- Lua
-- lazydev.nvim (lua/lazyp/lsp.lua) supplies the Neovim runtime and plugin
-- libraries, so no workspace.library list is needed here.
return {
	servers = {
		lua_ls = {
			settings = {
				Lua = {
					diagnostics = {
						disable = { 'lowercase-global' },
						globals = { 'IsDir' },
					},
				},
			},
		},
	},
}
