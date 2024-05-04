-- Don't include this file, we should manually include it via
-- require("harpoon.dev").reload();
--
-- A quick mapping can be setup using something like:
-- :nmap <leader>rr :lua require("harpoon.dev").reload()<CR>
local M = {}
M.log_name = "genja"

function M.reload()
    require("plenary.reload").reload_module("genja.log")
end

local log_levels = { "trace", "debug", "info", "warn", "error", "fatal" }
local function derive_log_level()
    local env_level = vim.env.GENJA_LOG or vim.g.genja_log_level
    for _, level in pairs(log_levels) do
        if level == env_level then
            return env_level
        end
    end
    return "warn" -- default, if user hasn't set to one from log_levels
end


M.log = require("plenary.log").new({
	level = derive_log_level(),
	plugin = M.log_name,
})

local log_key = os.time()
function M.get_log_key()
    return log_key
end

local function override(key)
    local fn = M.log[key]
    M.log[key] = function(...)
        fn(log_key, ...)
    end
end
for _, v in pairs(log_levels) do
    override(v)
end

-- @prop log{ trace debug info warn error fatal }
return M
