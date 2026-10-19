-- oil helpers, one table: require('genja.oil').git_add etc.
-- globals.lua: global helpers from elsewhere, as a module (used by the files below)
-- utils.lua: visual range, cursor entry, cd (used by the files below)
-- plug/: self-contained parts, to become oil plugins later


local entry            = require('genja.oil.entry')
local utils            = require('genja.oil.utils')
local cycle_sorting    = require('genja.oil.cycle-sorting')
local open             = require('genja.oil.open')
local undersort        = require('genja.oil.plug.undersort')
local preview          = require('genja.oil.plug.preview')
local git_diff_preview = require('genja.oil.git-diff-preview')
local git              = require('genja.oil.git')
local git_commit       = require('genja.oil.git-commit')
local fix_buffers      = require('genja.oil.fix-buffers')

local M = {}

-- visual range, cursor entry, cd to entry
M.visual_line_range              = utils.visual_line_range
M.oil_entry_dir_path             = utils.oil_entry_dir_path
M.cd_to_entry                    = utils.cd_to_entry

-- entries under cursor / visual lines
M.entry_from_path                = entry.entry_from_path
M.entry_from_oil                 = entry.entry_from_oil
M.get_oil_entries                = entry.get_oil_entries

-- sort modes, per-dir default (BufEnter)
M.sort_by_mtime_in_certain_paths = cycle_sorting.sort_by_mtime_in_certain_paths
M.dynamic_dir_sort               = cycle_sorting.dynamic_dir_sort
M.toggle_asc_desc                = cycle_sorting.toggle_asc_desc
M.cycle_sort_mode                = cycle_sorting.cycle_sort_mode
M.sort_by_name                   = cycle_sorting.sort_by_name
M.sort_by_size                   = cycle_sorting.sort_by_size
M.sort_by_mtime                  = cycle_sorting.sort_by_mtime

-- explorer, shell, browser, vlc, rar, custom <CR>
M.open_in_browser                = open.open_in_browser
M.open_in_shell                  = open.open_in_shell
M.open_in_explorer               = open.open_in_explorer
M.open_via_shell                 = open.open_via_shell
M.rate_on_movielens              = open.rate_on_movielens
M.vlc_rar                        = open.vlc_rar
M.open_in_vlc                    = open.open_in_vlc
M.select_custom                  = open.select_custom

-- move entries to _category dirs
M.MoveCat                        = undersort.MoveCat
M.move_to_cat                    = undersort.move_to_cat
M.move_to_cat_delete             = undersort.move_to_cat_delete

-- preview sized to the listing
M.fit_preview                    = preview.fit_preview
M.is_previewing                  = preview.is_previewing
M.toggle_preview_fit             = preview.toggle_preview_fit

-- git diff preview
M.toggle_diff_preview            = git_diff_preview.toggle_diff_preview

-- git add / unstage
M.refresh_oil_git                = git.refresh_oil_git
M.git_add                        = git.git_add
M.git_unstage                    = git.git_unstage

-- git commit popup
M.git_commit                     = git_commit.git_commit

-- E211 workaround: drop buffers of deleted files
M.forget_deleted_buffers         = fix_buffers.forget_deleted_buffers

return M
