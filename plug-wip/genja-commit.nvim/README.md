# genja-commit.nvim

Commit message popup, linting while typing, and a key that writes the message
from the staged diff.

## Features

- `require('genja-commit').open(dir)`: popup for the repo at `dir` (oil calls it).
  `:w` saves to the repo's `COMMIT_EDITMSG`; unsaved text is kept in memory and
  refilled on reopen (the newer of the two wins).
- Every `gitcommit` buffer:
  - lint while typing: [nvim-lint](https://github.com/mfussenegger/nvim-lint) +
    [gitlint](https://jorisroovers.com/gitlint/) when both are there, else
    built-in rules (title length, blank line 2, body line length);
  - `<M-g>`: write the message with `claude`, `copilot`, `gemini`, `aichat` (CLIs on PATH)
    or `ollama` (http, local server by default), the first available one in
    `generate.order`; inserted at the cursor; `<C-c>` cancels; the copilot, gemini
    and ollama backends are untested. Backends: `genja-util.nvim/lua/genja-util/llm.lua`;
  - `b:copilot_enabled` for copilot.vim ghost text.

## Popup keys

| key      | mode | action                          |
|----------|------|---------------------------------|
| `<C-CR>`, `<M-CR>`, `<C-s>` | n, i | commit (asks once on errors); only the last two arrive through Windows Terminal |
| `<M-u>`  | n, i | insert `update: <file>`         |
| `<M-g>`  | n, i | generate the message            |
| `<C-c>`  | n, i | cancel generating               |
| `<Esc>`, `q` | n | abort                          |
| `:w`     |      | save to `COMMIT_EDITMSG`        |

## Setup

```lua
{
	dir = '.../genja-commit.nvim',
	ft = 'gitcommit',
	opts = {
		window = 'split',     -- or 'float': the commit message window
		keys = { commit = { '<C-CR>', '<M-CR>', '<C-s>' }, fill = '<M-u>', abort = { '<Esc>', 'q' }, generate = '<M-g>', cancel = '<C-c>' },
		lint = { title_max = 65, body_max = 72, debounce = 300, install_gitlint = true },
		generate = {
			order = { 'claude', 'copilot', 'gemini', 'aichat', 'ollama' },
			timeout = 60,     -- seconds
			diff_max = 20000, -- bytes of staged diff sent
			subjects = 15,    -- recent subjects sent as style examples
			-- prompt = '...', replaces the built-in instructions
			claude = { model = 'haiku', effort = 'low' },
			copilot = { model = nil },
			gemini = { model = nil },
			aichat = { role = 'gitcommit', model = nil },
			-- http: OpenAI-compatible chat completions; local ollama unless end_point says otherwise
			ollama = { model = 'qwen3.5:0.8b', end_point = 'http://localhost:11434/v1/chat/completions', api_key = nil },
			-- own backends, named in order: { end_point, model, api_key } (http) or { exe, args } (cli)
			backends = {
				-- openrouter = { end_point = 'https://openrouter.ai/api/v1/chat/completions',
				--     model = 'deepseek/deepseek-v4-flash', api_key = function() return os.getenv('OPENROUTER_API_KEY') end },
			},
		},
		copilot = true,       -- set b:copilot_enabled in gitcommit buffers
		conventional = false, -- Conventional Commits mode, see below
		conventional_types = { 'feat', 'fix', 'docs', 'style', 'refactor', 'perf', 'test', 'build', 'ci', 'chore', 'revert' },
		on_commit = function(dir) end, -- after a popup commit succeeds
	},
}
```

gitlint is installed through Mason when Python is on PATH
(`lint.install_gitlint`).

## Conventional Commits mode

When on, `<M-g>` asks for `type(scope): description` and lets the model infer
type and scope from the diff, and the title must match that format (an error:
`<C-CR>` asks once). gitlint gets its `CT1` contrib rule.

First one set wins:

1. `git config genja-commit.conventional true|false`: this repo only (`.git/config`, not committed).
2. Project files: `commitlint.config.*`, `.commitlintrc*`, `commitlint` in `package.json`,
   `.czrc`, `.cz.*`, `cz.*`, `config.commitizen` in `package.json`, `[tool.commitizen]` in
   `pyproject.toml`, a `.gitlint` with `contrib-title-conventional-commits` (CT1).
3. `git config --global genja-commit.conventional true|false`: all repos.
4. `opts.conventional`.

Read when a commit buffer opens; reopen it after changing a setting.

With genja-completion011.nvim, nvim-cmp offers the types on the summary line,
scopes used before after `type(`, and footers (`BREAKING CHANGE:`, `Refs:`,
`Co-authored-by:`) at the start of body lines.

## To try it

1. `:Lazy install` (installs nvim-lint).
2. Stage something, open oil in the repo, press `ggc` (or `<LocalLeader>c`).
3. In the popup: type a title over 65 chars or text on line 2 to see the
   diagnostics; `<M-g>` to generate a message; `:w`, close, reopen to see the
   draft come back; `<C-CR>` to commit.
4. `git commit` from a terminal with nvim as the editor: lint, `<M-g>` and
   copilot ghost text (`<M-f>` accepts) work there too.
5. copilot backend (untested): `<M-g>` pipes the prompt with no `-p`; copilot
   ignores piped input when `-p` is given (docs: "Run Copilot CLI programmatically").
   Check it in the repo:

   ```sh
   git diff --cached | copilot -s --no-ask-user
   ```

   If the answer mentions your changes, it works.
6. Conventional Commits mode: `git config genja-commit.conventional true` in
   a repo, reopen the popup, then `<M-g>` (expect `type(scope): description`)
   or type a title without a type (expect an error; `<C-CR>` asks once).
   `git config --unset genja-commit.conventional` undoes it.
   Completion: at the start of the title (`<C-Space>` if no menu shows), after
   `fix(`, and at the start of a body line.

## Installing the CLIs

Both are Node/TypeScript programs from npm.

- copilot (needs a paid Copilot plan; `gh copilot` is retired):
  - `winget install GitHub.Copilot`: no global Node needed and no `.cmd`
    shim (so no 8191-char command-line cap), or
  - `npm install -g @github/copilot`: Node.js 22+.
  - First run: `copilot`, then `/login`.
- gemini:
  - `npm install -g @google/gemini-cli`: Node.js 20+ (checked at first run,
    not at install), then `gemini --version`.
