-- Recent files picker from genja-recent (frecency), the current project first; switches
-- between this project (git root, else :pwd) and all files. Uses genja-finder's shared keys.

local SRC = 'lua/genja/ext/recent.lua: '

local M = {}

---Project root of the current buffer: git root of its dir (oil: the shown dir), else :pwd.
---@return string
local function project_root()
	local dir = nil
	if vim.bo.filetype == 'oil' then
		local ok, oil = pcall(require, 'oil')
		if ok then
			dir = oil.get_current_dir()
		end
	end
	local name = vim.api.nvim_buf_get_name(0)
	if not dir and name ~= '' and vim.bo.buftype == '' then
		dir = vim.fs.dirname(name)
	end
	if not dir then
		dir = vim.fn.getcwd()
	end
	local root = vim.fs.root(dir, '.git')
	if not root then
		root = vim.fn.getcwd()
	end
	return vim.fs.normalize(root)
end

---Open the picker.
---@param opts? { all?: boolean, root?: string } all: every recent file; root: kept by <M-a>
function M.open(opts)
	opts = opts or {}
	local root = opts.root
	if not root then
		root = project_root()
	end
	local list_opts = { root = root }
	local title = 'Recent: ' .. vim.fs.basename(root) .. '  <M-a> all'
	if opts.all then
		list_opts = {}
		title = 'Recent: all  <M-a> project'
	end
	local paths = require('genja-recent').list(list_opts)
	if #paths == 0 and not opts.all then
		vim.notify(SRC .. 'no recent files in ' .. root .. '; showing all')
		M.open({ all = true, root = root })
		return
	end

	local conf = require('telescope.config').values
	local actions = require('telescope.actions')

	local function picker(popts)
		require('telescope.pickers').new(popts, {
			prompt_title = title,
			finder = require('telescope.finders').new_table({
				results = paths,
				entry_maker = require('telescope.make_entry').gen_from_file(popts),
			}),
			sorter = conf.file_sorter(popts),
			previewer = conf.file_previewer(popts),
			attach_mappings = function(prompt_bufnr, map)
				map({ 'i', 'n' }, '<M-a>', function()
					actions.close(prompt_bufnr)
					M.open({ all = not opts.all, root = root })
				end, { desc = 'recent: this project / all files' })
				return true
			end,
		}):find()
	end
	require('genja-finder').enhance(picker)({})
end

return M
