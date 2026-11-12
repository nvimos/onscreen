-- DDEV in WSL (mirrored networking), nvim on Windows.
-- Xdebug in the web container reaches nvim's listener only through the Windows LAN IP
-- (host.docker.internal doesn't resolve). That IP changes with the network: check() compares it
-- with DDEV's xdebug_ide_location, set_host() updates it. run() runs a command in the container
-- under the debugger (CLI scripts, Behat), only when asked.
-- Works from a buffer in the WSL copy (//wsl.localhost/<distro>/...) or a Windows copy holding
-- .ddev (synced into WSL; distro from genja.lsp phpactor_wsl.distro).
-- Called from lua/lazyp/debug/dap-php.lua (:DdevXdebugHost, :DebugCli, :DebugBehat).
local SRC = 'lua/genja/ext/debug-ddev.lua: '

local M = {}

-- Windows LAN IPv4, skipping loopback, link-local and Hyper-V switches.
---@return string|nil
function M.windows_ip()
    for name, addrs in pairs(vim.uv.interface_addresses()) do
        if not name:match('vEthernet') and not name:match('Loopback') then
            for _, addr in ipairs(addrs) do
                if addr.family == 'inet' and not addr.internal and not addr.ip:match('^169%.254%.') then
                    return addr.ip
                end
            end
        end
    end
    return nil
end

-- Single-quote for sh.
---@param s string
---@return string
local function shq(s)
    return "'" .. s:gsub("'", "'\\''") .. "'"
end

---@class genja.DdevProject
---@field name string         DDEV project name
---@field root string         folder holding .ddev, as nvim sees it
---@field distro string|nil   WSL distro (nil: the default one)

-- The DDEV project of a buffer, or nil.
---@param bufnr integer
---@return genja.DdevProject|nil
function M.project(bufnr)
    local root = vim.fs.root(bufnr, '.ddev')
    if not root then
        return nil
    end
    root = root:gsub('\\', '/')

    local name = vim.fs.basename(root)
    local ok, lines = pcall(vim.fn.readfile, root .. '/.ddev/config.yaml')
    if ok then
        for _, line in ipairs(lines) do
            local found = line:match('^name:%s*"?([%w%-_.]+)')
            if found then
                name = found
            end
        end
    end

    local distro = root:match('^//wsl%.localhost/([^/]+)/')
    if not distro then
        local has_lsp, lsp = pcall(require, 'genja.lsp')
        if has_lsp then
            distro = (lsp.get().phpactor_wsl or {}).distro
        end
    end
    return { name = name, root = root, distro = distro }
end

-- sh snippet: cd into the project's folder inside WSL (where DDEV runs it).
---@param project genja.DdevProject
---@return string
local function cd_project(project)
    return 'cd "$(ddev describe ' .. shq(project.name)
        .. [[ -j | sed -n 's/.*"approot":"\([^"]*\)".*/\1/p' | head -1)"]]
end

-- wsl.exe running an sh script in the project's distro, from ~.
---@param project genja.DdevProject
---@param script string
---@return string[]
local function wsl_cmd(project, script)
    local cmd = { 'wsl.exe' }
    if project.distro then
        vim.list_extend(cmd, { '-d', project.distro })
    end
    vim.list_extend(cmd, { '--cd', '~', '--exec', 'sh', '-c', script })
    return cmd
end

-- Warn when DDEV sends Xdebug somewhere other than this machine's IP. Runs in the background;
-- quiet outside DDEV projects and when the config can't be read.
---@param bufnr integer
function M.check(bufnr)
    local project = M.project(bufnr)
    local ip = M.windows_ip()
    if not project or not ip then
        return
    end
    local cmd = wsl_cmd(project, 'cat ~/.ddev/global_config.yaml')
    vim.system(cmd, { text = true, env = { WSL_UTF8 = '1' } }, vim.schedule_wrap(function(result)
        if result.code ~= 0 then
            return
        end
        local current = ''
        for line in (result.stdout or ''):gmatch('[^\n]+') do
            local found = line:match('^xdebug_ide_location:%s*"?([^"%s#]*)')
            if found then
                current = found
            end
        end
        if current ~= ip then
            vim.notify(SRC .. string.format('DDEV sends Xdebug to "%s", Windows is at %s: run :DdevXdebugHost',
                current, ip), vim.log.levels.WARN)
        end
    end))
end

-- Point DDEV at this machine's IP, restart the project and turn Xdebug on again (restart turns it off).
---@param bufnr integer
function M.set_host(bufnr)
    local project = M.project(bufnr)
    if not project then
        vim.notify(SRC .. 'no .ddev above ' .. vim.api.nvim_buf_get_name(bufnr), vim.log.levels.WARN)
        return
    end
    local ip = M.windows_ip()
    if not ip then
        vim.notify(SRC .. 'no Windows LAN IP found', vim.log.levels.WARN)
        return
    end
    local script = 'ddev config global --xdebug-ide-location=' .. ip
        .. ' && ddev restart ' .. shq(project.name)
        .. ' && ' .. cd_project(project) .. ' && ddev xdebug on'
    vim.notify(SRC .. 'DDEV Xdebug host ' .. ip .. ', restarting ' .. project.name .. ' ...')
    vim.system(wsl_cmd(project, script), { text = true, env = { WSL_UTF8 = '1' } },
        vim.schedule_wrap(function(result)
            if result.code == 0 then
                vim.notify(SRC .. 'DDEV restarted, Xdebug on, host ' .. ip)
            else
                vim.notify(SRC .. 'DDEV update failed (' .. result.code .. '): ' .. vim.trim(result.stderr or ''),
                    vim.log.levels.ERROR)
            end
        end))
end

-- Run `ddev exec <args>` in a terminal split under the debugger: starts "Listen for Xdebug" first
-- when no session runs. Xdebug's start_with_request=yes makes the CLI connect too.
---@param bufnr integer
---@param args string[]
function M.run(bufnr, args)
    local project = M.project(bufnr)
    if not project then
        vim.notify(SRC .. 'no .ddev above ' .. vim.api.nvim_buf_get_name(bufnr), vim.log.levels.WARN)
        return
    end
    if #args == 0 then
        vim.notify(SRC .. 'nothing to run: give a command, e.g. :DebugCli php bin/console list', vim.log.levels.WARN)
        return
    end
    if not project.root:match('^//wsl%.localhost/') then
        vim.notify(SRC .. 'runs the WSL copy: sync your Windows edits first (make ddev-sync)')
    end

    local dap = require('dap')
    if not dap.session() then
        local config = (dap.configurations.php or {})[1]
        if not config then
            vim.notify(SRC .. 'no PHP debug configuration: is PHP enabled in genja?', vim.log.levels.WARN)
            return
        end
        dap.run(config)
    end

    local quoted = {}
    for _, arg in ipairs(args) do
        table.insert(quoted, shq(arg))
    end
    local script = cd_project(project) .. ' && ddev exec ' .. table.concat(quoted, ' ')
    vim.cmd('botright 12new')
    vim.fn.jobstart(wsl_cmd(project, script), { term = true, env = { WSL_UTF8 = '1' } })
end

-- Behat in the container (profile ddev): args, or the current .feature file, or every scenario.
---@param bufnr integer
---@param args string[]
function M.behat(bufnr, args)
    local cmd = { 'vendor/bin/behat', '--profile=ddev', '--colors', '--no-snippets' }
    if #args > 0 then
        vim.list_extend(cmd, args)
    else
        local file = vim.api.nvim_buf_get_name(bufnr):gsub('\\', '/')
        local project = M.project(bufnr)
        if project and file:match('%.feature$') and file:sub(1, #project.root) == project.root then
            table.insert(cmd, file:sub(#project.root + 2))
        end
    end
    M.run(bufnr, cmd)
end

return M
