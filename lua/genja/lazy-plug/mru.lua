--vim.keymap.set('', '<S-F1>', ':lua CheckAndRunMRU()<CR>', { noremap = true, silent = true })

return {
	{ 'vim-scripts/mru.vim',       -- most recently used (old school)
	lazy = true,
	keys = { 
		{ '<S-F1>', ':lua CheckAndRunMRU()<cr>', { noremap = true, silent = true } },
	},
	cmd = { 'CheckAndRunMRU', 'MRU' },
	init = function()
		vim.g.MRU_Window_Height = 20
		vim.g.MRU_Max_Menu_Entries = 20

		vim.g.MRU_Filename_Format = {
			formatter = 'printf("%-36s", fnamemodify(v:val, ":t:r")) .  " (".v:val.")"',
			parser = "(\\zs.*\\ze)", -- how to extract the filename from the formatter output
			syntax = "^.\\{-}\\ze("
		}

	end,
	}
}

-- vim.cmd [[
-- 	" let MRU_File = 'd:\myhome\_vim_mru_files'
-- 	" let MRU_Max_Entries = 1000
-- 	" let MRU_Exclude_Files = '^/tmp/.*\|^/var/tmp/.*'  " For Unix
-- 	" let MRU_Exclude_Files = '^c:\\temp\\.*'           " For MS-Windows
-- 	"" The specified pattern should be a Vim regular expression pattern.
--     " let MRU_Max_Submenu_Entries = 15
--     " let MRU_Use_Current_Window = 1
-- 	" let MRU_Auto_Close = 0
--     " let MRU_Filename_Format={'formatter':'v:val', 'parser':'.*'}
-- ]];


-- You can select a file name to edit by pressing the <Enter> key or by double
-- clicking the left mouse button on a file name.

-- You can press the 'o' key to open the file name under the cursor in the
-- MRU window in a new window. You can also press <Shift-Enter> instead of 'o'
-- to open the file in a new window.
-- 
-- To open a file from the MRU window in read-only mode (view), press the 'v'
-- key.
-- 
-- 
-- To open a file from the MRU window in a new tab, press the 't' key.  If the
-- 
-- You can close the MRU window by pressing the 'q' key or the <Esc> key or
-- using one of the Vim window commands.
-- 
-- You can press the 'u' key in the MRU window to update the file list. This is
-- useful if you keep the MRU window open always.
-- 
-- You can open multiple files from the MRU window by specifying a count before
-- pressing '<Enter>' or 'v' or 'o' or 't'. You can also visually (using
-- linewise visual mode) select multiple filenames and invoke the commands to
-- open the files. Each selected file will be opened in a separate window or
-- tab.
