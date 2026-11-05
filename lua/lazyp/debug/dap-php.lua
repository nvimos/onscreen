--[[
PHP debugging with Xdebug.

Mason installs php-debug-adapter (lang/php.lua lists it). Run it with node
directly, since libuv can't start Mason's .cmd wrapper on Windows.

The PHP adapter is only set up when PHP is enabled in genja (genja.lsp.enabled()).

Xdebug must be on in PHP with xdebug.mode=debug and xdebug.start_with_request=yes
(Local: site > Tools > Xdebug). Then <leader>dc starts "Listen for Xdebug" and the
next request stops at your breakpoints. Local runs PHP on Windows itself, so the
paths match and need no pathMappings.

DDEV in WSL (Docker inside the distro, nvim on Windows): `ddev xdebug on`. With mirrored
networking host.docker.internal doesn't resolve in the container (2026-11-05), so DDEV's
xdebug_ide_location must be the Windows LAN IP (needs hostAddressLoopback=true in .wslconfig;
the Windows firewall asks to allow node). <leader>dc warns when it isn't; :DdevXdebugHost sets
it (lua/genja/ext/debug-ddev.lua). /var/www/html maps to the folder holding .ddev. Test session:
todo-test/php-debug.md.

Session UI and keys: lua/genja/ext/debug-ui.lua (auto-open, tab or split),
lua/genja/ext/debug-fkeys.lua (! flips F1-F8).
--]]
local SRC = 'lua/lazyp/debug/dap-php.lua: '
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
			---DDEV serves the project from /var/www/html; map it to the folder holding .ddev, written
			---the way nvim names the buffer (on Windows \\wsl.localhost\<distro>\...), so breakpoints match.
			---Without .ddev: no mappings, the paths are the same (PHP on Windows).
			---@return table<string, string>|nil
			local function ddev_mappings()
				local root = vim.fs.root(0, '.ddev')
				if not root then
					return nil
				end
				if vim.fn.has('win32') == 1 then
					root = root:gsub('/', '\\')
				end
				return { ['/var/www/html'] = root }
			end

			---@type dap.Configuration[]
			dap.configurations.php = {
				{
					type = 'php',
					request = 'launch',
					name = 'Listen for Xdebug',
					port = 9003,
					pathMappings = ddev_mappings,
				},
			}
		end

		local has_dapui, dapui = pcall(require, 'dapui')
		if has_dapui then
			dapui.setup()
		end

		vim.fn.sign_define('DapBreakpoint',          { text = '●', texthl = 'DiagnosticSignError' })
		vim.fn.sign_define('DapBreakpointCondition', { text = '◆', texthl = 'DiagnosticSignError' })
		vim.fn.sign_define('DapLogPoint',            { text = '◇', texthl = 'DiagnosticSignInfo' })
		vim.fn.sign_define('DapBreakpointRejected',  { text = '○', texthl = 'DiagnosticSignHint' })
		vim.fn.sign_define('DapStopped',             { text = '▶', texthl = 'DiagnosticSignWarn', linehl = 'CursorLine' })

		local dap = require('dap')
		local ui = require('genja.ext.debug-ui')
		local fkeys = require('genja.ext.debug-fkeys')

		dap.listeners.after.event_initialized['genja'] = function(session)
			fkeys.arm()
			local port = session.config.port
			vim.notify(SRC .. 'debug session started' .. (port and (', listening on port ' .. port) or '') .. '; ! flips the F-keys')
		end
		dap.listeners.before.event_stopped['genja'] = ui.on_stopped
		local function ended()
			ui.close()
			fkeys.disarm()
		end
		dap.listeners.before.event_terminated['genja'] = ended
		dap.listeners.before.event_exited['genja'] = ended

		vim.api.nvim_create_user_command('DdevXdebugHost', function()
			require('genja.ext.debug-ddev').set_host(vim.api.nvim_get_current_buf())
		end, { desc = 'DDEV: send Xdebug to this machine (restart project, Xdebug on)' })
		vim.api.nvim_create_user_command('DebugCli', function(cmd)
			require('genja.ext.debug-ddev').run(vim.api.nvim_get_current_buf(), cmd.fargs)
		end, { nargs = '+', desc = 'Debug: ddev exec <args> under the debugger' })
		vim.api.nvim_create_user_command('DebugBehat', function(cmd)
			require('genja.ext.debug-ddev').behat(vim.api.nvim_get_current_buf(), cmd.fargs)
		end, { nargs = '*', desc = 'Debug: Behat in DDEV (args, or the current .feature) under the debugger' })
	end,
}
