--[[
PHP debugging with Xdebug.

Mason installs php-debug-adapter (lang/php.lua lists it). Run it with node
directly, since libuv can't start Mason's .cmd wrapper on Windows.

The PHP adapter is only set up when PHP is enabled in genja (genja.lsp.enabled()).

Xdebug must be on in PHP with xdebug.mode=debug and xdebug.start_with_request=yes
(Local: site > Tools > Xdebug). Then <leader>dc starts "Listen for Xdebug" and the
next request stops at your breakpoints. Local runs PHP on Windows itself, so the
paths match and need no pathMappings.
--]]
local Maps = require('genja.map-plugin')

---@type LazySpec
return {
	'mfussenegger/nvim-dap',
	ft = 'php',
	keys = Maps:keys(),
	config = function()
		-- PHP adapter only when genja has PHP on (config.lua, setup() opts or local.lua).
		local ok, genja = pcall(require, 'genja.lsp')
		if ok and genja.enabled('php') then
			local dap = require('dap')
			local adapter = vim.fs.joinpath(vim.fn.stdpath('data'), 'mason', 'packages',
				'php-debug-adapter', 'extension', 'out', 'phpDebug.js')

			---@type dap.ExecutableAdapter
			dap.adapters.php = {
				type = 'executable',
				command = 'node',
				args = { adapter },
			}
			---@type dap.Configuration[]
			dap.configurations.php = {
				{
					type = 'php',
					request = 'launch',
					name = 'Listen for Xdebug',
					port = 9003,
				},
			}
		end

		local has_dapui, dapui = pcall(require, 'dapui')
		if has_dapui then
			dapui.setup()
		end
	end,
}
