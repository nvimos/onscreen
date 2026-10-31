-- netrw.nvim: file icons in netrw's sign column; netrw options stay in lua/genja/opt.lua.
-- Oil is the default explorer, so this only shows in :Explore / :Lexplore / scp:// listings.
-- Icons come from nvim-web-devicons, the same set oil uses.

---@type LazySpec
return {
    'prichrd/netrw.nvim',
    ft = 'netrw',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
        use_devicons = true,
        mappings = {},
    },
}
