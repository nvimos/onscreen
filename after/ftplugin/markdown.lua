-- Markdown: fold by treesitter (headings nest, fenced code folds too).
-- Folds deeper than level 3 start closed.

local wo = vim.wo[0][0]

wo.foldmethod = 'expr'
wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
wo.foldlevel = 3
-- The fold column shows a digit instead of the line once folds nest deeper than its width. Headings nest
-- up to six deep, so it grows to fit (at most 9) and draws the vertical line at every depth.
wo.foldcolumn = 'auto:9'

-- <!-- comments -->: gray, no background, in markdown windows only (highlight groups are global).
-- Treesitter (the html injection) and the html syntax each have their own comment group.
local comment = '@comment.html:MdComment,htmlComment:MdComment,htmlCommentPart:MdComment'
if wo.winhighlight == '' then
    wo.winhighlight = comment
elseif not wo.winhighlight:find(comment, 1, true) then -- sourced again: don't add it twice
    wo.winhighlight = wo.winhighlight .. ',' .. comment
end
wo.foldtext = "v:lua.require'genja.ext.md-foldtext'.text()" -- first line, highlighted, no line count
