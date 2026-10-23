-- Genja init for nvim
--
vim.cmd 'colorscheme lunaperche'
--
vim.g.mapleader      = ' '
vim.g.maplocalleader = ','

local Safeload = require('genja.api').Safeload

Safeload 'genja.env'
Safeload 'genja.map-zero'           -- stable early maps, if config breaks
Safeload 'genja.opt'                -- just static options
Safeload 'genja.fu'                 -- userfuncs

require 'genja.fn'.win_chdir_home() -- cd ~ on windows

local C = vim.fn.stdpath('config')
vim.cmd('source ' .. C .. '/lua/genja/auto-alias.vim') -- aliases, onliners, autocommads, abbreviations
vim.cmd('source ' .. C .. '/lua/genja/abbreviations.vim') -- abbreviations
vim.cmd('source ' .. C .. '/lua/genja/hilite.vim')     -- colors
vim.cmd('source ' .. C .. '/lua/genja/fn.vim')

Safeload('genja.hilite', function(m) m.setup() end)
Safeload 'genja.auto' -- autocommads
Safeload 'genja.lazy-plug-spec'
Safeload 'genja.map-lsp'
Safeload 'genja.map-telescope'
Safeload 'genja.ui-select'          -- vim.ui.select in telescope (code actions etc.)
Safeload 'genja.map-convoluted'
Safeload('genja.wrapfold', function(m) m.setup_command() end) -- :WrapFold



START_DIRS = (function() -- Telescope_find_dirs() looks in predefined locations
	local sd = {}
	local function Norm(p)
		return vim.fn.trim((p:gsub('\\', '/'):gsub('oil://', '')) )
	end
	local function add_dir(e) if IsDir(Norm(e)) then table.insert(sd, Norm(e)) end end
	local homePath = function(p)
		local h = vim.env.Userprofile or vim.env.HOME; return (h .. ('/' .. (p or '')));
	end
	local openmw = false
	local fonv = false
	local oni = true
	local movies = false

	add_dir [[ oil://C:/Users/jazzo/es/finn-appartment           ]]
	add_dir [[ C:/_setup.new/setup-2026-cut                      ]]
	add_dir [[ Q:/Dedupe/home-jaro.q4.26/Tilde27/__hj.2025/notes ]]
	add_dir [[ C:/_setup.bauss                                   ]]
	add_dir(homePath())


	if vim.fn.has('win32') == 1 then
		add_dir('J:/notes')
		add_dir('A:/workspace')
		add_dir('A:/_setup/bootstrap')
		add_dir('A:/bin')

		add_dir [[ oil://A:/ws/ ]]
		add_dir(homePath('Hj/notes'))
		add_dir(homePath('Notez26'))
		add_dir(homePath('Desktop/tmp'))
		add_dir(homePath('Local Sites/norway4u'))

		add_dir('C:/Users/jazzo/AppData/Local/nvim/plug-wip/genja-completion011.nvim')
		add_dir [[C:/Users/jazzo/AppData/Local/nvim/plug-wip/genja-finder.nvim/lua/genja-finder/]]
		add_dir('C:/Users/jazzo/AppData/Local/nvim/plug-wip/genja-oily.nvim')

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
	add_dir(homePath('ws/'))
	-- add_dir(vim.fn.stdpath('data'))

	return sd
end)()
