-- vim: set foldmethod=marker foldlevel=0 foldnestmax=2 foldcolumn=2:

-- oil buffer keymaps: lhs -> action name in lua/genja/oil-actions.lua,
-- or a table oil takes as is. No requires: the which-key spec reads this at startup.

local M = {}

-- {{{ keymaps
M.keymaps = {

	['gSa'] = 'sort_name', -- mnemonic: mp3 id3 tag %a% for album or %A% for artist
	['gSt'] = 'sort_mtime',
	['gSs'] = 'sort_size',
	['<F12>'] = 'cycle_sort',
	['<S-F12>'] = 'cycle_sort_opposite',
	['<F11>'] = 'cycle_sort_opposite',

	['ge'] = 'open_explorer',
	['gX'] = 'open_external',
	['<LocalLeader>x'] = 'open_external',
	['<LocalLeader>e'] = 'open_explorer',
	['<LocalLeader>,'] = 'vote_movielens',
	['<localleader>j'] = 'move_category',

	['ze'] = 'open_explorer',
	['za'] = 'open_external',
	['zr'] = 'vote_movielens',
	['zj'] = 'move_category',

	['<C-j>'] = 'move_category',
	['<C-q>'] = 'move_category_delete', -- on windows

	['}'] = { '3j', },
	['{'] = { '3k', },

	['se'] = 'open_explorer',
	['sa'] = 'open_external',
	['sr'] = 'vote_movielens',
	['ss'] = 'move_category',
	['sj'] = 'move_category',
	['<C-p>'] = 'preview_fit',
	['gga'] = 'git_add', -- note: gga/ggr make gg wait timeoutlen in oil buffers
	['<LocalLeader>a'] = 'git_add',
	['ggr'] = 'git_unstage',
	['<LocalLeader>r'] = 'git_unstage',
	['ggc'] = 'git_commit',
	['<LocalLeader>c'] = 'git_commit',
	['<C-S-p>'] = 'diff_preview',
	['<LocalLeader>M'] = 'oily_hide',
	['<CR>'] = 'select_custom',
	['<cr>'] = 'select_custom',
}
-- }}}

-- {{{ which-key groups, appended to which-key's opts.spec (opts_extend)
-- global labels: which-key hides a group with no mappings, so these show
-- only in oil buffers. "Oil:" sorts them together (sort includes 'desc').
M.which_key = {
	{ 'gS', group = 'Oil: Sort' },
}
-- }}}

return M
