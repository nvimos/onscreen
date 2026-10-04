return {
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,

		-- dependencies = { "windwp/nvim-ts-autotag", },
		config = function()
			-- import nvim-treesitter plugin
			local treesitter = require("nvim-treesitter.configs")

			-- configure treesitter
			treesitter.setup({ -- enable syntax highlighting
				-- modules = true,
				highlight = {
					enable = true,
				},
				indent = { enable = true },
				autotag = { enable = true }, -- via windwp/nvim-ts-autotag
				auto_install = true,
				ensure_installed = {
					"markdown",
					"yaml",
					"lua",
					"vim",
					"go",
				},
			})
		end,
	},
}
