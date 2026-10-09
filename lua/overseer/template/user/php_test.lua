-- lua/overseer/template/user/php_test.lua
-- Shared by php_test_file and php_test_all: the project's pest, else phpunit.

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

---@param name string
---@param args fun(): string[]
function M.template(name, args)
	return {
		name = name,
		builder = function()
			local runner, root = M.runner()
			return {
				cmd = vim.list_extend({ runner }, args()),
				cwd = root,
				components = {
					{ 'on_output_quickfix', open_on_exit = 'failure' },
					'default',
				},
			}
		end,
		condition = {
			filetype = { 'php' },
			callback = function()
				return M.runner() ~= nil
			end,
		},
	}
end

return M
