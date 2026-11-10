-- JavaScript / TypeScript debugging through vscode-js-debug (Mason: js-debug-adapter, listed by
-- genja-completion011's lang/typescript.lua). Set up from the nvim-dap spec (lua/lazyp/debug/dap-php.lua)
-- when genja has typescript on. Same keys and UI as PHP (debug-ui.lua, debug-fkeys.lua).
--   Node: launch this file      node runs the current file (Node 23+ runs .ts files as they are)
--   Node: npm run dev           the dev script under the debugger, breakpoints in the server code
--   Node: attach                pick a process started with `node --inspect`
--   Chrome: localhost:5173      a Vite dev server (React, Vue, Svelte) in a new Chrome; :5173 asked first
local SRC = 'lua/genja/ext/debug-js.lua: '

local M = {}

local FILETYPES = { 'javascript', 'typescript', 'javascriptreact', 'typescriptreact', 'vue', 'svelte' }

---@param dap table require('dap')
function M.setup(dap)
	local server = vim.fs.joinpath(vim.fn.stdpath('data'), 'mason', 'packages', 'js-debug-adapter',
		'js-debug', 'src', 'dapDebugServer.js')
	if not vim.uv.fs_stat(server) then
		vim.notify(SRC .. 'js-debug-adapter not installed yet (:MasonToolsInstall)', vim.log.levels.WARN)
		return
	end
	-- node runs the server directly: libuv can't start Mason's .cmd wrapper on Windows
	for _, name in ipairs({ 'pwa-node', 'pwa-chrome' }) do
		dap.adapters[name] = {
			type = 'server',
			host = 'localhost',
			port = '${port}',
			executable = { command = 'node', args = { server, '${port}' } },
		}
	end

	---@type dap.Configuration[]
	local configs = {
		{
			type = 'pwa-node',
			request = 'launch',
			name = 'Node: launch this file',
			program = '${file}',
			cwd = '${workspaceFolder}',
			sourceMaps = true,
		},
		{
			type = 'pwa-node',
			request = 'launch',
			name = 'Node: npm run dev',
			runtimeExecutable = 'npm',
			runtimeArgs = { 'run', 'dev' },
			cwd = '${workspaceFolder}',
			console = 'integratedTerminal',
			sourceMaps = true,
		},
		{
			type = 'pwa-node',
			request = 'attach',
			name = 'Node: attach',
			processId = function() return require('dap.utils').pick_process() end,
			cwd = '${workspaceFolder}',
			sourceMaps = true,
		},
		{
			type = 'pwa-chrome',
			request = 'launch',
			name = 'Chrome: localhost (dev server)',
			url = function()
				local port = vim.fn.input('dev server port: ', '5173')
				if port == '' then
					port = '5173'
				end
				return 'http://localhost:' .. port
			end,
			webRoot = '${workspaceFolder}',
			sourceMaps = true,
		},
	}
	for _, ft in ipairs(FILETYPES) do
		dap.configurations[ft] = configs
	end
end

return M
