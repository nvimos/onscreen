-- Markdown: fold by treesitter (headings nest, fenced code folds too).
-- Folds deeper than level 3 start closed.

local wo = vim.wo[0][0]

wo.foldmethod = 'expr'
wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
wo.foldlevel = 3

-- <!-- comments -->: gray with a gray background, in markdown windows only (highlight groups are global).
-- Treesitter (the html injection) and the html syntax each have their own comment group.
local comment = '@comment.html:MdComment,htmlComment:MdComment,htmlCommentPart:MdComment'
if wo.winhighlight == '' then
    wo.winhighlight = comment
elseif not wo.winhighlight:find(comment, 1, true) then -- sourced again: don't add it twice
    wo.winhighlight = wo.winhighlight .. ',' .. comment
end
wo.foldtext = "v:lua.require'genja.ext.md-foldtext'.text()" -- first line, highlighted, no line count
