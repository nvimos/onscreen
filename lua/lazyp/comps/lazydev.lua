return {
	-- Makes lua_ls understand the Neovim runtime and the plugins a file requires.
	'folke/lazydev.nvim',
	ft = 'lua',
	opts = {
		library = {
			{ path = '${3rd}/luv/library', words = { 'vim%.uv' } },
		},
	},
}
