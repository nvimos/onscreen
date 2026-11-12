-- :ReloadLua {module}  uncache, require again, redraw; completes package.loaded
-- :ReloadLuaGenja      the same for every loaded module with "genja" in its name, the `genja` bootstrap last,
--                      then the ftplugin and after/ftplugin files for every loaded buffer's filetype

local function complete_loaded_modules(lead)
    local names = vim.tbl_filter(
        function(n) return vim.startswith(n, lead) end,
        vim.tbl_keys(package.loaded))
    table.sort(names)
    return names
end

local SRC = 'lua/genja/ext/user-command/reload-lua.lua: '

-- Loaded modules with "genja" in the name (genja.*, genja-statusline.*, ...), the bootstrap `genja`
-- (lua/genja/init.lua: options, hilite.vim, the profile) last: it requires most of the others again.
---@return string[]
local function loaded_genja_modules()
    local names = {}
    for name in pairs(package.loaded) do
        if name ~= 'genja' and name:lower():find('genja', 1, true) then
            table.insert(names, name)
        end
    end
    table.sort(names)
    if package.loaded['genja'] ~= nil then
        table.insert(names, 'genja')
    end
    return names
end

-- after/ftplugin files for one filetype part: ft.lua, ft.vim, ft_*.lua, ft_*.vim, ft/*.lua, ft/*.vim
---@param dir string
---@param ft string
---@return string[]
local function ftplugin_files(dir, ft)
    local files = {}
    local globs = { ft .. '.lua', ft .. '.vim', ft .. '_*.lua', ft .. '_*.vim', ft .. '/*.lua', ft .. '/*.vim' }
    for _, g in ipairs(globs) do
        vim.list_extend(files, vim.fn.glob(dir .. '/' .. g, false, true))
    end
    return files
end

-- Source the config's ftplugin/ and after/ftplugin/ files again for every loaded buffer, in the buffer's
-- own filetype. A file must run in a buffer of its filetype (it uses setlocal), so filetypes with no
-- buffer open are skipped: their files are read from disk when such a buffer opens.
-- Buffers in a window run in that window, so window-local options (folds) land there.
-- Not :edit or FileType: that would run every other FileType autocmd (LSP, treesitter) again.
---@return integer sourced, string[] failed
local function reload_ftplugins()
    local config = vim.fn.stdpath('config')
    local dirs = { vim.fs.joinpath(config, 'ftplugin'), vim.fs.joinpath(config, 'after', 'ftplugin') }
    local sourced, failed = 0, {}

    local function source_for(ft)
        for _, part in ipairs(vim.split(ft, '.', { plain = true })) do
            for _, dir in ipairs(dirs) do
                for _, file in ipairs(ftplugin_files(dir, part)) do
                    local ok, err = pcall(vim.cmd.source, vim.fn.fnameescape(file))
                    if ok then
                        sourced = sourced + 1
                    else
                        table.insert(failed, file .. ': ' .. tostring(err))
                    end
                end
            end
        end
    end

    local done = {} -- buffers already handled through a window
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        local ft = vim.bo[buf].filetype
        if ft ~= '' and not done[buf] then
            done[buf] = true
            vim.api.nvim_win_call(win, function() source_for(ft) end)
        end
    end
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        local ft = vim.bo[buf].filetype
        if vim.api.nvim_buf_is_loaded(buf) and ft ~= '' and not done[buf] then
            vim.api.nvim_buf_call(buf, function() source_for(ft) end)
        end
    end
    return sourced, failed
end

local reloading = false -- guard: a reloaded module that calls :ReloadLuaGenja would start it again

-- Guards:
--  re-entry          a second run while one is going is refused
--  cwd               genja/init.lua does win_chdir_home(); the directory you were in is restored
--  failed module     the previous working module stays in package.loaded instead of a hole
--  autocmds          a count before / after, a rise means some module adds them without clearing its group
--  loop              the list is built once and each module required once; require() itself refuses cycles,
--                    and every require is a pcall
local function run_reload_genja()
    local names = loaded_genja_modules()
    local old = {}
    for _, name in ipairs(names) do
        old[name] = package.loaded[name]
    end
    local cwd = vim.fn.getcwd()
    local autocmds_before = #vim.api.nvim_get_autocmds({})
    local started = vim.uv.hrtime()

    -- Drop them all first so a module required by another one is loaded fresh too.
    for _, name in ipairs(names) do
        package.loaded[name] = nil
    end
    local failed = {}
    for _, name in ipairs(names) do
        local ok, err = pcall(require, name)
        if not ok then
            package.loaded[name] = old[name]
            table.insert(failed, name .. ': ' .. tostring(err))
        end
    end

    -- best effort: the directory may be gone, then nvim stays where the reload left it
    pcall(vim.cmd.cd, vim.fn.fnameescape(cwd))
    local ft_sourced, ft_failed = reload_ftplugins()
    vim.cmd('redrawstatus! | redrawtabline')
    local ms = math.floor((vim.uv.hrtime() - started) / 1e6)
    vim.notify(SRC .. ('reloaded %d modules, %d ftplugin files in %d ms'):format(#names - #failed, ft_sourced, ms))
    local added = #vim.api.nvim_get_autocmds({}) - autocmds_before
    if added > 0 then
        vim.notify(SRC .. ('%d autocmds more than before: some module adds them without clearing its group'):format(added), vim.log.levels.WARN)
    end
    if #failed > 0 then
        vim.notify(SRC .. 'kept the old version of:\n' .. table.concat(failed, '\n'), vim.log.levels.ERROR)
    end
    if #ft_failed > 0 then
        vim.notify(SRC .. 'ftplugin failed:\n' .. table.concat(ft_failed, '\n'), vim.log.levels.ERROR)
    end
end

local function reload_genja()
    if reloading then
        vim.notify(SRC .. 'a reload is already running', vim.log.levels.WARN)
        return
    end
    reloading = true
    local ok, err = pcall(run_reload_genja)
    reloading = false -- also after an error, or the command stays locked until restart
    if not ok then
        vim.notify(SRC .. 'reload aborted: ' .. tostring(err), vim.log.levels.ERROR)
    end
end

return {
    setup_user_command = function()
        vim.api.nvim_create_user_command('ReloadLuaGenja', reload_genja, {
            nargs = 0,
            desc = 'Lua: reload every loaded module with genja in its name',
        })

        vim.api.nvim_create_user_command('ReloadLua',
            function(o)
                local old = package.loaded[o.args]
                package.loaded[o.args] = nil
                local ok, err = pcall(require, o.args)
                if not ok then
                    -- keep the working version instead of a hole in package.loaded
                    package.loaded[o.args] = old
                    vim.notify(SRC .. 'kept the old version of ' .. o.args .. ': ' .. tostring(err), vim.log.levels.ERROR)
                    return
                end
                vim.cmd('redrawstatus! | redrawtabline')
            end,
            {
                nargs = 1,
                complete = complete_loaded_modules,
                desc = 'Lua: reload a loaded module'
            })
    end
}
