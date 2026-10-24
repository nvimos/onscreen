local imports = {

	-- { import = 'lazyp' }, -- CONFIG/lua/lazyp/*
	{ import = 'lazyp.debug' },
	{ import = 'lazyp.git' },
	{ import = 'lazyp.langs' },
	{ import = 'lazyp.explorer' },
	{ import = 'lazyp.langs-comps' }, -- lsp, completion, llm
	{ import = 'lazyp.maybe' },    -- seems ok to keep
	{ import = 'lazyp.my' },       -- my configs
	{ import = 'lazyp.new' },      -- undergoing evaluation

	-- { import = 'lazyp.no' },   -- not loaded atm
	{ import = 'lazyp.others' },   -- configs taken from other people
	{ import = 'lazyp.phunnee' },  -- fun, cool stuff
	{ import = 'lazyp.term' },     -- terminal integrations, floaters
	{ import = 'lazyp.ui' },       -- adjustments for nvim, qt, neovide
	{ import = 'lazyp.ui-gui' },       -- gui stuff
	{ import = 'lazyp.ui-telescope' },       -- adjustments for nvim, qt, neovide
	{ import = 'lazyp.util-qol' },  -- make it better (quality of life and utilities)
}


---@type LazySpec[]
PluginSpec = {}
for _, e in pairs({
	-- e.g. { Vonr/align.nvim },


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
for _, value in ipairs(imports) do
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
