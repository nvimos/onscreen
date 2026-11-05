# Go tests through neotest (2026-11-05)

auto-todo M. Spec: `lua/lazyp/langs/php-neotest.lua` (now PHP and Go; `ft = { 'php', 'go' }`).

## What it does

- neotest-golang (`go test`) next to the pest and phpunit adapters: Go tests use the same keys and
  summary panel as PHP tests.
- go.nvim's `:GoTest`, `:GoTestFunc`, `:GoTestFile` stay as they are.

## Keys (lua/genja/map-plugin/php-neotest.lua)

`<leader>Tr` nearest, `<leader>Tf` file, `<leader>Ts` summary, `<leader>To` output.

## Test

1. Open a Go module with a `_test.go` file (e.g. add `greet/greet_test.go` to
   `plug-wip/genja-completion011.nvim/examples/go`).
2. Cursor in a `TestXxx`, `<leader>Tr`: a sign shows pass or fail.
3. `<leader>Ts`: the summary lists the file's tests; `<leader>To` shows the go test output.
4. `:GoTestFunc` still works as before.
