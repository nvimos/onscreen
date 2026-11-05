-- Where lazy loads a plug-wip plugin from: the local checkout in plug-wip/ when it's there,
-- else the published repo (github.com/tox2ik/<repo>), which a fresh clone of the config gets.
-- A spec names the repo first and sets `dir = Wip.dir(...)`:
--   { 'tox2ik/genja-finder.nvim', dir = Wip.dir('genja-finder.nvim') }
local M = {}

---The plug-wip folder, or nil when it is missing (lazy then clones the spec's repo).
---@param folder string folder name under plug-wip/, e.g. 'genja-finder.nvim'
---@return string|nil
function M.dir(folder)
    local path = vim.fn.stdpath('config') .. '/plug-wip/' .. folder
    if vim.uv.fs_stat(path) then
        return path
    end
    return nil
end

return M
