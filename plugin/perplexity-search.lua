local function pplx(q)
  q = vim.trim(q or "")
  if q ~= "" then
    vim.ui.open("https://www.perplexity.ai/search?q=" .. vim.uri_encode(q))
  end
end

local map = vim.keymap.set
map("n", "<leader>pl", function() pplx(vim.api.nvim_get_current_line()) end, { desc = "Perplexity: line" })
map("n", "<leader>pw", function() pplx(vim.fn.expand("<cword>")) end, { desc = "Perplexity: word" })
map("n", "<leader>py", function() pplx(vim.fn.getreg('"')) end, { desc = "Perplexity: yank" })
map("x", "<leader>ps", function()
  local lines = vim.fn.getregion(
		vim.fn.getpos("v"),
		vim.fn.getpos("."), { type = vim.fn.mode() })
  pplx(table.concat(lines, "\n"))
end, { desc = "Perplexity: selection" })

vim.api.nvim_create_user_command(
	"Pplx",
	function(o) pplx(o.args) end,
	{ nargs = "+" })
