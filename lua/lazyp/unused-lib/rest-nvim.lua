-- A very fast, powerful, extensible and asynchronous Neovim HTTP client written in Lua.
-- a library or reference type of thing
---@type LazySpec
return {
	{
		-- not used: 2026-10
		"rest-nvim/rest.nvim",
		enabled = false,
		ft = "http",
		dependencies = { "luarocks.nvim" },
		config = function()
			require("rest-nvim").setup()
		end,
	}
}
