

  -- elseif vim.fn.has("win32") == 1 then
  --   if vim.fn.executable("rundll32") == 1 then
  --     return { "rundll32", "url.dll,FileProtocolHandler", path }
  --   else
  --     return nil, "rundll32 not found"
  --   end

local F = {}
local O = {}

local VisualLine = 'V'
local UserComm = vim.api.nvim_create_user_command


F.vlc_rar = function()
	local _, _, path = F.oil_entry_dir_path()
	os.execute(Join({
		'start',
		"A:\\bin\\7z-extract-tmp.bat",
		path:gsub("%.r%d%d", ".rar")
	}, ' '))
end

F.cd_to_entry = function()
	local _, _, path = F.oil_entry_dir_path()
	if not IsDir(path) then
		path = Dirname(path)
	end
	vim.cmd('cd '..path)
end




F.rate_on_movielens = function()
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

F.oil_entry_dir_path = function()
	local entry = require('oil').get_cursor_entry()
	local dir = require('oil').get_current_dir()
	local path = JoinPaths(dir, entry.name)
	return entry, dir, path
end


function escpath(p, qq)
	local q = '"'
	p = p:gsub("\"", "\\\"")

	if qq then return q..p..q end
	return p
end

local function executable(...)
	local paths = {...}
	for _, path in pairs(paths) do
		if vim.fn.executable(path) then
			return path
		end
	end
	for _, path in pairs(paths) do
		return path
	end
	return ""
end

F.open_in_vlc = function()
	local _, _, path = F.oil_entry_dir_path()
	local vlc  = executable([[C:\Program Files\VideoLAN\VLC\vlc.exe]])
	local cmd = { 'start', '"play-file"', '/I',
		escpath(vlc, 1),
		escpath(path, 1) }
	local z = Join(cmd, ' ')
	local e = os.execute(z)
	if e ~= 0 then
		F.open_in_explorer()
	end
end


F.open_in_explorer = function()
	local _, _, path = F.oil_entry_dir_path()
	if IsDir(path) then
		os.execute('explorer.exe '..path)
	else
		os.execute('explorer.exe '..Dirname(path))
	end
end

F.open_via_shell = function()
	local get_open_cmd = function(path)
		if false then
		elseif 1 == vim.fn.has("mac")  then return { "open", path }
		elseif 1 == vim.fn.executable("explorer.exe") then return { "explorer.exe", path }
		elseif 1 == vim.fn.executable("xdg-open") then return { "xdg-open", path }
		else return nil, "no handler found"; end
	end
	local entry, dir, path = F.oil_entry_dir_path()
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
end


F.move_to_cat_delete = function()
	local pos = vim.api.nvim_win_get_cursor(0)
	MoveCat(function()
		-- move cursor back to where it was after reloading
		-- maybe there is oil-reload?
		vim.cmd ([[edit ]]..vim.fn.expand('%'))
		local timer = vim.loop.new_timer()
		timer:start(1000, 0, vim.schedule_wrap(function()
			vim.api.nvim_win_set_cursor(0, pos)
		end))

	end, { default_text = "_del" })

end


F.move_to_cat = function()
	local pos = vim.api.nvim_win_get_cursor(0)
	MoveCat(function()
		-- move cursor back to where it was after reloading
		-- maybe there is oil-reload?
		vim.cmd ([[edit ]]..vim.fn.expand('%'))
		local timer = vim.loop.new_timer()
		timer:start(1000, 0, vim.schedule_wrap(function()
			vim.api.nvim_win_set_cursor(0, pos)
		end))

	end)
end

F.select_custom = function()
	local entry, _, _ = F.oil_entry_dir_path()
	local ext = Extensionname(entry.name)
	if false then
	elseif 'rar' == ext or ext:match('r[a%d][r%d]$') then
		vim.cmd[[ OilVlcRar ]]
	elseif IsVideoExtension(ext) then
		-- F.open_in_explorer()
		F.open_in_vlc() -- broken, must open in some special way
	elseif IsPictureExtension(ext) then
		F.open_in_explorer()
	else
		require('oil.actions').select.callback()
	end
end



local function get_oil_entries()
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
	else
		local m = F.entry_from_oil(d, oil.get_cursor_entry())
		table.insert(oil_entries, m)
	end
	-- local meta_files = {}
	for _,e in pairs(oil_entries) do
		local stat = vim.loop.fs_stat(e.path)
		if stat ~= nil then
			local pat = e.path..'*.{finished,torrent}'
			for _, mf in pairs(vim.fn.glob(pat, false, true)) do
				-- table.insert(meta_files, F.entry_from_path(mf))
				table.insert(oil_entries, F.entry_from_path(mf))
			end
		end
	end
	return oil_entries
end

function MoveCat( afterFn, opts)
	local op = {
		afterFn = afterFn,
		movees = get_oil_entries(),
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
		input = '',
		dirs = {
			-- [[Q:\audio-balmora\musikkkk]],
			-- [[Q:\audio-balmora\muzica]],
			[[V:\]] -- cinema
		}
	}
	op = vim.tbl_extend('force', op, opts)
	vim.notify("MoveCat() op.default_text = " .. op.default_text)
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
	if vim.fn.executable('rundll32') == 1 then
		cmd = { 'rundll32', 'url.dll,FileProtocolHandler', url }
	end
	local jid = vim.fn.jobstart(cmd, { detach = false })
	assert(jid > 0, 'jobstart() err: '.. vim.inspect(cmd))
end

function F.open_in_shell(url)
	local cmd = { 'xdg-open', url }
	if vim.fn.executable('rundll32') == 1 then
		cmd = { 'rundll32', 'shell32.dll,ShellExec_RunDLL', url }
	end
	local jid = vim.fn.jobstart(cmd, { detach = false })
	assert(jid > 0, 'jobstart() err: '.. vim.inspect(cmd))
end


O.vote_movielens = { desc = "Rate on movielens",    callback = F.rate_on_movielens }
O.open_explorer = {  desc = "Open dir in explorer", callback = F.open_in_explorer }
O.open_external = {  desc = "Open (shell)",         callback = F.open_via_shell }
O.move_category = {  desc = "Move to _category",    callback = F.move_to_cat }
O.move_category_delete = {  desc = "Move to _delete",    callback = F.move_to_cat_delete }
O.select_custom = {  desc = "Select (custom)",      callback = F.select_custom }


UserComm('OilVlcRar',   F.vlc_rar    , { desc = 'open rar in vlc (extract to c:/tmp)' })
UserComm('OilCd2Entry', F.cd_to_entry, { desc = 'cd to entry' })

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
				['ge'] = O.open_explorer,
				['gX'] = O.open_external,
				['<LocalLeader>x'] = O.open_external,
				['<LocalLeader>e'] = O.open_explorer,
				['<LocalLeader>,'] = O.vote_movielens,
				['<localleader>j'] = O.move_category,

				['ze'] = O.open_explorer,
				['za'] = O.open_external,
				['zr'] = O.vote_movielens,
				['zj'] = O.move_category,

				['<C-j>'] = O.move_category,
				['<C-q>'] = O.move_category_delete, -- on windows

				['}'] = '3j',
				['{'] = '3k',

				['se'] = O.open_explorer,
				['sa'] = O.open_external,
				['sr'] = O.vote_movielens,
				['ss'] = O.move_category,
				['sj'] = O.move_category,
				['<CR>'] = O.select_custom,
				['<cr>'] = O.select_custom,
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
