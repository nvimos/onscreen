

-- :lua require('telescope.builtin').find_files({layout_strategy='vertical',layout_config={width=0.5}})


-- nnoremap <Leader>f :lua require'telescope.builtin'.find_files(require('telescope.themes').get_dropdown({}))<cr>
-- " Change an option
-- nnoremap <Leader>f :lua require'telescope.builtin'.find_files(require('telescope.themes').get_dropdown({ winblend = 10 }))<cr>
-- 
-- themes.get_dropdown	A list like centered list. dropdown
-- themes.get_cursor	A cursor relative list.
-- themes.get_ivy	Bottom panel overlay. Ivy #771

--- Telescope find_files theme=dropdown
--- Or you can configure it in the pickers table in telescope.setup:
--- 
--- require('telescope').setup{
	---   defaults = {
		---     -- ...
		---   },
		---   pickers = {
			---     find_files = {
				---       theme = "dropdown",
				---     }
				---   },
				---   extensions = {
					---     -- ...
					---   }
					--- }

local ok, te = pcall(require, 'telescope')
if not ok then
	return
end

local action_generate = require("telescope.actions.generate")


require('telescope').setup {
	defaults = {
		-- winblend = 2,

		dynamic_preview_title = true,
		results_title = 'found:',
		prompt_title = '',
		file_sorter = require("telescope.sorters").get_fzy_sorter,
		file_previewer = require("telescope.previewers").vim_buffer_cat.new,
		grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
		generic_sorter = require("telescope.sorters").get_fzy_sorter,

		mappings = {
			i = {
				["<C-Down>"] = require('telescope.actions').cycle_history_next,
				["<C-Up>"] = require('telescope.actions').cycle_history_prev,
			},
			n = {
				["?"] = action_generate.which_key {
					name_width = 20, -- typically leads to smaller floats
					max_height = 0.5, -- increase potential maximum height
					separator = " > ", -- change sep between mode, keybind, and name
					close_with_action = false, -- do not close float on action
				},
			}
		},

		get_selection_window = function() return 0 end,

		borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
		-- borderchars = { "·", "│", "·─", "│", ".", ".", "'", "`" },

		path_display = { truncate = 3, shorten = 2, smart = true}, -- help: telescope.defaults.path_display
		prompt_prefix = '󰧚 ',
		layout_strategy = 'vertical', -- 'horizontal',
		layout_config = {
			scroll_speed = 6,
			prompt_position = 'top',
			mirror = true,
			height = 0.9999,
			width = 0.98 },
			preview = { timeout = 110 },
			-- vimgrep_arguments is only used for grep_string and live_grep
			vimgrep_arguments = { 'rg', '--color=never', '--no-heading', '--with-filename', '--line-number', '--column', '--smart-case', '--hidden' },
			border = true,
			file_ignore_patterns = {
				--
				'AMD_RyzenMaster.log',
				-- Files
				"%.a",
				"%.class",
				"%.mkv",
				"%.mp4",
				"%.mp3",
				"%.o",
				"%.out",
				"%.pdf",
				"%.zip",
				-- Directories
				"undodir/",
				".cache",
				".git/",
				".github/",
				--
				".node_modules/",
				".node_modules\\",
				"node%_modules",
				--
				"lazy-lock.json",
				"go.pkg.mod",
				"go\\pkg\\"
			}
		}
	}



local ok, te = pcall(require, 'telescope.builtin')
if not ok then
	return
end


-- vim.keymap.set('n', '<leader>jj', te.live_grep, { desc = '() live_grep 󰵃'})
vim.keymap.set('n', '<leader>jj', te.live_grep, { desc = '() live 󰵃'})
vim.keymap.set('n', '<leader>jg', te.git_files, { desc = '() git_files'})
vim.keymap.set('n', '<leader>jh', te.help_tags, { desc = '() help_tags'})
vim.keymap.set('n', '<leader>j?', te.builtin,   { desc = '() builtin'})
vim.keymap.set('n', '<leader>jb', te.buffers,   { desc = '() buffers'})
vim.keymap.set('n', '<leader>jr', te.registers,     { desc = '() registers'})
vim.keymap.set('n', '<leader>jo', te.oldfiles,  { desc = '() oldfiles'})
vim.keymap.set('n', '<leader>jd', Telescope_find_dirs, { desc = '() dirs󰅲'})

vim.keymap.set('n', '<leader>jm', te.marks,     { desc = '() marks'})

vim.keymap.set('n', '<leader>jq', te.quickfix,  { desc = '() quickfix'})
vim.keymap.set('n', '<leader>jl', te.loclist,  { desc = '() loclist'})
vim.keymap.set('n', '<leader>jv', te.vim_options,  { desc = '() vim_options'})
vim.keymap.set('n', '<leader>jC', te.colorscheme,   { desc = '() colorscheme'})
vim.keymap.set('n', '<leader>jM', te.keymaps,     { desc = '() keymaps'})
vim.keymap.set('n', '<leader>jA', te.autocommands,     { desc = '() autocommands'})

-- builtin.lsp_references
-- builtin.lsp_incoming_calls
-- builtin.lsp_outcoing_calls
-- builtin.lsp_definitions
-- builtin.lsp_type_definitions
-- builtin.lsp_implementations
-- builtin.lsp_document_symbols
-- builtin.lsp_workspace_symbols

-- builtin.diagnostics




vim.keymap.set('n', '<leader>js', function()
	te.grep_string({ search = vim.fn.input("Grep: ") })
end, {  desc = '() grep'})



vim.keymap.set('n', '<leader>j/.', te.find_files,                    { desc = '() find_files'})
vim.keymap.set('n', '<leader>j//', ':lua Telescope_find_dirs()<CR>', { desc = '() dirs()'})
-- vim.keymap.set('n', '<leader>ff', te.find_files, { desc = 'Telescope find_files'})
-- vim.keymap.set('n', '<leader>fg', te.live_grep, { desc = 'Telescope live_grep'})
-- vim.keymap.set('n', '<leader>fb', te.buffers, { desc = 'Telescobe buffers' })
-- vim.keymap.set('n', '<leader>fh', te.help_tags, { desc = 'Telescope help_tags'})
--vim.keymap.set('n', '<leader>pf', te.find_files, {})
--vim.keymap.set('n', '<C-p>', te.git_files, {})
--vim.keymap.set('n', '<leader>vh', te.help_tags, {})



--[[

        Default: layout_config = {
          bottom_pane = {
            height = 25,
            preview_cutoff = 120,
            prompt_position = "top"
          },
          center = {
            height = 0.4,
            preview_cutoff = 40,
            prompt_position = "top",
            width = 0.5
          },
          cursor = {
            height = 0.9,
            preview_cutoff = 40,
            width = 0.8
          },
          horizontal = {
            height = 0.9,
            preview_cutoff = 120,
            prompt_position = "bottom",
            width = 0.8
          },
          vertical = {
            height = 0.9,
            preview_cutoff = 40,
            prompt_position = "bottom",
            width = 0.8
          }
        }
]]
