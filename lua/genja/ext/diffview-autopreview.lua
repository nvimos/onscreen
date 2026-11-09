--[[

Diffview file panel: moving the cursor over a file opens its diff, no <CR> needed.

`j`, `k` and the arrow keys in the panel (lua/lazyp/git/diffview.lua) call move(): diffview's own
next/prev entry, then the diff of the file under the cursor in the panes while focus stays in
the panel. Folders and commit entries are skipped, so walking over them does not fold them.
On by default; toggle() flips it (F2 item `diffview toggle auto preview`).

]]

local SRC = 'lua/genja/ext/diffview-autopreview.lua: '

local M = {}

M.enabled = true

---The file entry under the cursor of the panel, with its view. Folders (collapsed is a boolean)
---and commit entries (files) are not diffs to open.
---@return table? view
---@return table? item
local function file_at_cursor()
    local lib = package.loaded['diffview.lib']
    local view = lib and lib.get_current_view()
    if not view or not view.panel or not view.panel.get_item_at_cursor then
        return nil, nil
    end
    local item = view.panel:get_item_at_cursor()
    if not item or type(item.collapsed) == 'boolean' or item.files then
        return nil, nil
    end
    return view, item
end

---@param direction integer 1 down, -1 up
function M.move(direction)
    local actions = require('diffview.actions')
    if direction > 0 then
        actions.next_entry()
    else
        actions.prev_entry()
    end
    if not M.enabled then
        return
    end
    local view, item = file_at_cursor()
    if view then
        view:set_file(item, false)
    end
end

---Left click in the panel: put the cursor on the clicked line, then open a file's diff
---(on or off, a click is explicit) or fold / unfold a folder like <CR>.
function M.click()
    local pos = vim.fn.getmousepos()
    if pos.winid == 0 or pos.line == 0 then
        return
    end
    vim.api.nvim_set_current_win(pos.winid)
    vim.api.nvim_win_set_cursor(pos.winid, { pos.line, math.max(pos.column - 1, 0) })
    local view, item = file_at_cursor()
    if view then
        view:set_file(item, false)
    else
        require('diffview.actions').select_entry() -- folders and commit entries
    end
end

function M.toggle()
    M.enabled = not M.enabled
    vim.notify(SRC .. 'auto preview ' .. (M.enabled and 'on' or 'off'))
end

return M
