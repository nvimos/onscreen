return {
		'olrtg/nvim-emmet',
		config = function()
				vim.keymap.set( { 'n', 'v' }, '<leader>xe', require('nvim-emmet').wrap_with_abbreviation)
		end,
		dependencies = {
				-- todo: test on a html file
				-- installed via mason?
				-- configured?
				-- configure for wp blocks?
				{ 'olrtg/emmet-language-server' }
		},
}
