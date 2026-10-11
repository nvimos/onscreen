---@type LazySpec
return {
	-- Makes lua_ls understand the Neovim runtime and the plugins a file requires.
	'folke/lazydev.nvim',
	ft = 'lua',
	---@type lazydev.Config
	opts = {
		library = {
			{ path = '${3rd}/luv/library', words = { 'vim%.uv' } },
		},
	},
}
