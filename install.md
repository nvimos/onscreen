# Install

Draft: written from the config as it is today; not yet tried on a clean machine.

## Requirements

Needed:

| Tool | Version | For |
|------|---------|-----|
| Neovim | 0.11+ | the editor; some features want 0.12; developed on 0.13-dev |
| git | any recent | lazy.nvim clones the plugins |
| curl | any | downloads (blink.cmp's prebuilt matcher, lookups) |
| ripgrep (`rg`) | any recent | live grep and live find (genja-finder) |
| `fd` (`fd-find`) | any recent | live find, faster than `rg` at listing files |

About finding files: `fd` is fine, and `rg` works in a pinch. Nevertheless, if you have ever used
computers before, you install Everything (and `es.exe`) on Windows, and let an index answer in milliseconds what a directory
walk answers in a coffee break. Live find tries `es`, then `fd`, then `rg`. And if you are on Linux
and not using `locate` (plocate), you are in no position to make snarky remarks about this config being
built on Windows 11.

Needed for parts of it:

| Tool | For |
|------|-----|
| Node.js + npm | Mason installs most language servers with npm (TypeScript, CSS, HTML, JSON, YAML, Bash) |
| Python 3 | Mason's pip packages: pyrefly, ruff, gitlint, the Makefile server, sqlfluff |
| PowerShell 7 (`pwsh`) | the tests (`tests/Makefile`), terminals, Windows helpers |
| GNU Make | the tests; `<F2>` make targets |
| Go | gopls (Mason builds it with `go install`), Go projects |
| PHP 8.2+ | phpactor; on Windows phpactor runs in a WSL distro set in `lua/genja/lsp/local.lua` |
| a C compiler (LLVM: `winget install LLVM.LLVM`) | building treesitter parsers |
| a Nerd Font | icons in the statusline and pickers |

Optional:

| Tool | For |
|------|-----|
| claude (Claude Code CLI) | the claude terminal and ask backends, commit messages |
| ollama | local models for ghost text and commit messages |
| gemini, aichat, gh copilot | other ask and commit backends |
| lazygit | the lazygit floaterm |
| glow | markdown preview in a pwsh window |
| WSL, Docker | the WSL and container tasks |

On Windows most of these come from winget, e.g.
`winget install Neovim.Neovim Git.Git BurntSushi.ripgrep.MSVC OpenJS.NodeJS.LTS Python.Python.3.13 Microsoft.PowerShell GoLang.Go`.

## The whole config

Clone it where Neovim looks for its config:

```powershell
git clone https://github.com/nvimos/onscreen.git $env:LOCALAPPDATA\nvim
nvim
```

On the first start lazy.nvim installs itself and the plugins, and Mason installs the language servers of the
languages that are on. The plugins written for this config (`genja-*.nvim`) come from their GitHub repos;
a local checkout in `plug-wip/<name>` is used instead when it is there.

Linux (`~/.config/nvim`) is not tested yet.

### Local files

Per-machine settings live in gitignored files; the config starts without them.

- `lua/genja/lsp/local.lua`: languages on or off on this machine, the WSL distro for phpactor.
- `lua/genja/local/startdirs.txt`: start directories (copy `startdirs.example.txt`).
- `lua/genja/local/secrets.lua`: API keys for the ghost text and LLM providers.

## Single plugins with lazy.nvim

Each `genja-*.nvim` plugin works on its own. Most need `genja-util.nvim`; list it as a dependency.
The plugin's own README has the full options.

Live grep and find pickers:

```lua
{
    'tox2ik/genja-finder.nvim',
    dependencies = { 'nvim-telescope/telescope.nvim', 'tox2ik/genja-util.nvim' },
    opts = {
        exclude = { 'node_modules', 'vendor', 'dist' },
    },
}
```

LSP servers and completion, one module per language:

```lua
{
    'tox2ik/genja-completion.nvim',
    name = 'genja-completion011.nvim',
    event = { 'BufReadPre', 'BufNewFile', 'VeryLazy' },
    cmd = 'Mason',
    dependencies = {
        'neovim/nvim-lspconfig',
        'mason-org/mason.nvim',
        'mason-org/mason-lspconfig.nvim',
        { 'saghen/blink.cmp', version = '1.*' },
    },
    opts = {},
    config = function(_, opts)
        require('genja.comps').setup(opts)
    end,
}
```

Commit popup, gitcommit lint and message generation:

```lua
{
    'tox2ik/genja-commit.nvim',
    dependencies = { 'tox2ik/genja-util.nvim' },
    ft = 'gitcommit',
    opts = {},
}
```

### Working on a plugin locally

To load a checkout instead of the GitHub repo, set `dir`. The config does it with a helper that falls back
to the repo when the folder is missing (`lua/genja/plug-wip.lua`):

```lua
local Wip = require('genja.plug-wip')

{
    'tox2ik/genja-finder.nvim',
    dir = Wip.dir('genja-finder.nvim'), -- plug-wip/genja-finder.nvim, or nil: lazy clones the repo
    dependencies = { { 'tox2ik/genja-util.nvim', dir = Wip.dir('genja-util.nvim') } },
}
```

A spec needs a trigger (`cmd`, `keys`, `ft`, `event`) or a `require` from somewhere, else lazy never loads it.
