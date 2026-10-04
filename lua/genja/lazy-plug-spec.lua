PluginSpec = {}

-- below is a list of plugs to maybe try at some point
-- or that are undergoing evaluation
for _, e in pairs({
	-- { Vonr/align.nvim },
	{
		dir = require('genja.api').CONFIG .. '/plug-wip/genja-statusline.nvim',
		opts = {},
		event = "VeryLazy",
		config = function()
			require('genja-statusline').setup()
		end
	},
	{
		"sudormrfbin/cheatsheet.nvim",
		dependencies = {
			"nvim-telescope/telescope.nvim",
			"nvim-lua/plenary.nvim",
		},
		cmd = "Cheatsheet",
		keys = {
			{ "<leader>?", "<cmd>Cheatsheet<cr>", desc = "Cheat-sheet" },
		},
	},

}) do
	table.insert(PluginSpec, e)
end

-- This file declares new plugins that are undergoing evaluation
-- When confirmed as good enough, they can go to;
--
--     VIM/genja/lazy.lua
--     VIM/lua/lazy-my/      (my configs)
--     VIM/lua/lazy-others/  (other people's configs)
--     VIM/lua/lazy-{topic}/ (by feature, by use case)
--
-- The format for plugin declarations is explained in;
--
--     :help lazy.nvim-lazy.nvim-plugin-spec



--[[
	import lazy-plugin specs from
	VIM/lua/lazy-my
	VIM/lua/lazy-others
	VIM/lua/lazy-{topic}
--]]
for _, value in ipairs({
	-- { import = 'lazyp.new' },   -- undergoing evaluation
	-- { import = 'lazyp.no' },   -- not loaded atm
	{ import = 'lazyp.comps' }, -- lsp, completion, llm
	{ import = 'lazyp.maybe' }, -- seems ok to keep
	{ import = 'lazyp.my' },    -- my configs
	{ import = 'lazyp.others' }, -- configs taken from other people
	{ import = 'lazyp.term' },  -- terminal integrations, floaters
	{ import = 'lazyp.ui' },    -- adjustments for nvim, qt, neovide
	{ import = 'lazyp.utilqol' }, -- make it better (quality of life and utilities)
}) do
	table.insert(PluginSpec, value)
end


require('lazy').setup({
		spec = PluginSpec,
		defaults = {
				lazy = true
		},
		install = { colorscheme = { "habamax" } }, -- nightfox is also nice
		change_detection = {
				notify = false
		},
		--[[
		dev = {
				---@type string | fun(plugin: LazyPlugin): string
				---directory where you store your local plugin projects
			path = 'A:\workspace',
		}
		--]]
})
