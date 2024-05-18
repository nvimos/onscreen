--[[
	Inspiration
	https://github.com/folke/lazy.nvim
	https://github.com/ThePrimeagen/init.lua

	Docs
	https://jacobsimpson.github.io/nvim-lua-manual/docs/interacting/

	Distros
	https://github.com/e-cal/evim
	https://github.com/LunarVim/Neovim-from-scratch/tree/master/lua/user
	https://github.com/nvim-lua/kickstart.nvim/tree/master/lua/kickstart/plugins

	Plugins
	https://vimawesome.com/plugin/vim-devicons

	Examples
	https://gist.github.com/s1n7ax
	https://gist.github.com/s1n7ax/6885a550633fa8a285fdef2c0f8044ad generate doc-comments
	https://github.com/wincent/wincent/blob/aa3a322e3a911dabe0ef398ebb1fd7c77209b8ac/roles/dotfiles/files/.vim/plugin/mappings/leader.vim


	Dotfiles (funny, or "simple")
	https://github.com/Traap/nvim - old timer has his own system.
	https://github.com/beauwilliams/Dotfiles/tree/master/Vim/nvim - full of life ossie with code comments spanning 88-145 dashes :D


	Plugins to study
	https://github.com/ojroques/nvim-buildme/blob/main/lua/buildme.lua


	Other
	https://www.nerdfonts.com/cheat-sheet
]]

vim.cmd 'colorscheme lunaperche'
require 'genja.fn'          -- functions

if (is_started_from_windows_shell()) then
	vim.loop.chdir(vim.env.Userprofile) end

Myleige( ' ',   ',')        -- mapleader, maplocalleader
Myleige([[ ]], [[,]])       -- mapleader, maplocalleader

require 'genja.opt'         -- just static options
-- require 'genja.auto-alias'  -- these should be safe foo

-- ./auto-alias.vim
vim.cmd ([[source ]]..CONFIG..[[/lua/genja/auto-alias.vim]]) --  can vim.cmd[[ ]] support vimscript syntax?


require 'genja.imap'        -- early maps, if config breaks
require 'genja.auto'        -- autocommads, automation
require 'genja.hilite'      --
require 'genja.lazy'        -- genja/lazy.lua -> import { plugins, genja.lazy-plugs }
require 'genja.map'         --

START_DIRS = (function()    -- Telescope_find_dirs() looks in predefined locations
	local function Norm(p) s, _ = p:gsub([[\]], [[/]]); return s end
	local sd = {}
	if vim.fn.has("Windows") then
		table.insert(sd, Norm('O:/H1'))
		table.insert(sd, Norm('A:/workspace'))
		table.insert(sd, Norm(vim.env.Userprofile))
		else
		table.insert(sd, Norm(vim.env.HOME))
		end
		table.insert(sd, Norm(vim.fn.stdpath('config')))
		table.insert(sd, Norm(vim.fn.stdpath('data')))
	return sd end)()
