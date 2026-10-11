-- lua/overseer/template/user/php_test.lua
-- Shared by php_test_file and php_test_all: the project's pest, else phpunit.
-- Not a template itself: disabled in lua/lazyp/maybe/overseer.lua.

local M = {}

---@return string?, string? runner, project root
function M.runner()
	local root = vim.fs.root(0, { 'composer.json' })
	if not root then
		return
	end
	local ext = vim.fn.has('win32') == 1 and '.bat' or ''
	for _, name in ipairs({ 'pest', 'phpunit' }) do
		local path = vim.fs.joinpath(root, 'vendor', 'bin', name .. ext)
		if vim.uv.fs_stat(path) then
			return path, root
		end
	end
end

---A provider, so the task is only offered when a runner exists (v2 dropped condition.callback).
---@param name string
---@param args fun(): string[]
---@return overseer.TemplateFileProvider
function M.template(name, args)
	return {
		condition = { filetype = { 'php' } },
		generator = function()
			local runner, root = M.runner()
			if not runner then
				return 'no vendor/bin/pest or vendor/bin/phpunit'
			end
			---@type overseer.TemplateDefinition
			local tmpl = {
				name = name,
				builder = function()
					return {
						cmd = vim.list_extend({ runner }, args()),
						cwd = root,
						components = {
							{ 'on_output_quickfix', open_on_exit = 'failure' },
							'default',
						},
					}
				end,
			}
			return { tmpl }
		end,
	}
end

return M
