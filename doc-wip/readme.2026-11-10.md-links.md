# Markdown: bare URLs to inline links (2026-11-10)

What: `<F2>` > `markdown  inline links from urls` turns bare `http(s)://` addresses into `[name](url)`.
Where: `lua/genja/ext/md-links.lua`, registered in `after/ftplugin/markdown.vim`; tests `tests/md/test_md_links.lua`.

- Range: the cursor line, or the selected lines when `<F2>` is pressed in visual mode (like `checklist toggle`).
- Name: the path without query and fragment, percent escapes decoded (`tox2ik/genja-util.nvim`).
  Longer than 60 chars: only the last part (`page.html`). No path: the host.
- Left alone: links `[t](url)`, autolinks `<url>`, `code spans` and fenced code.
- A trailing `.`, `,`, `:` ... stays outside the link.

## Test

1. In a markdown file write `see https://github.com/tox2ik/genja-util.nvim?tab=readme.`
2. `<F2>`, type `inline`, `<CR>`: the line reads `see [tox2ik/genja-util.nvim](https://github.com/tox2ik/genja-util.nvim?tab=readme).`
3. Select three lines with URLs, one already a link, `<F2>` > same item: only the bare ones change.
4. A URL with a long path: the name is the last path part.
