local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
-- local actions = require "telescope.actions"
-- local action_state = require "telescope.actions.state"

local log = require('genja.log').log



local M = { items = {} }

function M.add_item(n, fn, d) table.insert(M.items, { name = n, callback = fn, display = d }) end
function M.just_run(cmd, d) M.add_item(cmd, function() vim.cmd(cmd) end, d) end
function M.just_command(cmd, d) M.add_item(cmd, function() vim.api.nvim_command(cmd) end, d) end

-- from telescope.nvim/lua/telescope/builtin/__files.lua
local find_files = function(opts)
	local utils = require "telescope.utils"
	local make_entry = require "telescope.make_entry"
	local find_command = (function()
		if opts.find_command then
			if type(opts.find_command) == "function" then
				return opts.find_command(opts)
			end
			return opts.find_command
		elseif 1 == vim.fn.executable "rg" then     return { "rg", "--files", "--color", "never" }
		elseif 1 == vim.fn.executable "fd" then     return { "fd", "--type", "f", "--color", "never" }
		elseif 1 == vim.fn.executable "fdfind" then return { "fdfind", "--type", "f", "--color", "never" }
		elseif 1 == vim.fn.executable "find" and
			vim.fn.has "win32" == 0 then            return { "find", ".", "-type", "f" }
		elseif 1 == vim.fn.executable "where" then  return { "where", "/r", ".", "*" }
		end
	end)()

	if not find_command then
		-- utils.notify("builtin.find_files", {
		-- 	msg = "You need to install either find, fd, or rg",
		-- 	level = "ERROR",
		-- 	once = true,
		-- })
		vim.notify('you need to install either find, fd or rg', vim.log.levels.ERROR)
		return
	else
		vim.notify_once('finn command: ' .. table.concat(find_command, ' '), vim.log.levels.INFO)
	end

	local command = find_command[1]
	local hidden = opts.hidden
	local no_ignore = opts.no_ignore
	local no_ignore_parent = opts.no_ignore_parent
	local follow = opts.follow
	local search_dirs = opts.search_dirs
	local search_file = opts.search_file

	if search_dirs then
		for k, v in pairs(search_dirs) do
			search_dirs[k] = utils.path_expand(v)
		end
	end

	if command == "fd" or command == "fdfind" or command == "rg" then
		if hidden then
			find_command[#find_command + 1] = "--hidden"
		end
		if no_ignore then
			find_command[#find_command + 1] = "--no-ignore"
		end
		if no_ignore_parent then
			find_command[#find_command + 1] = "--no-ignore-parent"
		end
		if follow then
			find_command[#find_command + 1] = "-L"
		end
		if search_file then
			if command == "rg" then
				find_command[#find_command + 1] = "-g"
				find_command[#find_command + 1] = "*" .. search_file .. "*"
			else
				find_command[#find_command + 1] = search_file
			end
		end
		if search_dirs then
			if command ~= "rg" and not search_file then
				find_command[#find_command + 1] = "."
			end
			vim.list_extend(find_command, search_dirs)
		end
	elseif command == "find" then
		if not hidden then
			table.insert(find_command, { "-not", "-path", "*/.*" })
			find_command = flatten(find_command)
		end
		if no_ignore ~= nil then
			log.warn "The `no_ignore` key is not available for the `find` command in `find_files`."
		end
		if no_ignore_parent ~= nil then
			log.warn "The `no_ignore_parent` key is not available for the `find` command in `find_files`."
		end
		if follow then
			table.insert(find_command, 2, "-L")
		end
		if search_file then
			table.insert(find_command, "-name")
			table.insert(find_command, "*" .. search_file .. "*")
		end
		if search_dirs then
			table.remove(find_command, 2)
			for _, v in pairs(search_dirs) do
				table.insert(find_command, 2, v)
			end
		end
	elseif command == "where" then
		if hidden ~= nil then
			log.warn "The `hidden` key is not available for the Windows `where` command in `find_files`."
		end
		if no_ignore ~= nil then
			log.warn "The `no_ignore` key is not available for the Windows `where` command in `find_files`."
		end
		if no_ignore_parent ~= nil then
			log.warn "The `no_ignore_parent` key is not available for the Windows `where` command in `find_files`."
		end
		if follow ~= nil then
			log.warn "The `follow` key is not available for the Windows `where` command in `find_files`."
		end
		if search_dirs ~= nil then
			log.warn "The `search_dirs` key is not available for the Windows `where` command in `find_files`."
		end
		if search_file ~= nil then
			log.warn "The `search_file` key is not available for the Windows `where` command in `find_files`."
		end
	end

	if opts.cwd then
		opts.cwd = utils.path_expand(opts.cwd)
	end

	opts.entry_maker = opts.entry_maker or make_entry.gen_from_file(opts)

	local finn

	finn = pickers.new(opts, {
		prompt_title = (opts.cwd or vim.fn.getcwd()),
		finder = finders.new_oneshot_job(find_command, opts),
		previewer = conf.file_previewer(opts),
		sorter = conf.file_sorter(opts),
		attach_mappings = function(prompt_bufnr, map)
			require('genja.fn.telemap').Telemap(map)

			-- map({ 'i', 'n' }, '<F1>',  function()
				-- vim.cmd 'cd ..'
				-- print(vim.fn.getcwd())
				-- local act = require 'telescope.actions'
				-- act.close()
				-- finn:find()
			-- end)

			-- actions.select_default:replace(function()
				-- actions.close(prompt_bufnr)
				-- local selection = action_state.get_selected_entry()
				-- selection.value.callback()
			-- end)

			return true
		end,
	})

	finn:find()
end

local function finn_ivy(opts)
	local thm = {}
	thm = require('telescope.themes').get_ivy()
	Look = vim.tbl_deep_extend("force", thm, {
		previewer = false,
		layout_config = {
			height = function(_, max_column, max_lines)
				return math.max(max_lines-5, 35)
			end,
		},
	})
	Look = vim.tbl_deep_extend("force", Look, opts)
	find_files(Look)
end

M = require 'telescope'.register_extension {
	-- setup = function(o, _)
	-- 	opts = vim.tbl_extend('force', default_opts, o)
	-- end,
	exports = {
		-- finn = find_files,
		finn = finn_ivy
	},
}

return M
