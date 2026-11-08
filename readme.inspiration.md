# Inspiration

Lis of other's work that was used as a starting point in 2023 and as benchmarks or reference points later on in 2026.

## Docs

- [nvim Lua manual: interacting](https://jacobsimpson.github.io/nvim-lua-manual/docs/interacting/)


## v2026

### Distros, Tutorials, Examples

| Distro | Description |
| --- | --- |
| [Neovim-from-scratch](https://github.com/LunarVim/Neovim-from-scratch/tree/master/lua/user) | LunarVim author's step-by-step config tutorial |
| [AstroCommunity](https://github.com/AstroNvim/astrocommunity) | Community language packs and plugin specs for AstroNvim |
| [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim/tree/master/lua/kickstart/plugins) | Small, readable starting point to fork and own |
| [nvim-lazyman](https://github.com/doctorfree/nvim-lazyman) | Installs and switches between many distros; its [wiki lists them](https://github.com/doctorfree/nvim-lazyman/wiki/Configuration_Distributions) |
| [NormalNvim](https://github.com/NormalNvim/NormalNvim) | "A normal Neovim distribution"; a fork of AstroNvim |
| [CosmicNvim](https://github.com/CosmicNvim/CosmicNvim) | Lightweight, opinionated config for web development |
| [AstroNvim](https://github.com/AstroNvim/AstroNvim) | Feature-rich, IDE-like distro with a plugin core |
| [mini.nvim](https://github.com/echasnovski/mini.nvim) | Library of 45+ independent modules; not a distro, but a base many build on |
| [LunarVim](https://github.com/LunarVim/LunarVim) | IDE layer for Neovim, community driven |
| [SpaceVim](https://github.com/SpaceVim/SpaceVim) | Modular configuration for Vim and Neovim, Spacemacs style |
| [LazyVim](https://github.com/LazyVim/LazyVim) | Full setup on lazy.nvim; language extras to enable per language |
| [NvChad](https://github.com/NvChad/NvChad) | Fast framework with solid defaults and a polished UI; base46 themes |
| [Ecovim](https://github.com/ecosse3/nvim) | Non-minimal config built for front-end development |
| [evim](https://github.com/e-cal/evim) | Personal distro by e-cal |

### Competition

What the other nvim distributions taught us (see CLAUDE.md, Goal):

- Before building a feature, survey what others built. Use theirs only if its interface fits our mental model; otherwise build our own and take the ideas that work.
- Slow and un-Vim-like: animated notifications, sliding messages inside the nvim UI, typing input that lags. Vim's responsiveness is the bar.
- Good starting points exist, but without coding workflows built on LSP that work together (completion, diagnostics, lint, tests, git, AI).
- Nobody ships a configured experience for mixed projects, e.g. a Drupal site, or a Symfony app with a React front end and a test framework.
- LazyVim language extras and AstroCommunity packs are worth surveying before adding a language: take their choices, not their files.
- Always-on sidebars (file trees, outlines) eat screen space that text needs. Oil, a buffer you edit, fits instead.
- Some are bloated, others too small; there is room for a ready-to-go setup in between.
- Not a contest: no claim to be better than other distributions.

## v2023

### Plugin manager and configs

- [folke/lazy.nvim](https://github.com/folke/lazy.nvim)
- [ThePrimeagen/init.lua](https://github.com/ThePrimeagen/init.lua)
- [Traap/nvim](https://github.com/Traap/nvim): old timer with his own system

### Examples

- [s1n7ax gists](https://gist.github.com/s1n7ax)
- [s1n7ax: generate doc-comments](https://gist.github.com/s1n7ax/6885a550633fa8a285fdef2c0f8044ad)
- [wincent: leader mappings](https://github.com/wincent/wincent/blob/aa3a322e3a911dabe0ef398ebb1fd7c77209b8ac/roles/dotfiles/files/.vim/plugin/mappings/leader.vim)

### Plugins

- [vim-devicons on VimAwesome](https://vimawesome.com/plugin/vim-devicons)
