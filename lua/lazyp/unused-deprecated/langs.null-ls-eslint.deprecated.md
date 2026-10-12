```markdown
# From `null-ls` to the modern ESLint setup

## Why `null-ls` was archived

`jose-elias-alvarez/null-ls.nvim` was archived on 12 August 2023 because its maintainer no longer had the time or energy to maintain it, and no longer used Neovim as his primary editor. Rather than leave an inactive repository looking maintained, he made it read-only.

The maintainer also cited structural maintenance problems:

- `null-ls` relied on internal or unstable parts of Neovim’s LSP-related behavior, so Neovim updates could break it.
- It shipped nearly 300 built-in sources, creating a very large compatibility surface.
- Its source architecture was difficult to evolve without breaking users’ configurations.

## Why `none-ls` was forked

`nvimtools/none-ls.nvim` was created as a community-maintained fork to keep `null-ls` usable after the original project became read-only. It is a drop-in replacement: the repository and maintenance changed, but the Lua module is still `require('null-ls')`.

The fork exists mainly to preserve existing configurations and maintain compatibility with newer Neovim versions. It does not fundamentally replace the old architecture; it continues it.

## Modern replacement

For ESLint, the cleanest modern approach is to remove both `eslint.nvim` and `none-ls` and use ESLint’s own language server through `nvim-lspconfig`.

This provides:

- Diagnostics while editing
- Code actions, including quick fixes
- `eslint-disable` comment generation
- `EslintFixAll` for applying available fixes
- Native LSP integration without an intermediary plugin

Install the ESLint language server, for example with npm:

```bash
npm install -g @vscode/eslint-lsp
```

Or install `vscode-eslint-language-server` through Mason.

## Recommended configuration

```lua
return {
  {
    'neovim/nvim-lspconfig',
    ft = {
      'javascript',
      'javascriptreact',
      'typescript',
      'typescriptreact',
      'vue',
      'svelte',
    },
    config = function()
      local lspconfig = require('lspconfig')

      lspconfig.eslint.setup({
        settings = {
          workingDirectories = { mode = 'auto' },
          experimental = {
            useFlatConfig = true,
          },
        },
        on_attach = function(client, bufnr)
          -- Apply available ESLint fixes before saving.
          vim.api.nvim_create_autocmd('BufWritePre', {
            buffer = bufnr,
            command = 'EslintFixAll',
          })

          vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, {
            buffer = bufnr,
            desc = 'Code action',
          })
        end,
      })
    end,
  },
}
```

`nvim-lspconfig` supplies the `EslintFixAll` command. Attaching it to `BufWritePre` reproduces the old `apply_on_save` behavior from `eslint.nvim`.

## Feature mapping

| Old feature | Modern equivalent |
|---|---|
| Diagnostics while typing | ESLint LSP diagnostics |
| Code actions | `vim.lsp.buf.code_action()` |
| Fixes on save | `EslintFixAll` in a `BufWritePre` autocmd |
| Disable-rule comments | ESLint LSP code action |
| `eslint_d` daemon | Usually unnecessary; the ESLint language server is persistent |
| ESLint formatting | `EslintFixAll`, or `conform.nvim` with Prettier |

## Lighter alternative

If you only need lint diagnostics and formatting, use `nvim-lint` plus `conform.nvim`:

```lua
-- Diagnostics
require('lint').linters_by_ft = {
  javascript = { 'eslint_d' },
  typescript = { 'eslint_d' },
  javascriptreact = { 'eslint_d' },
  typescriptreact = { 'eslint_d' },
}

-- Formatting / fixes
require('conform').setup({
  formatters_by_ft = {
    javascript = { 'eslint_d' },
    typescript = { 'eslint_d' },
    javascriptreact = { 'eslint_d' },
    typescriptreact = { 'eslint_d' },
  },
  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
  },
})
```

This route is simpler, but it does not provide the same rich code-action experience as the ESLint language server.

## Recommendation

Use `nvim-lspconfig` with the ESLint language server for diagnostics and code actions. Add `EslintFixAll` on save only if you actually want automatic fixing. Use `conform.nvim` with Prettier separately if your project uses Prettier for formatting.

This avoids the archived `null-ls`, avoids the compatibility-focused `none-ls` fork, and uses ESLint’s maintained LSP integration directly.
```
