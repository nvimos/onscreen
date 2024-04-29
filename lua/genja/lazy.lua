

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({ 'git', 'clone', '--filter=blob:none', 'https://github.com/folke/lazy.nvim.git', '--branch=stable', lazypath, })
end
vim.opt.rtp:prepend(lazypath)


-- PluginSpec «:help lazy.nvim-lazy.nvim-plugin-spec»
PluginSpec = {

	--[[ "debian stable" ]]
	'mbbill/undotree',                -- revert to previous versions of edits
	{ 'rafcamlet/nvim-luapad',        -- evaluate lua in realtime
		lazy = true,
		cmd = 'Luapad'
		},

	{ 'preservim/nerdtree',         -- file navigation reeplacing netrw
		lazy = true,
		config = true,
		cmd = 'NERDTreeToggle',
		-- keys = { '<F1>', '<cmd>NERDTreeToggle<cr>', mode = {'n'} }
		},
	{ 'vim-scripts/mru.vim',       -- most recently used (old school)
		lazy = true,
		keys = { '<S-F1>', nil }
		},

	{ 'tpope/vim-fugitive',        -- git ui
		lazy = true,
		cmd = 'Git'
		},

	--[[ cute ]]
	{ 'eandrju/cellular-automaton.nvim', --  TODO: move fml key-binds here
		lazy = true },

	--[[ "debian testing" ]]
	'folke/zen-mode.nvim', -- todo lazy

	--[[ "debian unstable" ]]
	'michaeljsmith/vim-indent-object', -- leader + vii vai vaI; cii dii -- TODO lazify
	'theprimeagen/harpoon', --  meh ? evaluating...
	{ 'laytan/cloak.nvim',               -- hide sensitive info in config files
		cmd = { 'CloakDisable', 'CloakToggle', 'CloakPreviewLine', 'CloakEnable' },
		config = function() 
			--[[ The plugin automatically activates when 
			     a file matched by the patterns is opened.
			     You do have to call the setup() function. ]]
			require("cloak").setup({
				enabled = true,
				cloak_character = "*",
				highlight_group = "Comment",
				patterns = {
					{ file_pattern = { ".env*", "wrangler.toml", ".dev.vars", }, cloak_pattern = "=.+" },
					{ file_pattern = { ".yml", ".yaml", }, cloak_pattern = { ":.+", "-.+" } },
				}}) end,
		lazy = true,
		},
	--[[ maybe try at some point ]]

	-- 'theprimeagen/refactoring.nvim',
	-- 'github/copilot.vim',


	{ import = "genja.lazy-plug" },
	{ import = 'pluginz' },

}
	
-- local lazy_plugin_spec = { import = "genja.lazy" }
-- table.insert(PluginSpec, lazy_plugin_spec)
--  require("lazy").setup(lazy_plugin_spec, { })

-- table.insert(PluginSpec, { import = "genja.lazy-plug" })
-- table.insert(PluginSpec, { import = 'pluginz' })

require("lazy").setup(PluginSpec, {

})
