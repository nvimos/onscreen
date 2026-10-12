
local filepath = vim.fn.expand("~/tmp/vim.env.txt")

vim.fn.mkdir(vim.fn.fnamemodify(filepath, ":h"), "p")

local file = io.open(filepath, "w")
if not file then
  vim.notify("Could not open or create file: " .. filepath, vim.log.levels.ERROR)
  return
end

for key, val in pairs(vim.fn.environ()) do
  file:write(string.format("%s = %s\n", key, tostring(val)))
end

file:close()
vim.notify("Environment variables written to " .. filepath)
