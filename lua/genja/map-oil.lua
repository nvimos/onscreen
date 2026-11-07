-- vim: set foldmethod=marker foldlevel=1 foldnestmax=2 foldcolumn=2:

-- oil buffer keymaps, passed to oil's setup (lua/lazyp/explorer/oil.lua)

local O = require('genja.oil-actions')

local M = {}

-- {{{ keymaps
M.keymaps = {

    ['gSa'] = O.sort_name, -- mnemonic: mp3 id3 tag %a% for album or %A% for artist
    ['gSt'] = O.sort_mtime,
    ['gSs'] = O.sort_size,
    ['<F12>'] = O.cycle_sort,
    ['<S-F12>'] = O.cycle_sort_opposite,
    ['<F11>'] = O.cycle_sort_opposite,

    ['ge'] = O.open_explorer,
    ['gX'] = O.open_external_os_xdg,
    ['<LocalLeader>x'] = O.open_external_os_xdg,
    ['<C-Right>'] = 'actions.open_external', -- same as oil's default gx; overrides global <C-Right> (wincmd l)
    ['<LocalLeader>e'] = O.open_explorer,
    ['<LocalLeader>,'] = O.vote_movielens,
    ['<localleader>j'] = O.move_category,

    ['ze'] = O.open_explorer,
    ['za'] = O.open_external_os_xdg,
    ['zr'] = O.vote_movielens,
    ['zj'] = O.move_category,

    ['<C-j>'] = O.move_category,
    ['<C-q>'] = O.move_category_delete, -- on windows

    ['}'] = { '3j', },
    ['{'] = { '3k', },

    ['se'] = O.open_explorer,
    ['sa'] = O.open_external_os_xdg,
    ['sr'] = O.vote_movielens,
    ['ss'] = O.move_category,
    ['sj'] = O.move_category,
    ['<C-p>'] = O.preview_fit,
    ['<C-A-y>'] = O.preview_fit,
    ['<C-M-y>'] = O.preview_fit,
    ['å'] = O.preview_fit, -- jolemak-2026-quirk

    ['gga'] = O.git_add, -- note: gga/ggr make gg wait timeoutlen in oil buffers
    ['<LocalLeader>a'] = O.git_add,
    ['ggr'] = O.git_unstage,
    ['<LocalLeader>r'] = O.git_unstage,
    ['ggc'] = O.git_commit,
    ['<LocalLeader>c'] = O.git_commit,
    ['ggC'] = O.git_commit_entry,
    ['<LocalLeader>C'] = O.git_commit_entry,
    [']c'] = O.next_changed,
    ['[c'] = O.prev_changed,
    ['<C-S-p>'] = O.diff_preview,
    ['<LocalLeader>M'] = O.oily_hide,
    ['<LocalLeader>s'] = O.startdirs_add,
    ['<LocalLeader>S'] = O.startdirs_remove,
    ['<CR>'] = O.select_custom,
    ['<cr>'] = O.select_custom,
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
