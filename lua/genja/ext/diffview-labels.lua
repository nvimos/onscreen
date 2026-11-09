--[[

Pane labels in diffview: the revisions as typed, not commit hashes.

`:DiffviewOpen v2026...PR-zen-z3` labels the panes ` v2026 - path` and
` PR-zen-z3 - path`; with commits (`abc123..def456`) the commits show. Diffview only
knows the hashes, so its own label (`<sha>:path`) is replaced from the `rev_arg` of
the view in the `diff_buf_win_enter` hook (lua/lazyp/git/diffview.lua).

Left alone: file history, merge tool, the plain `:DiffviewOpen` (index vs working tree).
A single revision (`:DiffviewOpen main`) relabels only the left pane; the right one is
the working tree and diffview says so itself.

]]

local M = {}

---@param rev_arg string e.g. 'v2026...PR-zen-z3', 'main..', 'abc123'
---@return string? left left label (nil: keep diffview's own)
---@return string? right right label (nil: keep diffview's own)
local function labels_for(rev_arg)
    if rev_arg == '' then
        return nil, nil
    end
    local from, to = rev_arg:match('^(.-)%.%.%.?(.*)$')
    if not from then
        return rev_arg, nil -- one revision against the working tree
    end
    if from == '' then
        from = 'HEAD'
    end
    if to == '' then
        to = 'HEAD'
    end
    return from, to
end

---Put the revision names in the winbar of one diffview pane.
---@param winid integer
---@param ctx { symbol: string?, layout_name: string }
function M.set(winid, ctx)
    if not ctx.layout_name:match('^diff2') then
        return
    end
    local lib = package.loaded['diffview.lib']
    local view = lib and lib.get_current_view()
    -- file history and merge tool views have no rev_arg (or an empty one): nothing to rename
    if not view or not view.rev_arg or not view.cur_entry then
        return
    end
    local left, right = labels_for(view.rev_arg)
    local name = (ctx.symbol == 'a' and left) or (ctx.symbol == 'b' and right) or nil
    if not name then
        return
    end
    local label = (' %s - %s'):format(name, view.cur_entry.path):gsub('%%', '%%%%')
    vim.wo[winid].winbar = label
end

-- exposed for tests
M._labels_for = labels_for

return M
