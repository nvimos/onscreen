-- API keys: the gitignored lua/genja/local/secrets.lua first, then the environment.
--   require('genja.ext.secrets').LocalOrEnv('GEMINI_API_KEY')
-- secrets.lua returns a table of names to keys: `return { GEMINI_API_KEY = '...' }`.
-- Read on every call, so an edited file needs no restart.
local SRC = 'lua/genja/ext/secrets.lua: '

local M = {}

local FILE = vim.fn.stdpath('config') .. '/lua/genja/local/secrets.lua'

---Key `name` from secrets.lua, else $name; nil when neither has it.
---@param name string
---@return string|nil
function M.LocalOrEnv(name)
    if vim.fn.filereadable(FILE) == 1 then
        local ok, secrets = pcall(dofile, FILE)
        if not ok then
            vim.notify(SRC .. 'lua/genja/local/secrets.lua: ' .. tostring(secrets), vim.log.levels.WARN)
        elseif type(secrets) == 'table' and type(secrets[name]) == 'string' and secrets[name] ~= '' then
            return secrets[name]
        end
    end
    local env = vim.env[name]
    if env == nil or env == '' then
        return nil
    end
    return env
end

return M
