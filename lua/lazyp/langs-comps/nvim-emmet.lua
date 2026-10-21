local Maps = require('genja.map-plugin')

---@type LazySpec
return {
		-- todo: test me 2026-10
		event = {'BufRead *.html,*.xml,*.php,*.jsx'},
		'olrtg/nvim-emmet',
		config = function(_, opts)
				Maps:mappings(opts)
		end,
		dependencies = {
				-- todo: test on a html file
				-- installed via mason?
				-- configured?
				-- configure for wp blocks?
				{ 'olrtg/emmet-language-server' }
		},
}
