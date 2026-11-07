-- vim: set foldmethod=marker foldlevel=0 foldnestmax=2 foldcolumn=2:

local aucmd = vim.api.nvim_create_autocmd
local augrp = vim.api.nvim_create_augroup
local UserComm = vim.api.nvim_create_user_command

local function config_oil(_, opts)
    require('oil').setup(opts)
    vim.g.loaded_netrw = nil -- load netrw, keep :Lexplore, but oil handles dirs
end

local function init_oil()
    vim.g.loaded_netrwPlugin = 1 -- prevent netrw FileExplorer autocmds

    -- arg-1 is a dir -> load oil
    if vim.fn.argc() == 1 then
        local stat = vim.loop.fs_stat(vim.fn.argv(0))
        if stat and stat.type == "directory" then
            require("lazy").load({ plugins = { "oil.nvim" } })
        end
    end

    -- Open a folder -> load oil
    vim.api.nvim_create_autocmd("BufReadPre", {
        desc = "Lazy load oil.nvim when opening a directory buffer",
        callback = function(ev)
            if vim.fn.isdirectory(ev.match) == 1 then
                -- Load the plugin immediately before Neovim processes the directory buffer
                require("lazy").load({ plugins = { "oil.nvim" } })
            end
        end,
    })
end

local function genja_oily_is_hidden_file(name, bufnr)
    return require("genja-oily").is_hidden_file(name, bufnr)
end


local F = require 'genja.oil'

UserComm('OilVlcRar', F.vlc_rar, { desc = 'Oil: open rar in vlc (extract to c:/tmp)' })
UserComm('OilCd2Entry', F.cd_to_entry, { desc = 'Oil: cd to entry' })

-- Sugar syntax autogroups experiment {{{
--- local
---      MyAutos = {}
---      MyAutos.__index = MyAutos
---      MyAutos.__call = function(groupName)
---      	local inst = setmetatable({}, MyAutos)
---      	inst.gr = augrp(groupName, { clear = true })
---      	return inst end
---      function MyAutos:acom(fn) fn(self, self.gr) end
---      Oilgroup = MyAutos('MyOil')
---      Oilgroup.acom(function(gr)
---      	aucmd('BufEnter', {   group = gr,
---      	                    pattern = 'oil:///*',
---      					   callback = F.sort_by_mtime_in_certain_paths })
---      end)
--- }}}

-- Oil: dynamic file sorting {{{
local MyOil = augrp('MyOil', { clear = true })
aucmd({ 'BufEnter' }, { group = MyOil, callback = F.dynamic_dir_sort, pattern = 'oil:///*', })
-- E211 workaround (oil #762): drop buffers of files oil is about to delete
aucmd('User', { group = MyOil, pattern = 'OilActionsPre', callback = F.forget_deleted_buffers })
-- }}}

local oil_spec = {
    'stevearc/oil.nvim',

    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = { 'UIEnter', 'TabNew', 'WinNew', 'VimResume' },
    -- lazy = false, -- bug: open in external editor opens netrw instead of oil
    cmd = 'Oil',

    config = config_oil,
    init = init_oil,

    ---@type oil.SetupOpts
    opts = {

        -- {{{ config, keymaps
        skip_confirm_for_simple_edits = true,
        default_file_explorer = true, -- use oil instead of netrw
        keymaps = require('genja.map-oil').keymaps,
        -- }}}

        -- {{{ ui layout (modal?)
        float = {
            border = 'rounded',
            padding = 4, -- around the floating window
            max_width = 0,
            max_height = 0,
            win_options = { winblend = 0, },
            -- This is the config that will be passed to nvim_open_win.
            -- Change values here to customize the layout
            override = function(conf) return conf; end,
        },
        -- }}}

        -- {{{ ui main window (?)
        win_options = {
            concealcursor = 'nvic',
            cursorcolumn = false,
            conceallevel = 3,
            foldcolumn = '2', -- (sic) must be string
            signcolumn = 'yes',
            spell = false,
            list = false,
            wrap = false,
        },
        -- }}}

        -- {{{ ui listing options (keep it lean)
        -- todo: toggle ls -l mode
        -- todo: toggle ls -1rt mode
        -- todo: toggle du -sm * | sort -n mode
        -- todo: toggle du -sm * mode (no sort, just show sizes)
        -- todo: figure out how to hack recursive du -sm for dirs, and cache results for 1-2 hours
        columns = {
            { "size", }, -- even size is noise for the default view
            { "icon", add_padding = false },
        },
        -- }}}

        -- {{{ listing options
        view_options = {
            is_hidden_file = genja_oily_is_hidden_file,
            natural_order = false,
            case_insensitive = true,
            sort = {
                { 'type', 'asc' },
                { 'name', 'asc' },
            },
        },
        -- }}}

    },
}

---@type LazySpec
return {

    oil_spec,

    {
        -- oil's groups for which-key
        -- appended to the main spec's opts.spec (opts_extend)
        'folke/which-key.nvim',
        optional = true, -- loaded only if added somewhere else
        opts = { spec = require('genja.map-oil').which_key },
    },
}
