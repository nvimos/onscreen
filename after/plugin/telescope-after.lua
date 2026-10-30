-- vim: foldmethod=marker

-- {{{ telescope_pretty_path
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
-- }}}

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

local which_key = action_generate.which_key {
	name_width = 20, -- typically leads to smaller floats
	max_height = 0.5, -- increase potential maximum height
	separator = " > ", -- change sep between mode, keybind, and name
	close_with_action = false, -- do not close float on action
}

local mappings = {
	i = {
		["<C-Down>"] = require('telescope.actions').cycle_history_next,
		["<C-Up>"] = require('telescope.actions').cycle_history_prev,
		["<C-/>"] = which_key,
		["<C-_>"] = which_key, -- what some terminals send for <C-/>
		-- telescope defaults, every picker: uncomment a line to switch that key off (A1)
		-- ['<C-n>'] = false, -- move_selection_next
		-- ['<C-p>'] = false, -- move_selection_previous
		-- ['<C-c>'] = false, -- close
		-- ['<Down>'] = false, -- move_selection_next
		-- ['<Up>'] = false, -- move_selection_previous
		-- ['<CR>'] = false, -- select_default
		-- ['<C-x>'] = false, -- select_horizontal
		-- ['<C-v>'] = false, -- select_vertical
		-- ['<C-t>'] = false, -- select_tab
		-- ['<C-u>'] = false, -- preview_scrolling_up
		-- ['<C-d>'] = false, -- preview_scrolling_down
		-- ['<C-f>'] = false, -- preview_scrolling_left
		-- ['<C-k>'] = false, -- preview_scrolling_right
		-- ['<PageUp>'] = false, -- results_scrolling_up
		-- ['<PageDown>'] = false, -- results_scrolling_down
		-- ['<M-f>'] = false, -- results_scrolling_left (refine uses it)
		-- ['<M-k>'] = false, -- results_scrolling_right
		-- ['<Tab>'] = false, -- toggle_selection + move_selection_worse
		-- ['<S-Tab>'] = false, -- toggle_selection + move_selection_better
		-- ['<C-q>'] = false, -- send_to_qflist + open_qflist (map-telescope sets it)
		-- ['<M-q>'] = false, -- send_selected_to_qflist + open_qflist (map-telescope sets it)
		-- ['<C-l>'] = false, -- complete_tag (map-telescope: loclist)
		-- ['<C-/>'] = false, -- which_key (key list)
		-- ['<C-_>'] = false, -- which_key (terminals send it for <C-/>)
		-- ['<C-w>'] = false, -- delete word
		-- ['<C-r><C-w>'] = false, -- insert_original_cword
		-- ['<C-r><C-a>'] = false, -- insert_original_cWORD
		-- ['<C-r><C-f>'] = false, -- insert_original_cfile
		-- ['<C-r><C-l>'] = false, -- insert_original_cline
		-- ['<C-j>'] = false, -- nop
	},
	n = {
		["?"] = which_key,
		-- telescope defaults, every picker: uncomment a line to switch that key off (A1)
		-- ['<esc>'] = false, -- close (Telemap sets it)
		-- ['<CR>'] = false, -- select_default
		-- ['<C-x>'] = false, -- select_horizontal
		-- ['<C-v>'] = false, -- select_vertical
		-- ['<C-t>'] = false, -- select_tab
		-- ['<Tab>'] = false, -- toggle_selection + move_selection_worse
		-- ['<S-Tab>'] = false, -- toggle_selection + move_selection_better
		-- ['<C-q>'] = false, -- send_to_qflist + open_qflist (map-telescope sets it)
		-- ['<M-q>'] = false, -- send_selected_to_qflist + open_qflist (map-telescope sets it)
		-- ['j'] = false, -- move_selection_next
		-- ['k'] = false, -- move_selection_previous
		-- ['H'] = false, -- move_to_top
		-- ['M'] = false, -- move_to_middle
		-- ['L'] = false, -- move_to_bottom
		-- ['<Down>'] = false, -- move_selection_next
		-- ['<Up>'] = false, -- move_selection_previous
		-- ['gg'] = false, -- move_to_top
		-- ['G'] = false, -- move_to_bottom
		-- ['<C-u>'] = false, -- preview_scrolling_up
		-- ['<C-d>'] = false, -- preview_scrolling_down
		-- ['<C-f>'] = false, -- preview_scrolling_left
		-- ['<C-k>'] = false, -- preview_scrolling_right
		-- ['<PageUp>'] = false, -- results_scrolling_up
		-- ['<PageDown>'] = false, -- results_scrolling_down
		-- ['<M-f>'] = false, -- results_scrolling_left (refine uses it)
		-- ['<M-k>'] = false, -- results_scrolling_right
		-- ['?'] = false, -- which_key (key list)
	}
}
-- picker keys kept with the other telescope keymaps (loclist/qflist: <M-l> <M-L> <C-l> <M-q> <M-Q> <C-q>)
local map_ok, map_telescope = pcall(require, 'genja.map-telescope')
if map_ok and type(map_telescope) == 'table' then
	mappings = vim.tbl_deep_extend('force', mappings, map_telescope.picker_mappings)
end


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

		mappings = mappings,

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


		-- {{{ ignore patterns
		-- Lua patterns, matched anywhere in the path: anchor extensions with $ ("%.a" alone hides *.ahk),
		-- escape . and - with %, [\\/] for either separator. genja-finder heeds these too.
		-- Directory names: "%f[%w_%.]name[\\/]" matches name/ at the path start or after a separator or
		-- '-', but not inside a longer word (target/ yes, subtarget/ no).
		--
		-- How others manage ignore lists (looked up 2026-10-13):
		-- * What the lists are for, usually: hide build output and vendored deps (node_modules, target,
		--   __pycache__); hide binaries a previewer can't show (exe, dll, media, archives); hide OS/editor
		--   junk (Thumbs.db, .DS_Store, *.swp); and speed, since skipping big trees is the largest win.
		-- * Telescope's own docs suggest leaving this list short: it applies in every picker that has a
		--   file, so lsp_references/diagnostics in node_modules etc. are hidden too. For find/grep they
		--   recommend .gitignore + fd/rg, which never even list ignored files.
		--   https://github.com/nvim-telescope/telescope.nvim/blob/master/doc/telescope.txt
		-- * This list is a Lua post-filter: rg/fd still walk and print every file, then each path is checked
		--   against every pattern. Big trees go in genja-finder `exclude` (rg --glob !x / fd --exclude x).
		--   Very long lists are slow in rg/fd too (a 16k-line ignore file used ~7 GiB in rg).
		--   https://github.com/BurntSushi/ripgrep/issues/2750
		-- * One list for every tool: the global git ignore (core.excludesFile, default
		--   ~/.config/git/ignore) is read by git, rg and fd (fd only inside a repo unless --no-require-git).
		--   For non-git rules: ~/.config/fd/ignore and a .ignore file per directory, which rg and fd both
		--   read. People build their global file from github/gitignore's Global/ templates (Windows,
		--   macOS, Vim, JetBrains...) instead of writing it by hand.
		--   https://adamj.eu/tech/2022/11/06/git-set-up-a-global-ignore-file/
		--   https://github.com/github/gitignore/tree/main/Global   https://man.archlinux.org/man/fd.1.en
		-- * Bringing files back: a `!pattern` line in .ignore beats .gitignore, e.g. `!*.log` makes rg
		--   search gitignored logs. Negation in --ignore-file has known bugs; a .ignore file works.
		--   https://mbork.pl/2021-02-06_Unignoring_some_files_by_ripgrep
		-- * Separate lists by purpose: VS Code keeps files.exclude (hide from the tree; search too),
		--   search.exclude (search only) and files.watcherExclude (perf only). The same split here:
		--   this list = never show, genja-finder exclude = don't search, <M-i> cycles it off.
		-- * Toggles instead of one fixed list: togglescope flips a picker between two configs (e.g. with and
		--   without hidden/ignored files) with one key, the same idea as genja-finder's <M-i>.
		--   https://github.com/Theo-Steiner/togglescope
		-- * `.git/[^h]` hides .git but keeps .git/hooks findable.  https://lee-phillips.org/nvimTelescopeConfig
		file_ignore_patterns = {
			-- Files
			"%.a$",
			"%.class$",
			"%.mkv$",
			"%.mp4$",
			"%.mp3$",
			"%.o$",
			"%.out$",
			"%.pdf$",
			"%.zip$",
			-- Build output / binaries
			"%.exe$", "%.dll$", "%.pdb$", "%.obj$", "%.lib$", "%.so$", "%.dylib$",
			"%.pyc$", "%.jar$", "%.wasm$",
			-- Archives / installers
			"%.7z$", "%.rar$", "%.tar$", "%.gz$", "%.tgz$", "%.iso$", "%.msi$",
			-- Media / fonts
			"%.wav$", "%.flac$", "%.webm$", "%.avi$", "%.mov$",
			"%.ttf$", "%.otf$", "%.woff2?$",
			-- OS / editor junk
			"Thumbs%.db$", "desktop%.ini$", "%.DS_Store$", "%.lnk$",
			"%.sw[po]$", "~$",
			-- Logs (also covers AMD_RyzenMaster.log) and lockfiles
			"%.log$",
			"package%-lock%.json$", "pnpm%-lock%.yaml$", "yarn%.lock$", "Cargo%.lock$",
			-- Directories
			"undodir[\\/]",
			"%.cache[\\/]",
			"%.git[\\/][^h]",        -- hides .git/ but keeps .git/hooks/ findable
			"%.github[\\/]",
			"node_modules[\\/]",
			"__pycache__[\\/]",
			"%f[%w_%.]%.?venv[\\/]", -- venv/ and .venv/
			"%.mypy_cache[\\/]",
			"%.pytest_cache[\\/]",
			"%f[%w_%.]target[\\/]",  -- Rust/Maven
			"%.gradle[\\/]",
			"%.idea[\\/]",
			"%f[%w_%.]%.vs[\\/]",    -- Visual Studio
			"%f[%w_%.]obj[\\/]",     -- .NET
			"%.next[\\/]",
			"%.terraform[\\/]",
			"%f[%w_%.]coverage[\\/]",
			--
			"lazy%-lock%.json$",
			"go[\\/]pkg[\\/]mod[\\/]",
		}

		-- }}}
	}
}

-- {{{ key hint in the prompt
-- Telescope has no footer, so the hint is virtual text after the prompt prefix, shown while the
-- prompt is empty (like a placeholder). The right edge holds telescope's result counter.
-- A picker can set its own: vim.b[prompt_bufnr].telescope_hint = '…' in attach_mappings.
local HINT = 'mark Tab · send <M-l/q> · appeng <M-L/Q> · keys <C-/>'
local hint_ns = vim.api.nvim_create_namespace('genja_telescope_hint')

---Show the hint on an empty prompt, clear it once something is typed.
---@param buf integer prompt buffer
local function update_hint(buf)
	if not vim.api.nvim_buf_is_valid(buf) then
		return
	end
	vim.api.nvim_buf_clear_namespace(buf, hint_ns, 0, -1)
	local line = vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] or ''
	if line ~= vim.fn.prompt_getprompt(buf) then
		return
	end
	vim.api.nvim_buf_set_extmark(buf, hint_ns, 0, 0, {
		virt_text = { { vim.b[buf].telescope_hint or HINT, 'TelescopeResultsTitle' } }, -- same as the key help (lua/genja/ext/telescope-virthelp.lua)
		virt_text_pos = 'eol',
	})
end

vim.api.nvim_create_autocmd('FileType', {
	group = vim.api.nvim_create_augroup('genja_telescope_hint', { clear = true }),
	pattern = 'TelescopePrompt',
	callback = function(ev)
		-- telescope sets the prompt text after the filetype
		vim.schedule(function() update_hint(ev.buf) end)
		vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI' }, {
			buffer = ev.buf,
			callback = function() update_hint(ev.buf) end,
		})
	end,
})
-- }}}

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
