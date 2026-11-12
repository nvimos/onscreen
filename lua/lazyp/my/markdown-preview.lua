---@type LazySpec
return {
	{
        -- Needs node.
		-- Live preview of the markdown buffer in the browser.
        -- A Node app (app/, built with npm) runs a local web server;
        -- nvim sends it the buffer text and cursor on edits and moves,
		-- and the page renders it (markdown-it, KaTeX, mermaid) and scrolls along.
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		build = "cd app && npm install",
		init = function()
			vim.g.mkdp_filetypes = { "markdown" }
		end,
		ft = { "markdown" },
	},
}
