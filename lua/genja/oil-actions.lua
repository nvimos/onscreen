-- vim: set foldmethod=marker foldlevel=1 foldnestmax=2 foldcolumn=2:
--
-- oil actions (desc + callback), assigned to keys in lua/genja/map-oil.lua

local F = require('genja.oil')

local O                = {}

-- {{{ open the entry: in nvim, or outside it (explorer, shell, browser)
O.select_custom        = { desc = "Oil: Select (custom)", callback = F.select_custom }
O.open_explorer        = { desc = "Oil: Open dir in explorer", callback = F.open_in_explorer }
O.open_external_os_xdg = { desc = "Oil: Open (explorer / open / xdg-open)", callback = F.open_via_shell }
O.vote_movielens       = { desc = "Oil: Rate on movielens", callback = F.rate_on_movielens }
-- }}}

-- {{{ preview window: file or git diff
O.preview_fit          = { desc = "Oil: Toggle preview (list snug, preview >= 50%)", callback = F.toggle_preview_fit }
O.diff_preview         = { desc = "Oil: Toggle diff preview (plain preview if unchanged; <CR> in diff opens file at line)", callback = F.toggle_diff_preview }
-- }}}

-- {{{ tidy the listing: move entries to _category dirs, hide them via .oily
O.move_category        = { desc = "Oil: Move to _category", callback = F.move_to_cat }
O.move_category_delete = { desc = "Oil: Move to _delete", callback = F.move_to_cat_delete }
O.oily_hide            = { desc = "Oil: hide entry via .oily (nearest up the tree; g. shows all)", callback = function() require("genja-oily").hide() end }
-- }}}

-- {{{ start dirs (plug-wip/genja-startdirs.nvim): the dir under the cursor, else oil's dir
---@return string?
local function entry_dir()
	local oil = require('oil')
	local dir = oil.get_current_dir()
	local entry = oil.get_cursor_entry()
	if dir and entry and entry.type == 'directory' then
		return dir .. entry.name
	end
	return dir
end
O.startdirs_add        = { desc = "Oil: add dir to start dirs [oil] (dir under cursor, else this one)", callback = function()
	local dir = entry_dir()
	if dir then require('genja-startdirs').add(dir, 'oil') end
end }
O.startdirs_remove     = { desc = "Oil: remove dir from start dirs (dir under cursor, else this one)", callback = function()
	local dir = entry_dir()
	if dir then require('genja-startdirs').remove(dir) end
end }
-- }}}

-- {{{ git: stage, unstage, commit the entries
O.git_add              = { desc = "Oil: git add (entry or visual lines)", callback = F.git_add }
O.git_unstage          = { desc = "Oil: git unstage, keeps changes (entry or visual lines)", callback = F.git_unstage }
O.git_commit           = { desc = "Oil: git commit (message popup)", callback = F.git_commit }
-- }}}

-- {{{ sort the listing
O.sort_name            = { desc = "Oil: Sort by name", callback = F.sort_by_name }
O.sort_mtime           = { desc = "Oil: Sort by mtime", callback = F.sort_by_mtime }
O.sort_size            = { desc = "Oil: Sort by size", callback = F.sort_by_size }
O.cycle_sort           = { desc = "Oil: Cycle sort mode", callback = F.cycle_sort_mode }
O.cycle_sort_opposite  = { desc = "Oil: Cycle sort mode", callback = F.toggle_asc_desc }
-- }}}

return O
