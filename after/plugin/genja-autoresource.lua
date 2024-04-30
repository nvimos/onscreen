--[[ 
	genja-autoresource: always reload lua init-files on safe

	setup({

	})
]]

local pats = {}
local genja = vim.fn.readdir(vim.fn.stdpath('config')..'/lua/genja/', 'v:val =~ "\\.lua$"') -- init.lua, opt.lua, ...
local after = vim.fn.readdir(vim.fn.stdpath('config')..'/after/plugin/', 'v:val =~ "\\.lua$"')

vim.list_extend(pats, genja)
vim.list_extend(pats, after)

vim.api.nvim_create_autocmd('BufWritePost', {
	group = vim.api.nvim_create_augroup('conf-reload', { clear = true }),
	pattern = pats,
	callback = function(ev)
		local fname = vim.fn.fnamemodify(ev.match, ':t')
			vim.g.genja_resource = "1"
			if not vim.g.source_safeish then -- flag to turn it off
				return
			end
			vim.g.genja_resource = "2"

			-- xpcall(
			-- 	function() error('error message') end,
			-- 	function(err) print(debug.traceback(err))a
			-- 	end)

			local status, err = pcall(vim.cmd, [[source ]]..ev.match)
			if not status then
				vim.g.genja_resource = "FAIL"
				-- err = vim.inspect(err)
				err = err or "?{?}?"
				vim.api.nvim_err_writeln(string.format("Failed to re-source «%s»", ev.match))
				vim.api.nvim_err_writeln( debug.traceback(err))

				-- for i, e in pairs(vim.split(err, "\n")) do
				-- 	vim.api.nvim_err_writeln(e)
				-- end
				-- print(string.format("psource(%s):\n%s", ev.match, err))
			end
			vim.g.genja_resource = "SUCC: " .. ev.match
	end
})


--[[ v1 ]]
-- vim.api.nvim_create_autocmd('BufWritePost', {
-- 	group = vim.api.nvim_create_augroup('conf-reload', { clear = true }),
-- 	pattern = pats,
-- 	callback = function(ev)
-- 		local safeish = { [''] = false }
-- 		local _safeish =  {
-- 			'zexp.lua' ,
-- 			'map.lua' ,
-- 			'init-map.lua',
-- 			'init.lua',
-- 			'fn.lua',
-- 			'opt.lua' ,
-- 			'alias.lua',
-- 			'auto.lua',
-- 			'winbar.lua',
-- 			'hilite.lua', }
-- 		for _, e in ipairs(_safeish) do safeish[e] = true end
-- 		local fname = vim.fn.fnamemodify(ev.match, ':t')
-- 			vim.g.genja_resource = "0"
-- 		if safeish[fname] then
-- 			vim.g.genja_resource = "1"
-- 			if not vim.g.source_safeish then -- flag to turn it off
-- 				return
-- 			end
-- 			vim.g.genja_resource = "2"
-- 			local status, err = pcall(vim.cmd, [[source ]]..ev.match)
-- 			if not status then
-- 				vim.g.genja_resource = "FAIL"
-- 				err = vim.inspect(err)
-- 				err = err or "?{?}?"
-- 				print(string.format("psource(%s):\n%s", ev.match, err))
-- 			end
-- 			vim.g.genja_resource = "SUCC"
-- 		else
-- 			vim.g.genja_resource = "not-safe:«"..fname.."» file:«".. ev.match .."»"
-- 		end
-- 	end
-- })
