CONFIG = vim.fn.stdpath('config')



function Myleige(g, l)
	vim.g.mapleader      = g or [[\]]
	vim.g.maplocalleader = l or [[ ]]
end

local UserComm = vim.api.nvim_create_user_command

function Cd(to) vim.api.nvim_call_function("chdir", { to }); vim.cmd[[pwd]] end


UserComm( 'Winfo', function(c) 
	local zzz = vim.api.nvim_get_current_buf()
	-- print(vim.api.nvim_buf_get_name(z))


	-- print(vim.inspect(vim.bo.fenc))
	--print(vim.inspect(vim.bo.filetype))

	info = {}
	info.name = vim.fn.bufname()
    info.modified = vim.fn.getbufvar(0, "&modified") == 1
    info.modified_count = vim.fn.getbufvar(0, "&mod") 
    info.line_count = vim.fn.line("$")
    info.filetype = vim.bo.filetype
    info.encoding = vim.bo.fenc
	-- :::nvim_buf_get_var
	print(vim.inspect(info))

end, { desc = 'gather info about current window/buffer' })


UserComm( 'Nospell',  function(c) vim.o.spell = not vim.o.spell end,              { desc = "toggle spelling" , bar = true })
UserComm( 'VimStatusline',  function(c) return 'VimStatusline()' end,              { desc = "just a meme" , bar = true })


-- complete = function() return {'a', 'x', 'c'} end
UserComm( 'Woot', function(c) print(vim.inspect(c)) end, { nargs = '?', force = true, desc = "What is a function?"  })
UserComm( 'Woot', function(c) print(vim.inspect(c)) end, { nargs = '*', force = true, desc = "What is a function?", bar = true  })

function Close_nerdtree_wins() -- <space> ee | e. | et
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		local ft = vim.api.nvim_buf_get_option(buf, 'filetype')
		if ft == 'nerdtree' then
			vim.api.nvim_win_close(win, true)
		end
	end
end

function CheckAndRunMRU() -- <S-F1>
    if vim.bo.filetype == "mru" then vim.cmd("quit")
    else
		-- os.execute("A:\\bin\\uniq-vim-mru-files.exe")
		-- vim.cmd("MRU")
		vim.fn.jobstart("A:\\bin\\uniq-vim-mru-files.exe", {
			on_exit = function()
				vim.cmd("MRU")
			end
		}) 
	end
end

UserComm('CycleDirs', function() CycleDirs() end, {})
UserComm('CDconfig',  function() Cd(vim.fn.stdpath('config')) end,                { desc = "cd stdpath(config)" , bar = true })
UserComm('CDconfigg', function() Cd(vim.fn.stdpath('config')..'/lua/genja') end, { desc = "cd ()/lua/genja" , bar = true })
UserComm('CD',        function(c) Cd(c.fargs) end,                                { nargs = '*', desc = "cd ?" , bar = true })


--[[ from help, other people, etc ]]--

UserComm('HiTest', function() vim.cmd [[:so $VIMRUNTIME/syntax/hitest.vim]] end, {})

--[[ roll your own ]]--
local _cdp = 1
function CycleDirs(dirlist)
	dirlist = dirlist or START_DIRS
	Cd(dirlist[_cdp]); _cdp = _cdp + 1;
	if _cdp > #dirlist then
		_cdp = 1; end end

function is_started_from_windows_shell()
	return [[nvim.exe]] == vim.fn.readdir( '.', [[v:val =~ 'nvim.exe$']])
	                [1] end
