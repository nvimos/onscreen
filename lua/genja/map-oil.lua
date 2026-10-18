-- vim: set foldmethod=marker foldlevel=0 foldnestmax=2 foldcolumn=2:

-- oil buffer keymaps, passed to oil's setup as `keymaps` (lua/lazyp/explorer/oil.lua)

local F = require 'genja.fn-oil'

-- {{{ oil actions
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
-- }}}

-- {{{ keymaps
local keymaps          = {

	['gSa'] = O.sort_name, -- mnemonic: mp3 id3 tag %a% for album or %A% for artist
	['gSt'] = O.sort_mtime,
	['gSs'] = O.sort_size,
	['<F12>'] = O.cycle_sort,
	['<S-F12>'] = O.cycle_sort_opposite,
	['<F11>'] = O.cycle_sort_opposite,

	['ge'] = O.open_explorer,
	['gX'] = O.open_external,
	['<LocalLeader>x'] = O.open_external,
	['<LocalLeader>e'] = O.open_explorer,
	['<LocalLeader>,'] = O.vote_movielens,
	['<localleader>j'] = O.move_category,

	['ze'] = O.open_explorer,
	['za'] = O.open_external,
	['zr'] = O.vote_movielens,
	['zj'] = O.move_category,

	['<C-j>'] = O.move_category,
	['<C-q>'] = O.move_category_delete, -- on windows

	['}'] = { '3j', },
	['{'] = { '3k', },

	['se'] = O.open_explorer,
	['sa'] = O.open_external,
	['sr'] = O.vote_movielens,
	['ss'] = O.move_category,
	['sj'] = O.move_category,
	['<C-p>'] = O.preview_fit,
	['gga'] = O.git_add, -- note: gga/ggr make gg wait timeoutlen in oil buffers
	['<LocalLeader>a'] = O.git_add,
	['ggr'] = O.git_unstage,
	['<LocalLeader>r'] = O.git_unstage,
	['ggc'] = O.git_commit,
	['<LocalLeader>c'] = O.git_commit,
	['<C-S-p>'] = O.diff_preview,
	['<LocalLeader>M'] = O.oily_hide,
	['<CR>'] = O.select_custom,
	['<cr>'] = O.select_custom,
}
-- }}}

return keymaps
