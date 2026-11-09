# Go: treesitter parsers templ and proto (2026-11-10)

What: highlighting, folds and textobjects for templ components (`.templ`) and protobuf files (`.proto`).
Where: `lua/lazyp/my/load-treesitter.lua`, next to `gomod`, `gosum`, `gotmpl`.
sql comes with PR-langs, dockerfile with PR-wsl-docker.

The parsers are built on the next start when a C compiler is found (clang-cl from `winget install LLVM.LLVM`).

## Test

1. Start nvim once and wait for `tree-sitter-templ` and `tree-sitter-proto` to finish.
2. Open a `.templ` file: `:InspectTree` shows a templ tree, `templ` components are highlighted.
3. Open a `.proto` file: `message`, `service`, `rpc` are highlighted; `:InspectTree` shows a proto tree.
