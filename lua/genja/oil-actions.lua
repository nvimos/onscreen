-- oil actions (desc + callback) and the wiring of lua/genja/map-oil.lua to them

local F = require('genja.oil')

local M = {}

-- {{{ actions
local O                = {}
O.vote_movielens       = { desc = "Oil: Rate on movielens", callback = F.rate_on_movielens }
O.open_explorer        = { desc = "Oil: Open dir in explorer", callback = F.open_in_explorer }
O.open_external        = { desc = "Oil: Open (shell)", callback = F.open_via_shell }
O.move_category        = { desc = "Oil: Move to _category", callback = F.move_to_cat }
O.move_category_delete = { desc = "Oil: Move to _delete", callback = F.move_to_cat_delete }
O.select_custom        = { desc = "Oil: Select (custom)", callback = F.select_custom }
O.preview_fit          = { desc = "Oil: Toggle preview (list snug, preview >= 50%)", callback = F.toggle_preview_fit }
O.git_add              = { desc = "Oil: git add (entry or visual lines)", callback = F.git_add }
O.git_unstage          = { desc = "Oil: git unstage, keeps changes (entry or visual lines)", callback = F.git_unstage }
O.diff_preview         = { desc = "Oil: Toggle diff preview (plain preview if unchanged; <CR> in diff opens file at line)", callback = F.toggle_diff_preview }
O.git_commit           = { desc = "Oil: git commit (message popup)", callback = F.git_commit }
O.oily_hide            = { desc = "Oil: hide entry via .oily (nearest up the tree; g. shows all)", callback = function() require("genja-oily").hide() end }

O.sort_name            = { desc = "Oil: Sort by name", callback = F.sort_by_name }
O.sort_mtime           = { desc = "Oil: Sort by mtime", callback = F.sort_by_mtime }
O.sort_size            = { desc = "Oil: Sort by size", callback = F.sort_by_size }
O.cycle_sort           = { desc = "Oil: Cycle sort mode", callback = F.cycle_sort_mode }
O.cycle_sort_opposite  = { desc = "Oil: Cycle sort mode", callback = F.toggle_asc_desc }

M.actions              = O
-- }}}

-- {{{ wiring
-- map-oil.lua values: a name from M.actions, or a table passed to oil as is ({ '3j' })
function M.keymaps()
	local keymaps = {}
	for lhs, value in pairs(require('genja.map-oil').keymaps) do
		if type(value) == 'string' then
			if O[value] then
				keymaps[lhs] = O[value]
			else
				vim.notify('nvim/lua/genja/oil-actions.lua: unknown action ' .. value .. ' for ' .. lhs, vim.log.levels.WARN)
			end
		else
			keymaps[lhs] = value
		end
	end
	return keymaps
end
-- }}}

return M

-- vim: set foldmethod=marker foldlevel=0 foldnestmax=2 foldcolumn=2:
