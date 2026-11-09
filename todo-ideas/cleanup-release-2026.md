# Session Summary: On-Screen Nvim Assessment

Grok's feedback

**Date:** Sunday, November 08, 2026  
**Topic:** Review of <https://github.com/nvimos/onscreen> (On-Screen Nvim)

## Initial Assessment

On-Screen Nvim is a Neovim 0.11+ configuration/distribution that aims to feel like classic Vim (fast, plain, no lag) while providing a modern coding environment. It reacts against 2023-era distros that felt slow and full of visual bling.

**Strengths noted from README:**

- Clear philosophy: plain on the surface, capable underneath
- Performance focus (lazy loading, sub-second startup, no animated UI)
- Real automated test suite
- oil.nvim as file manager (no permanent sidebar)
- Quiet diagnostics, context-aware `<F2>` menu
- AI integration (Claude terminal, ask popup, commit message generation)
- Windows-first orientation
- Custom plugins extracted into separate repos (`genja-*.nvim`)

**Caveats:** Extremely new (0 stars/forks), install docs marked as draft, Linux untested, work-in-progress.

## Code Review

Examination of the repository structure revealed:

- Core logic in `lua/genja/` (mix of Lua and Vimscript)
- Large keymapping file (`map-zero.lua`)
- Dedicated F2 subsystem (builder, picker, registry, run modules)
- Several rough edges: zero-byte stub (`map-jolemak.lua`), multiple `unused-*` folders under `lazyp/`, large legacy `vimrc.almalinux.vim`, empty `ui/` directory, experimental `zexp-*` files, extensive todo files extending to 2028, and multiple alternate readmes

**Overall impression:** Architecture and testing approach show engineering maturity, but the surface still feels like a lab notebook with unfinished stubs and archival clutter.

## Polish Suggestions

1. Delete or complete the zero-byte `map-jolemak.lua` stub.
2. Collapse the six `unused-*` folders under `lazyp/` into a single archive or remove them.
3. Move or document `vimrc.almalinux.vim`.
4. Verify that `lazyp/` plugin specs actually resolve on a clean machine (install is untested).
5. Give `ui/gui-func-state` real content or remove the empty directory.
6. Consolidate the F2 subsystem’s multiple readmes into one.

## Removal Candidates

A list of relative paths was provided for potential cleanup, including:

- `lua/genja/map-jolemak.lua`
- All `lua/lazyp/unused-*` directories
- `lua/genja/vimrc.almalinux.vim`
- Experimental `zexp-*` files
- Extensive `todo-*.md` files and alternate readmes
- `do.not.readme.md`, `desktop.ini`, `doc-wip/`, `ws/`, `.claude/skills/`, and others

## Todo Item (in session style)

- Verify clean-machine install on Linux, not just Windows.
- Delete or fill the zero-byte `map-jolemak` stub and collapse the unused `lazyp` folders.
- Move or document `vimrc.almalinux.vim`.
- Give the empty `ui` directory real code or remove it.
- Trim the F2 subsystem readmes.
- **Opinion:** The bones are fresher than the surface. Real test suite, engineered F2 picker, and sub-second startup goals indicate active, competent work. Zero stars, untested Linux, empty stubs, and long-range todo files make it feel like promising infrastructure still in a lab phase rather than a finished distro.
