-- :Ops and :Frontend: start the latest release build of the Ops desktop app (Flutter front end,
-- ~/es/nvimos-poc-frontend, `make build`; vim.g.nvimos_frontend_dir overrides) connected to this nvim.
-- This nvim listens first if it isn't already: the address relay serves (lua/lazyp/new/nvimos-serve.lua),
-- else 127.0.0.1:6666, else a free port when another nvim holds that one; the app gets it as its argument.
local SRC = 'plugin/ops.lua: '

local function launch()
    local dir = vim.g.nvimos_frontend_dir or '~/es/nvimos-poc-frontend'
    local exe = vim.fs.normalize(dir .. '/build/windows/x64/runner/Release/ops.exe')
    if vim.fn.executable(exe) ~= 1 then
        vim.notify(SRC .. 'no build at ' .. exe .. ' (make build in the front end)', vim.log.levels.ERROR)
        return
    end

    local ok, nvimos = pcall(require, 'nvimos')
    if not ok then
        vim.notify(SRC .. 'relay plugin not loaded: ' .. tostring(nvimos), vim.log.levels.ERROR)
        return
    end
    -- This nvim's socket for the app: the one already served, else start it.
    local addr = nvimos.served or nvimos.DEFAULT_ADDRESS
    if not vim.tbl_contains(vim.fn.serverlist(), addr) then
        local served, err = pcall(vim.fn.serverstart, addr)
        if not served then
            -- Another nvim holds the default port: any free port, the app gets it as its argument.
            served, err = pcall(vim.fn.serverstart, '127.0.0.1:0')
        end
        if not served then
            vim.notify(SRC .. 'listen failed: ' .. tostring(err), vim.log.levels.ERROR)
            return
        end
        addr = err
        -- So :NvimosServeStop and the next :Ops find it.
        nvimos.served = addr
        vim.notify(SRC .. 'listening on ' .. addr)
    end

    local job = vim.fn.jobstart({ exe, addr }, { cwd = vim.fs.dirname(exe), detach = true })
    if job <= 0 then
        vim.notify(SRC .. 'could not start ' .. exe, vim.log.levels.ERROR)
    end
end

vim.api.nvim_create_user_command('Ops', launch, { desc = 'Ops: start the front end app on this nvim' })
vim.api.nvim_create_user_command('Frontend', launch, { desc = 'Ops: start the front end app on this nvim' })
