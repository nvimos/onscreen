-- Write files that have the Windows Hidden attribute.
--
-- Why: to overwrite a file, nvim (through libuv's uv_fs_open) calls CreateFileW with
-- CREATE_ALWAYS and FILE_ATTRIBUTE_NORMAL. Windows refuses that with ERROR_ACCESS_DENIED when the
-- existing file is Hidden (or System), so the write fails with the unhelpful
-- "E212: Can't open file for writing: operation not permitted". Vim under MSYS and appends (>>)
-- do not hit it. The call is inside nvim's C code, so the attribute has to be cleared from here.
-- Docs: https://learn.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-createfilew
-- (dwCreationDisposition: CREATE_ALWAYS)
--
-- How: read the attribute with GetFileAttributesW (no process). Only a hidden file costs
-- anything: attrib -H before the write, attrib +H after it (also when the write fails).
-- If Hidden cannot be cleared we say why and leave the file alone; the write then fails with E212
-- and nothing is lost.
local SRC = 'plugin/hidden-write.lua: '

if vim.fn.has('win32') == 1 then
    local ffi = require('ffi')
    local bit = require('bit')

    local FILE_ATTRIBUTE_HIDDEN = 0x2
    local INVALID_FILE_ATTRIBUTES = 0xFFFFFFFF
    local CP_UTF8 = 65001

    -- pcall: a re-sourced plugin file declares the same functions twice
    pcall(ffi.cdef, [[
        uint32_t GetFileAttributesW(const wchar_t *path);
        int MultiByteToWideChar(uint32_t cp, uint32_t flags, const char *s, int n, wchar_t *out, int outn);
    ]])

    -- buffer number -> path whose Hidden attribute we cleared and still have to restore
    local cleared = {}

    ---@return boolean? hidden, string? err
    local function is_hidden(path)
        local len = ffi.C.MultiByteToWideChar(CP_UTF8, 0, path, -1, nil, 0)
        if len == 0 then
            return nil, 'cannot convert the path to UTF-16'
        end
        local wide = ffi.new('wchar_t[?]', len)
        ffi.C.MultiByteToWideChar(CP_UTF8, 0, path, -1, wide, len)
        local attrs = ffi.C.GetFileAttributesW(wide)
        if attrs == INVALID_FILE_ATTRIBUTES then
            return nil, 'GetFileAttributesW failed'
        end
        return bit.band(attrs, FILE_ATTRIBUTE_HIDDEN) ~= 0
    end

    ---@return boolean? ok, string? err
    local function run_attrib(flag, path)
        -- vim.system throws when attrib.exe cannot be started
        local started, res = pcall(function()
            return vim.system({ 'attrib', flag, path }, { text = true }):wait()
        end)
        if not started then
            return nil, tostring(res)
        end
        if res.code ~= 0 then
            return nil, vim.trim(res.stderr .. res.stdout)
        end
        return true
    end

    local function restore(buf)
        local path = cleared[buf]
        if not path then
            return
        end
        cleared[buf] = nil
        local ok, err = run_attrib('+H', path)
        if ok then
            return
        end
        local name = vim.fn.fnamemodify(path, ':t')
        vim.notify(
            SRC .. 'could not set Hidden again on ' .. name .. ': ' .. err
                .. '\nRun:  attrib +H "' .. path .. '"',
            vim.log.levels.ERROR
        )
    end

    local function clear_hidden(buf, path)
        local name = vim.fn.fnamemodify(path, ':t')

        local hidden, err = is_hidden(path)
        if hidden == nil then
            vim.notify(SRC .. 'cannot read the attributes of ' .. name .. ': ' .. err, vim.log.levels.WARN)
            return
        end
        if not hidden then
            return
        end

        local ok
        ok, err = run_attrib('-H', path)
        if not ok then
            vim.notify(
                SRC .. name .. ' is marked Hidden, so Windows refuses this write, and attrib -H failed: '
                    .. err .. '\nThe file is left as it is.',
                vim.log.levels.ERROR
            )
            return
        end

        -- attrib can exit 0 and still keep Hidden (e.g. when System is set), so look again
        hidden, err = is_hidden(path)
        if hidden ~= false then
            vim.notify(
                SRC .. name .. ' is still Hidden after attrib -H' .. (err and (': ' .. err) or '')
                    .. '\nClear Hidden and System by hand:  attrib -H -S "' .. path .. '"',
                vim.log.levels.ERROR
            )
            return
        end

        cleared[buf] = path
        -- BufWritePost does not fire when the write fails; this runs after the command either way
        vim.schedule(function()
            restore(buf)
        end)
    end

    local group = vim.api.nvim_create_augroup('hidden_write', { clear = true })

    vim.api.nvim_create_autocmd('BufWritePre', {
        group = group,
        desc = 'Clear the Hidden attribute before writing',
        callback = function(args)
            if vim.bo[args.buf].buftype ~= '' then
                return
            end
            local path = vim.api.nvim_buf_get_name(args.buf)
            -- a new file cannot be hidden yet
            if path == '' or not vim.uv.fs_stat(path) then
                return
            end
            clear_hidden(args.buf, path)
        end,
    })

    vim.api.nvim_create_autocmd('BufWritePost', {
        group = group,
        desc = 'Set the Hidden attribute again after writing',
        callback = function(args)
            restore(args.buf)
        end,
    })
end
