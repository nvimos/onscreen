-- PowerShell: <F2> item that runs the current file with pwsh (overseer task)

local SRC = 'after/ftplugin/ps1.lua: '

local f2 = require('genja.f2')

f2.add_task(f2.groups.this_file, 'run with PowerShell (pwsh)')
    :fn(function(ctx)
        local file = vim.api.nvim_buf_get_name(ctx.bufnr)
        if file == '' then
            vim.notify(SRC .. 'buffer has no file name', vim.log.levels.WARN)
            return
        end
        if vim.fn.executable('pwsh') == 0 then
            vim.notify(SRC .. 'no pwsh in nvim\'s PATH', vim.log.levels.ERROR)
            return
        end
        if vim.bo[ctx.bufnr].modified then
            vim.notify(SRC .. 'unsaved changes, pwsh runs the file on disk', vim.log.levels.WARN)
        end
        local cmd = { 'pwsh', '-NoProfile', '-File', file }
        require('genja.f2.run').overseer('pwsh ' .. vim.fs.basename(file), cmd, vim.fs.dirname(file))
    end)
    :buffer(0)
    :add()
