local ok, telescope = pcall(require, 'telescope')
if not ok then
    error 'Install nvim-telescope/telescope.nvim'
end

local opts = {}
local default_opts = {
	hex = true,
	rgb = false,
	alpha = 220,
}

local picker = require 'telescope._extensions.mycolors.picker'
return telescope.register_extension {
    setup = function(http_opts, _)
        opts = vim.tbl_extend('force', default_opts, http_opts)
    end,
    exports = {
        mycolors = function(o) picker(o, opts) end,
    },
}
