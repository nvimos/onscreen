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

-- M.log = require("plenary.log").new({
-- 	level = derive_log_level(),
-- 	plugin = M.log_name,
-- })

---@return string path of the log file
M.where = function()
	local ca = vim.api.nvim_call_function("stdpath", { "cache" })
	local log = M.log_name.. ".log"
	return JoinPaths(ca, log)
end

M.nuke = function()
	os.remove(M.where())
end

---@param name string plugin name for plenary.log
M.init = function(name)

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


	M.log_name = name
	M.log = require("plenary.log").new({
		level = derive_log_level(),
		plugin = name,
	})

	local function override(key)
		local log_key = os.time()
		local fn = M.log[key]
		M.log[key] = function(...)
			if fn then
				fn(log_key, ...)
			end
		end
	end

	for _, v in pairs(log_levels) do
		override(v)
	end
end


-- function M.get_log_key()
    -- return log_key
-- end



-- @prop log{ trace debug info warn error fatal }
return M
