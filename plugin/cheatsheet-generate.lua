-- zumba code
-- :CheatsheetGenerate (or :lua CheatsheetGenerate()) dumps the current global
-- keymaps to <config>/cheatsheet.txt, one "description | key" line per mapping.

local modes = {
  { "n", "Normal" },
  { "i", "Insert" },
  { "v", "Visual + Select" },
  { "x", "Visual" },
  { "s", "Select" },
  { "o", "Operator-pending" },
  { "c", "Command-line" },
  { "t", "Terminal" },
  { "l", "Lang-arg" },
}

function CheatsheetGenerate()
  local path = vim.fn.stdpath("config") .. "/cheatsheet.txt"
  local lines = {
    "# Auto-generated cheatsheet from current keymaps",
    "# Generated on: " .. os.date("%Y-%m-%d %H:%M"),
    "",
  }
  local function add(s) lines[#lines + 1] = s end

  for _, mode in ipairs(modes) do
    local id, name = mode[1], mode[2]
    local maps = vim.api.nvim_get_keymap(id)
    if #maps > 0 then
      add(("## %s @mode-%s"):format(name, id))
      add("")
      for _, m in ipairs(maps) do
        local desc = (m.desc or "") ~= "" and m.desc or ("`%s`"):format(m.rhs or "")
        add(desc .. " | " .. m.lhs)
      end
      add("")
    end
  end

  local f, err = io.open(path, "w")
  if not f then
    return vim.notify("Cheatsheet: " .. err, vim.log.levels.ERROR)
  end
  f:write(table.concat(lines, "\n"))
  f:close()
  vim.notify("Wrote cheatsheet to: " .. path)
end

vim.api.nvim_create_user_command(
	"CheatsheetGenerate",
	CheatsheetGenerate, { desc = "Write keymap cheatsheet" })
