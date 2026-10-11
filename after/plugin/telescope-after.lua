---path_display: "file.lua (dir/)", file name highlighted.
---@param path string
---@return string display
---@return table? highlights { { {start, end}, hl_group }, ... }
local function telescope_pretty_path(_, path)
	-- 1. Grab just the filename (the tail end of the path)
	local filename = path:match("[^/]+$") or ""

	-- 2. Strip out the project's root path to make the rest relative and clean
	local cwd = vim.uv.cwd() or vim.fn.getcwd()
	local relative_path = path

	-- Escape special magic characters in the CWD path for a safe match
	local escaped_cwd = cwd:gsub("(%W)", "%%%1")
	if path:match("^" .. escaped_cwd) then
		relative_path = path:sub(#cwd + 2) -- Clean off 'CWD/' from the path string
	end

	-- 3. Extract the parent folder path
	local parent_dir = relative_path:match("(.*)/[^/]+$") or ""

	-- If it's a file sitting right in your root directory
	if parent_dir == "" then
		return filename
	end

	-- 4. Construct the visual string: "filename.lua (lua/config/telescope/)"
	local display_string = string.format("%s (%s/)", filename, parent_dir)

	-- 5. Clever Part: Inject precise highlight coordinates back to Telescope!
	-- This paints the filename using your theme's bold "Constant" or "Function" link,
	-- and soft-fades the parent directory using the standard "Comment" syntax.
	local highlights = {
		{ { 0, #filename },                   "Constant" },
		{ { #filename + 1, #display_string }, "Comment" },
	}

	return display_string, highlights
end

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

		-- path_display = { truncate = 3, shorten = 2, smart = true },     -- help: telescope.defaults.path_display
		path_display = telescope_pretty_path,

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
