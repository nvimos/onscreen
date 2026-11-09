- [x] like the markdown F2 context action to convert list items into
      checkboxes, add one more. ConvertHTTP addresses including HTTPS into
      markdown links, links that are inline.
      the name should be the path of the link and if it's longer than
      45-60 characters then do a basename on it and exclude any query
      parameters
  - [x] lua/genja/ext/md-links.lua, `<F2>` > markdown: inline links from urls; visual range or cursor line, 60 chars (2026-11-10)
  - [x] tests/md/test_md_links.lua (make test D=md passes)
  - [ ] test: guide doc-wip/readme.2026-11-10.md-links.md
