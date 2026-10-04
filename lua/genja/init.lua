-- Genja init for nvim
--
vim.o.guifont        = 'Cascadia Code Light:h14:l'
vim.cmd 'colorscheme lunaperche'
--
vim.g.mapleader      = ' '
vim.g.maplocalleader = ','

Safeload             = require('genja.fn').Safeload

Safeload 'genja.env'
Safeload 'genja.map-zero' -- stable early maps, if config breaks
Safeload 'genja.opt'      -- just static options
Safeload 'genja.fu' -- userfuncs
Safeload 'genja.ft' -- filetypes

require 'genja.fn'.win_chdir_home() -- cd ~ on windows

C = vim.fn.stdpath('config')
vim.cmd('source ' .. C .. '/lua/genja/auto-alias.vim') -- aliases, onliners, autocommads, abbreviations
vim.cmd('source ' .. C .. '/lua/genja/hilite.vim')  -- colors
vim.cmd('source ' .. C .. '/lua/genja/fn.vim')

Safeload('genja.hilite', function(m) m.setup() end)
Safeload 'genja.auto' -- autocommads
Safeload 'genja.boot.boot-lazy' -- genja/lazy-spec.lua -> import { lazy-my }
Safeload 'genja.lazy-plug-spec'
Safeload 'genja.map-lsp'
Safeload 'genja.map-telescope'
Safeload 'genja.map-convoluted'

START_DIRS = (function() -- Telescope_find_dirs() looks in predefined locations
	local sd = {}
	local function Norm(p) local s, _ = p:gsub('\\', '/'); return s end
	local function InsertDir(e) if IsDir(e) then table.insert(sd, Norm(e)) end end
	local function add_dir(e) InsertDir(e) end
	local homePath = function(p)
		local h = vim.env.Userprofile or vim.env.HOME;
		return (h .. ('/' .. (p or '')))
	end

	add_dir(homePath())

	local openmw = false
	local fonv = false
	local oni = true
	local movies = false

	if vim.fn.has('Windows') then
		add_dir('J:/notes')
		add_dir('A:/workspace')
		add_dir('A:/_setup/bootstrap')
		add_dir(homePath('Hj/notes'))
		add_dir(homePath('Notez26'))

		add_dir('O:')

		if oni then
			table.insert(sd, '--- (fonv)')
			add_dir(homePath('Documents/Klei/OxygenNotIncluded'))
		end

		if fonv then
			table.insert(sd, '--- (fonv)')
			add_dir('C:/Games/standalone/Fallout New Vegas Ultimate Edition/Data/NVSE/plugins/Tweaks/GameSettings')
			add_dir('C:/Games/standalone/Fallout New Vegas Ultimate Edition/Data')
			add_dir(homePath('Documents/My Games/FalloutNV'))
			add_dir(homePath('AppData/Local/FalloutNV'))
		end

		if openmw then
			table.insert(sd, '--- (morrowind)')
			add_dir('C:/Games/Openmw.DataFilesExamples')
			add_dir('C:/Games/OpenMW.master')
			add_dir('C:/Games')
			add_dir(homePath('Documents/my games/OpenMW'))
			add_dir(homePath('AppData/Roaming/Vortex/morrowind/mods'))
			add_dir('J:/notes/gaming/morrowind')
		end

		if movies then
			table.insert(sd, '--- (movies)')
			add_dir('P:/cinema')
			add_dir('P:/backup/lin/balmora-2023.files/Base/home/jaroslav')
			add_dir('P:/cinema')
			add_dir('V:')
		end
		table.insert(sd, '---')

		-- add_dir('J:/bin')
		-- add_dir('J:/reference')
	end

	add_dir(vim.fn.stdpath('config'))
	add_dir(vim.fn.stdpath('data'))
	return sd
end)()
