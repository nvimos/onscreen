local Wip = require('genja.plug-wip')

---@type LazySpec
return {
    'tox2ik/genja-completion.nvim',
    name = 'genja-completion011.nvim', -- the repo's name is shorter
    dir = Wip.dir('genja-completion011.nvim'),

    -- MasonInstall: headless `make mason-luals` runs before VeryLazy fires.
    cmd = { 'Mason', 'MasonInstall' },
    event = {
        -- BufReadPre,
        -- BufNewFile: enable servers before the first file's FileType.
        'BufReadPre', 'BufNewFile',

        -- VeryLazy: cmdline completion is ready on an empty start screen too.
        'VeryLazy' },
    dependencies = {
        'saghen/blink.cmp', -- lua/lazyp/langs-comps/blink-cmp.lua
        'neovim/nvim-lspconfig', -- lua/lazyp/comps/nvim-lspconfig.lua
    },

    ---@type genja.Opts
    opts = {
        lsp = {
            enabled = {
                -- files from lua/genja/lang/*.lua
                bash       = true,
                powershell = true,
                lua        = true,
                json       = true,
                vim        = true,
                go         = true,
                php        = true,
                python     = true,
                gitconfig  = true,
                sshconfig  = true,
                c_cpp      = false,
                typescript = false,
            },

            mason = { ui = { border = 'double' } }, -- for require('mason').setup()
            -- for vim.diagnostic.config()
            diagnostics = {
                virtual_text = true,
                severity_sort = true
            },
        },
        completion = {
            features = {
                'keymaps',
                'snippets',
                'lsp',
                'path',
                'gitignore',
                'sshconfig',
                'gitcommit',
                'dictionary',
                'buffer',
                'lazydev',
                'minuet', -- lua/genja/completion/minuet.lua (config side), after 'keymaps'
                'cmdline',
                'appearance'
            },
        },
    },

    ---@param opts genja.Opts
    config = function(_, opts)
        local Safeload = require('genja.api').Safeload
        Safeload('genja.comps', function(genja_comps)
            genja_comps.setup(opts)
        end)
    end
}
