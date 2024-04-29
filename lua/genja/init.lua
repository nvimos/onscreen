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
	https://github.com/Traap/nvim - old timer has his own system.
	https://github.com/wincent/wincent/blob/aa3a322e3a911dabe0ef398ebb1fd7c77209b8ac/roles/dotfiles/files/.vim/plugin/mappings/leader.vim


	Plugins to study
	https://github.com/ojroques/nvim-buildme/blob/main/lua/buildme.lua


	Other
	https://www.nerdfonts.com/cheat-sheet

]]
vim.cmd 'colorscheme lunaperche'
require 'genja.fn'

if (is_started_from_windows_shell()) then
	vim.loop.chdir(vim.env.Userprofile)
end

vim.g.mapleader      = ' '
vim.g.maplocalleader = ','

--[[=================]]--
require 'genja.opt'
require 'genja.init-map'
require 'genja.alias'
require 'genja.auto'
require 'genja.hilite'
require 'genja.lazy' -- packages via genja.lazy
require 'genja.map'
--[[=================]]--
------------------------------
-- require 'genja.lsp'
START_DIRS = (function() -- Telescope_find_dirs
	local function Norm(p) return p:gsub([[\]], [[/]]) end
	return {
		-- Norm(vim.env.HOME) , 
		Norm(vim.fn.stdpath('config'))
		, Norm('A:/workspace')
		, Norm('O:/H1')
		, } end)()



