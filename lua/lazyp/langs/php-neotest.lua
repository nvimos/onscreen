-- Tests: run the nearest test, a file or the suite, with results inline.
-- PHP adapters on top of genja's LSP setup (plug-wip/genja-completion011.nvim/lua/genja/lang/php.lua).

local Maps = require('genja.map-plugin')

---@type LazySpec
return {
	'nvim-neotest/neotest',
	ft = 'php',
	dependencies = {
		'nvim-neotest/nvim-nio',
		'nvim-lua/plenary.nvim',
		'nvim-treesitter/nvim-treesitter',
		'olimorris/neotest-phpunit',
		'V13Axel/neotest-pest',
	},
	keys = Maps:keys(),
	config = function()
		require('neotest').setup({
			adapters = {
				require('neotest-pest'),
				-- Pest projects also have phpunit; leave those to neotest-pest.
				require('neotest-phpunit')({ root_ignore_files = { 'tests/Pest.php' } }),
			},
		})
	end,
}
