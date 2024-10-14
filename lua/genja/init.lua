-- Genja init for nvim
--
vim.cmd 'colorscheme lunaperche'
--
vim.o.guifont        = 'Cascadia Code Light:h14:l'
vim.g.mapleader      = ' '
vim.g.maplocalleader = ','

Safeload             = require('genja.fn').Safeload

Safeload 'genja.map-zero' -- stable early maps, if config breaks
Safeload 'genja.opt'      -- just static options

Safeload 'genja.env'
Safeload 'genja.fu' -- userfuncs
Safeload 'genja.ft' -- filetypes

--[[
Safeload 'genja.fn' ]]

-- require 'genja.fn'.win_chdir_home() -- if started on windows, cd to ~

vim.cmd(
	(function(c)
		return Join({
				'source %s/lua/genja/auto-alias.vim', -- aliases, onliners, autocommads, abbreviations
				'source %s/lua/genja/hilite.vim', -- colors
				'source %s/lua/genja/fn.vim' }, '\n')
			:format(c, c, c)
	end)(vim.fn.stdpath('config')))

C = vim.fn.stdpath('config')
vim.cmd('source ' .. C .. '/lua/genja/auto-alias.vim') -- aliases, onliners, autocommads, abbreviations
vim.cmd('source ' .. C .. '/lua/genja/hilite.vim')  -- colors
vim.cmd('source ' .. C .. '/lua/genja/fn.vim')


Safeload('genja.hilite', function(m) m.setup() end)
Safeload 'genja.auto' -- autocommads
Safeload 'genja.lazy' -- genja/lazy.lua -> import { lazyp }
Safeload 'genja.map-lsp'
Safeload 'genja.map-telescope'
Safeload 'genja.map-convoluted'

START_DIRS = (function() -- Telescope_find_dirs() looks in predefined locations
	local sd = {}
	local function Norm(p)
		local s, _ = p:gsub('\\', '/'); return s
	end
	local function InsertDir(e) if IsDir(e) then table.insert(sd, Norm(e)) end end
	local function add_dir(e) InsertDir(e) end
	local home = function(p)
		local h = vim.env.Userprofile or vim.env.HOME;
		return (h .. ('/' .. (p or '')))
	end

	add_dir(home())

	local openmw = false
	local movies = false

	if vim.fn.has('Windows') then
		add_dir('J:/notes')
		add_dir('A:/workspace')
		add_dir('A:/_setup/bootstrap')
		add_dir(home('Hj/notes'))

		add_dir('O:')

		if openmw then
			table.insert(sd, '--- (morrowind)')
			add_dir('C:/Games/Openmw.DataFilesExamples')
			add_dir('C:/Games/OpenMW.master')
			add_dir('C:/Games')
			add_dir(home('Documents/my games/OpenMW'))
			add_dir(home('AppData/Roaming/Vortex/morrowind/mods'))
			add_dir('J:/notes/gaming/morrowind')
		end

		if movies then
			table.insert(sd, '--- (movies)')
			add_dir('P:/cinema')
			add_dir('P:/backup/lin/balmora-2023.files/Base/home/jaroslav')
			add_dir('P:/cinema')
			add_dir('V:')
		end
		-- table.insert(sd, '---')
		-- add_dir('J:/bin')
		-- add_dir('J:/reference')
	end

	add_dir(vim.fn.stdpath('config'))
	add_dir(vim.fn.stdpath('data'))
	return sd
end)()

--
-- function append_to_buffer_end(text)
-- 	vim.api.nvim_buf_set_lines(
-- 		vim.api.nvim_get_current_buf(),
-- 		vim.api.nvim_buf_line_count(vim.api.nvim_get_current_buf()),
-- 		-1,
-- 		false,
-- 		{text}
-- 	)
-- end
-- append_to_buffer_end('LOADED')


--[[
	Inspiration
	- https://github.com/folke/lazy.nvim
	- https://github.com/ThePrimeagen/init.lua

	Docs
	- https://jacobsimpson.github.io/nvim-lua-manual/docs/interacting/
	- https://github.com/folke/noice.nvim/wiki/A-Guide-to-Messages

	Distros
	- https://github.com/e-cal/evim
	- https://github.com/LunarVim/Neovim-from-scratch/tree/master/lua/user
	- https://github.com/nvim-lua/kickstart.nvim/tree/master/lua/kickstart/plugins

	Plugins
	- https://vimawesome.com/plugin/vim-devicons
	- https://kkalamarski.me/essential-neovim-plugins

	Examples
	- https://gist.github.com/s1n7ax
	- https://gist.github.com/s1n7ax/6885a550633fa8a285fdef2c0f8044ad generate doc-comments
	- https://github.com/wincent/wincent/blob/aa3a322e3a911dabe0ef398ebb1fd7c77209b8ac/roles/dotfiles/files/.vim/plugin/mappings/leader.vim

	Dotfiles (funny, or "simple")
	- https://github.com/Traap/nvim - old timer has his own system.
	- https://github.com/beauwilliams/Dotfiles/tree/master/Vim/nvim - full of life ossie with code comments spanning 88-145 dashes :D

	Plugins to study
	- https://github.com/ojroques/nvim-buildme/blob/main/lua/buildme.lua

	Intro to fugitive
	- https://jeancharles.quillet.org/posts/2022-03-02-Practical-introduction-to-fugitive.html

	Other
	- https://www.nerdfonts.com/cheat-sheet
	- https://github.com/nvim-neorg/neorg
]]
