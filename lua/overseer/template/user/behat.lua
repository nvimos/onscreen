-- lua/overseer/template/user/behat.lua
-- Behat from a .feature buffer (filetype cucumber): "behat: this feature" and "behat: this scenario"
-- (file:line under the cursor). Project root: the dir with behat.yml / behat.yml.dist / behat.dist.yml.
-- DDEV projects (.ddev/ in the root) run `ddev exec vendor/bin/behat` in the web container, whose
-- cwd is the project root, so paths are passed relative to it. A project inside WSL
-- (//wsl.localhost/<distro>/...) runs ddev in that distro through wsl.exe. Else vendor/bin/behat.

local CONFIGS = { 'behat.yml', 'behat.yml.dist', 'behat.dist.yml' }

---@param root string normalized project root
---@return string|nil distro, string|nil linux_path
local function wsl_path(root)
    local distro, rest = root:match('^/+wsl%.localhost/([^/]+)(/.*)$')
    if not distro then
        distro, rest = root:match('^/+wsl%$/([^/]+)(/.*)$')
    end
    return distro, rest
end

---Command and cwd for behat with `target` (a path relative to the root, maybe :line).
---@param root string
---@param target string
---@return string[]|nil cmd, string|nil cwd, string|nil why
local function command(root, target)
    local behat = { 'vendor/bin/behat', '--format=progress', target }
    if vim.uv.fs_stat(vim.fs.joinpath(root, '.ddev')) then
        local distro, linux = wsl_path(root)
        if distro and vim.fn.has('win32') == 1 then
            local cmd = { 'wsl.exe', '-d', distro, '--cd', linux, '--exec', 'ddev', 'exec' }
            return vim.list_extend(cmd, behat), nil
        end
        if vim.fn.executable('ddev') == 0 then
            return nil, nil, 'a DDEV project, but no ddev in PATH'
        end
        return vim.list_extend({ 'ddev', 'exec' }, behat), root
    end
    local ext = (vim.fn.has('win32') == 1 and '.bat' or '')
    local bin = vim.fs.joinpath(root, 'vendor', 'bin', 'behat' .. ext)
    if not vim.uv.fs_stat(bin) then
        return nil, nil, 'no vendor/bin/behat'
    end
    behat[1] = bin
    return behat, root
end

---@param name string
---@param with_line boolean
---@return overseer.TemplateDefinition
local function template(name, with_line)
    return {
        name = name,
        builder = function()
            local file = vim.fs.normalize(vim.api.nvim_buf_get_name(0))
            local root = vim.fs.normalize(vim.fs.root(0, CONFIGS) or '')
            local target = file:sub(#root + 2)
            if with_line then
                target = target .. ':' .. vim.api.nvim_win_get_cursor(0)[1]
            end
            local cmd, cwd = command(root, target)
            return {
                cmd = cmd,
                cwd = cwd,
                components = {
                    { 'on_output_quickfix', open_on_exit = 'failure' },
                    'default',
                },
            }
        end,
    }
end

---@type overseer.TemplateFileProvider
return {
    condition = { filetype = { 'cucumber' } },
    generator = function()
        local root = vim.fs.root(0, CONFIGS)
        if not root then
            return 'no behat.yml, behat.yml.dist or behat.dist.yml above the file'
        end
        local cmd, _, why = command(vim.fs.normalize(root), 'x')
        if not cmd then
            return why
        end
        return { template('behat: this feature', false), template('behat: this scenario', true) }
    end,
}
