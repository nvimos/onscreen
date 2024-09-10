vim.cmd 'colorscheme lunaperche'
require 'genja.fn'          -- functions

if (Started_from_windows_shell()) then
	vim.loop.chdir(vim.env.Userprofile)
end

vim.g.mapleader      = ' '
vim.g.maplocalleader = ','

require 'genja.opt'         -- just static options
vim.cmd ([[source ]]..CONFIG..[[/lua/genja/auto-alias.vim]])

require 'genja.imap'        -- early maps, if config breaks
require 'genja.auto'        -- autocommads, automation
require 'genja.hilite'      --
require 'genja.lazy'        -- genja/lazy.lua -> import { lazyp }
require 'genja.map'         --

START_DIRS = (function()    -- Telescope_find_dirs() looks in predefined locations
	local sd = {}
	local function Norm(p) s, _ = p:gsub([[\]], [[/]]); return s end
	local function InsertDir(e) if IsDir(e) then table.insert(sd, Norm(e)) end end
	local function add_dir(e, drive) if drive then if NetUseDrive(drive) then InsertDir(e) end else InsertDir(e) end end
	-- check if `net drive X:` is available.
	-- This is intended to prevent IO timeouts caused by IsDir() aka vim.loop.fs_stat
	-- ... the dashboard still seems to hang when drives are unmounted. dunno what's causing that.
	function NetUseDrive(drive)
		local handle = io.popen('cmd /c "net use  '..drive..': 2>nul && echo yes"')
		if nil ~= handle then
			local output = handle:read('*a')
			if "yes" == StripNewlines(output) then
				return true end end return false end
	if vim.fn.has('Windows') then
		add_dir('A:/_setup/bootstrap')
		add_dir('J:/bin', 'J')
		add_dir('J:/notes', 'J')
		add_dir('J:/reference', 'J')
		add_dir('O:', 'O') -- outer
		add_dir('A:/workspace')
		add_dir('P:/backup/lin/balmora-2023.files/Base/home/jaroslav', 'p')
		add_dir('P:/cinema', 'p')
		add_dir('V:', 'v') --video
		add_dir(vim.env.Userprofile)
		else
		add_dir(vim.env.HOME)
	end
	add_dir(vim.fn.stdpath('config'))
	add_dir(vim.fn.stdpath('data'))
	return sd end)()

--[[
	Inspiration
	- https://github.com/folke/lazy.nvim
	- https://github.com/ThePrimeagen/init.lua

	Docs
	- https://jacobsimpson.github.io/nvim-lua-manual/docs/interacting/

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
