

  -- elseif vim.fn.has("win32") == 1 then
  --   if vim.fn.executable("rundll32") == 1 then
  --     return { "rundll32", "url.dll,FileProtocolHandler", path }
  --   else
  --     return nil, "rundll32 not found"
  --   end

local F = {}

local VisualLine = 'V'

local vote_movielens = {
	desc = "Rate on movielens",
	callback = function()
		local oil_entries = {}
		local ok, oil = pcall(require, 'oil')
		if ok then
			if VisualLine == vim.fn.mode() then
				local buf = vim.api.nvim_get_current_buf()
				local a, b = F.visual_line_range()
				for i = a, b do
					local m = F.entry_from_oil(oil.get_current_dir(), oil.get_entry_on_line(buf, i))
					table.insert(oil_entries, m)
				end
			else
				local m = F.entry_from_oil(oil.get_current_dir(), oil.get_cursor_entry())
				table.insert(oil_entries, m)
			end
		end
		if ok and #oil_entries > 0 then
			for _, e in pairs(oil_entries) do
				local name = StripSceneTags(e.name)
				F.open_in_browser('https://movielens.org/explore?q='..name)
			end
		end
	end
}

F.oil_edp = function()
	local entry = require('oil').get_cursor_entry()
	local dir = require('oil').get_current_dir()
	local path = JoinPaths(dir, entry.name)
	return entry, dir, path
end

local open_explorer = {
	desc = "Open dir in explorer",
	callback = function()
		local _, _, path = F.oil_edp()
		if IsDir(path) then
			os.execute('explorer.exe '..path)
		else
			os.execute('explorer.exe '..Dirname(path))
		end
	end
}
local open_external = {
	desc = "Open (shell)",
	callback = function()
		local get_open_cmd = function(path)
			if false then
			elseif 1 == vim.fn.has("mac")  then return { "open", path }
			elseif 1 == vim.fn.executable("explorer.exe") then return { "explorer.exe", path }
			elseif 1 == vim.fn.executable("xdg-open") then return { "xdg-open", path }
			else return nil, "no handler found"; end
		end
		local entry, dir, path = F.oil_edp()
		if not entry or not dir then
			return
		end
		local cmd, err = get_open_cmd(path)
		if not cmd then
			vim.notify(string.format("Could not open %s: %s", path, err), vim.log.levels.ERROR)
			return
		end
		if IsDir(path) then
			os.execute(Join(cmd, ' ')) -- jobstart explorer does not work for some reason.
		else
			-- TODO use vim.ui.open once this is resolved
			-- https://github.com/neovim/neovim/issues/24567
			local jid = vim.fn.jobstart(cmd, { detach = false }) -- original is "true"
			assert(jid > 0, "Failed to start job")
		end
	end,
}

local move_category = {
	desc = "Move to _category",
	callback = function()
		local my_pos = vim.fn.line('.') - 1
		MoveCat(function()
			vim.cmd ([[edit ]]..vim.fn.expand('%'))
			vim.cmd (':'..(my_pos))
		end)
	end
}

local select_custom = {
	desc = "Select (custom)",
	callback = function()
		local entry, _, _ = F.oil_edp()
		if false then
		elseif IsVideoExtension(Extensionname(entry.name)) then
			open_external.callback()
		-- elseif IsDir(path) then require('oil.actions').select.callback()
		else
			require('oil.actions').select.callback()
		end
	end
}


function MoveCat( afterFn )
	local oil = require('oil')
	local d = oil.get_current_dir()
	local oil_entries = {}
	if VisualLine == vim.fn.mode() then
		local buf = vim.api.nvim_get_current_buf()
		local a, b = F.visual_line_range()
		for i = a, b do
			local m = F.entry_from_oil(d, oil.get_entry_on_line(buf, i))
			table.insert(oil_entries, m)
		end
	-- elseif VisualBlock == ...
		-- local l0 = vim.fn.line("'<")
		-- local lN = vim.fn.line("'>")
		-- local _, lA, _, _ = vim.fn.getpos("'<")
		-- local _, lB, _, _ = vim.fn.getpos("'>")
	else
		local m = F.entry_from_oil(d, oil.get_cursor_entry())
		table.insert(oil_entries, m)
	end
	local meta_files = {}
	for _,e in pairs(oil_entries) do
		local stat = vim.loop.fs_stat(e.path)
		if stat ~= nil then
			local pat = e.path..'*.{finished,torrent}'
			for _, mf in pairs(vim.fn.glob(pat, false, true)) do
				table.insert(meta_files, F.entry_from_path(mf))
			end
		end
	end
	for _, fentry in ipairs(meta_files) do
		table.insert(oil_entries, fentry)
	end
	local op = {
		afterFn = afterFn,
		movees = oil_entries,
		pats = {
			-- [[-*]],
			-- [[-*/_*]],
			-- [[-*/*/_*]],
			[[%d+%-*]],
			[[%d+%-*/_*]],
			[[%d+%-*/*/_*]],
			[[_*]],
			[[_*/_*]],
		},
		dirs = {
			-- [[Q:\audio-balmora\musikkkk]],
			-- [[Q:\audio-balmora\muzica]],
			[[V:\]] -- cinema
		}
	}
	require('telescope').extensions.undersort.undersort(op)
end

F.entry_from_path = function(path)
	local dirname = vim.fn.fnamemodify(path:gsub('/$', ''), ':h')
	local basename = vim.fn.fnamemodify(path:gsub('/$', ''), ':t')
	local stat = vim.loop.fs_stat(path)
	return {
		dir = dirname,
		name = basename,
		path = JoinPaths(dirname, basename),
		stat = stat,
		size = stat.size,
		type = stat.type,
	}
end
F.entry_from_oil = function(d, e)
	return {
		dir = d,
		name = e.name,
		path = JoinPaths(d, e.name),
		stat = e.meta.stat,
		size = e.meta.stat.size,
		type = e.meta.stat.type,
	}
end

function F.visual_line_range()
	local v,c = vim.fn.line("v") , vim.fn.line(".")
	local a,b = v,c
	if c < v then
		a,b = c,v
	end
	return a, b
end

function F.open_in_browser(url)
	local cmd = { 'xdg-open', url }
	if vim.fn.executable("rundll32") == 1 then
		cmd = { 'rundll32', 'url.dll,FileProtocolHandler', url }
	end
	local jid = vim.fn.jobstart(cmd, { detach = false })
	assert(jid > 0, 'jobstart() err: '.. vim.inspect(cmd))
end


return {
	{	'stevearc/oil.nvim', event = 'UIEnter',
		cmd = 'Oil',
		-- keymaps = {
		-- 	{ "gX", nil },
		-- 	{ '<LocalLeader>x', nil },
		-- 	{ '<LocalLeader>,', nil },
		-- 	{ '<localleader>j', nil },
		-- },
		opts = {
			skip_confirm_for_simple_edits = true,

			float = {
				-- Padding around the floating window
				padding = 4,
				max_width = 0,
				max_height = 0,
				border = "rounded",
				win_options = {
					winblend = 0,
				},
				-- This is the config that will be passed to nvim_open_win.
				-- Change values here to customize the layout
				override = function(conf)
					return conf
				end,
			},

			keymaps = {
				['ge'] = open_explorer,
				['gX'] = open_external,
				['<LocalLeader>x'] = open_external,
				['<LocalLeader>e'] = open_explorer,
				['<LocalLeader>,'] = vote_movielens,
				['<localleader>j'] = move_category,

				['ze'] = open_explorer,
				['za'] = open_external,
				['zr'] = vote_movielens,
				['zj'] = move_category,

				['se'] = open_explorer,
				['sa'] = open_external,
				['sr'] = vote_movielens,
				['ss'] = move_category,
				['sj'] = move_category,
				['<cr>'] = select_custom,
			},
			win_options = {
				wrap = false,
				signcolumn = "yes",
				cursorcolumn = false,
				foldcolumn = "2",
				spell = false,
				list = false,
				conceallevel = 3,
				concealcursor = "nvic",
			},
			default_file_explorer = true, -- instead of netrw
			columns = {
				"size",
				{ "icon", add_padding = false}, },


			}, dependencies = { "nvim-tree/nvim-web-devicons" }, }
		}
