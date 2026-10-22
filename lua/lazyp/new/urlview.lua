local Maps = require('genja.map-plugin')

-- urlview.nvim lists URLs in a picker. No plugin opens all URLs of a visual
-- selection, so a 'selection' searcher is registered below; `x gx` uses it.
-- Normal-mode gx stays nvim's built-in (vim.ui.open).

---@type LazySpec
return {
	'axieax/urlview.nvim',
	cmd = 'UrlView',
	keys = Maps:keys(),

	opts = {
		default_picker = 'native', -- vim.ui.select
		default_action = 'system',
		unique = true,
		sorted = false, -- keep text order
		jump = { prev = '[u', next = ']u' },
	},

	config = function(_, opts)
		require('urlview').setup(opts)

		local search = require('urlview.search')
		local helpers = require('urlview.search.helpers')

		-- opts.line1, opts.line2: line range of the selection.
		search.selection = function(o)
			local lines = vim.api.nvim_buf_get_lines(0, o.line1 - 1, o.line2, false)
			return helpers.content(table.concat(lines, '\n'))
		end
	end,
}
