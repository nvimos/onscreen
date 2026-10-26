---@type LazySpec
return {
	-- Makes lua_ls understand the Neovim runtime and the plugins a file requires.
	'folke/lazydev.nvim',
	ft = 'lua',
	---@type lazydev.Config
	opts = {
		-- env GENJA_LUA_NO_LIB=1 (tests/Makefile): no libraries, lua_ls skips indexing them
		enabled = function()
			if vim.env.GENJA_LUA_NO_LIB ~= nil and vim.env.GENJA_LUA_NO_LIB ~= '' then
				return false
			end
			-- lazydev's default
			return vim.g.lazydev_enabled ~= false
		end,
		library = {
			{ path = '${3rd}/luv/library', words = { 'vim%.uv' } },
		},
	},
}
