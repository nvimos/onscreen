-- :ReloadLua {module}  uncache, require again, redraw; completes package.loaded
-- :ReloadLuaGenja      the same for every loaded module with "genja" in its name, the `genja` bootstrap last

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
    vim.cmd('redrawstatus! | redrawtabline')
    local ms = math.floor((vim.uv.hrtime() - started) / 1e6)
    vim.notify(SRC .. ('reloaded %d modules in %d ms'):format(#names - #failed, ms))
    local added = #vim.api.nvim_get_autocmds({}) - autocmds_before
    if added > 0 then
        vim.notify(SRC .. ('%d autocmds more than before: some module adds them without clearing its group'):format(added), vim.log.levels.WARN)
    end
    if #failed > 0 then
        vim.notify(SRC .. 'kept the old version of:\n' .. table.concat(failed, '\n'), vim.log.levels.ERROR)
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
