-- vim: set foldmethod=marker foldlevel=1 foldnestmax=2 foldcolumn=2:
--
-- oil actions (desc + callback), assigned to keys in lua/genja/map-oil.lua

local F = require('genja.oil')

local O                = {}

-- {{{ open the entry: in nvim, or outside it (explorer, shell, browser)
O.select_custom        = { desc = "Select (custom, vlc?)", callback = F.select_custom }
O.open_explorer        = { desc = "Open: explorer", callback = F.open_in_explorer }
O.open_external_os_xdg = { desc = "Open: explorer / open / xdg-open", callback = F.open_via_shell }
O.vote_movielens       = { desc = "Rate on movielens", callback = F.rate_on_movielens }
-- }}}

-- {{{ preview window: file or git diff
O.preview_fit          = { desc = "Preview: snug", callback = F.toggle_preview_fit }
O.diff_preview         = { desc = "Preview: diff-goto", callback = F.toggle_diff_preview }
-- }}}

-- {{{ tidy the listing: move entries to _category dirs, hide them via .oily
O.move_category        = { desc = "Undersort: Move to _category", callback = F.move_to_cat }
O.move_category_delete = { desc = "Undersort: Move to _delete", callback = F.move_to_cat_delete }

-- }}}

O.oily_hide            = { desc = "Oily: hide via .oily", callback = function() require("genja-oily").hide() end }

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
O.startdirs_add        = { desc = "Startdirs: add dir under cursor", callback = function()
	local dir = entry_dir()
	if dir then require('genja-startdirs').add(dir, 'oil') end
end }
O.startdirs_remove     = { desc = "Startdirs: remove dir from start", callback = function()
	local dir = entry_dir()
	if dir then require('genja-startdirs').remove(dir) end
end }
-- }}}

-- {{{ git: stage, unstage, commit the entries
O.git_add              = { desc = "Git: add", callback = F.git_add }
O.git_unstage          = { desc = "Git: unstage (keep changes)", callback = F.git_unstage }
O.git_commit           = { desc = "Git: commit (message popup)", callback = F.git_commit }
-- }}}

-- {{{ sort the listing
O.sort_name            = { desc = "Oil: Sort by name", callback = F.sort_by_name }
O.sort_mtime           = { desc = "Oil: Sort by mtime", callback = F.sort_by_mtime }
O.sort_size            = { desc = "Oil: Sort by size", callback = F.sort_by_size }
O.cycle_sort           = { desc = "Oil: Cycle sort mode", callback = F.cycle_sort_mode }
O.cycle_sort_opposite  = { desc = "Oil: Cycle sort mode", callback = F.toggle_asc_desc }
-- }}}

return O
