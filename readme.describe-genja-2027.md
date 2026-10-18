# genja compared to other configs

Question (2026-10-18): which known or lesser known nvim distributions, or
personal configs, do most of what genja does?

Based on `lazy-lock.json` and the file layout, compared from memory; the
upstream repos were not checked live.

## What defines genja

- Telescope for every picker (own live grep/find, action menu, `vim.ui.select`).
- oil + oil-git + `.oily`, aerial, dropbar, overseer (`<F2>` make targets).
- harpoon, undotree, fugitive, cloak, zen-mode, cellular-automaton.
- nvim-cmp + mason + native `vim.lsp.config`, in genja-completion011.
- PHP first (phpactor in WSL, neotest pest/phpunit, dap-php); Go via go.nvim.
- floaterm + toggleterm, Claude in a floaterm, codecompanion.
- Own statusline/tabline/winbar, jolemak layout, keymaps.nvim + which-key.
- Windows first; vim 9 fallback in `vimrc.almalinux.vim`.
- Not used: gitsigns, autopairs, surround, conform, lualine, colorscheme plugin.

## Closest personal configs

1. stevearc/dotfiles: author of oil, aerial, overseer, dressing; telescope +
   `vim.ui.select` overrides, own statusline, Windows support. Closest on tooling.
2. ThePrimeagen/init.lua: harpoon, undotree, fugitive, cloak, zen-mode,
   cellular-automaton, telescope. Closest on feel.
3. ray-x/nvim: author of go.nvim + guihua; Go side only.
4. vermaden (vendored in `lua/lazyp/others-vermaden/`): matches genja's past more than its present.

## Distributions, by overlap

1. kickstart.nvim / kickstart-modular: closest base (now blink.cmp).
2. LunarVim nvim-basic-ide / "Neovim from scratch": same plumbing, no
   oil/harpoon/overseer. LunarVim itself is unmaintained.
3. LazyVim + php, go, aerial, overseer, harpoon2, dap, test extras: most
   features (~60-70%), but snacks.picker, blink.cmp and lualine at the core.
4. AstroNvim, NvChad: furthest; heavy UI frameworks.

## Unique to genja

- Windows + phpactor-in-WSL bridge.
- vim 9 fallback file in the same tree.
- Live find with es/locate backends.
- `.oily` per-folder hiding in oil.
- jolemak layout maps.
- A CLAUDE.md per in-repo plugin.

Summary: Primeagen's plugin set on stevearc's tooling, with a PHP-on-Windows layer.
