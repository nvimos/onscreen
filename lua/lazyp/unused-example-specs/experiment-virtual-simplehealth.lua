-- virtual plugin experiment (not downloaded, declared inline)
---@type LazyPluginSpec
return {
  "simple-checkhealth",
  enabled = false,
  virtual = true, -- Tells Lazy it's an inline configuration
  -- defaults.lazy = true (lazy-plug-spec.lua), so the spec needs explicit triggers
  cmd = "CheckHealthLspSimple",
  keys = {
    { "<leader>ch", "<cmd>CheckHealthLspSimple<CR>", desc = "Simple LSP health check" },
  },
  config = function()
    local ns = vim.api.nvim_create_namespace("simple_lsp_checkhealth")

    -- Workspace folders of a client, falling back to its root dir.
    local function workspaces(client)
      local dirs = {}
      local folders = client.workspace_folders or (client.config and client.config.workspace_folders) or {}
      for _, folder in ipairs(folders) do
        dirs[#dirs + 1] = folder.uri and vim.uri_to_fname(folder.uri) or tostring(folder.name)
      end
      if #dirs == 0 then
        local root = client.root_dir or (client.config and client.config.root_dir)
        if root then
          dirs[1] = tostring(root)
        end
      end
      return dirs
    end

    -- Checks the buffer the command was run from.
    --   PASS: at least one LSP server is attached to it
    --   FAIL: servers are running but none is attached to it, or none is running
    -- Returns the float content: lines, per-line highlights, verdict, verdict highlight.
    local function check_lsp()
      local buf = vim.api.nvim_get_current_buf()
      local bufname = vim.api.nvim_buf_get_name(buf)
      local ft = vim.bo[buf].filetype

      local attached, others = {}, {}
      for _, client in ipairs((vim.lsp.get_clients or vim.lsp.get_active_clients)()) do
        if client.attached_buffers and client.attached_buffers[buf] then
          attached[#attached + 1] = client
        else
          others[#others + 1] = client
        end
      end
      local function by_id(a, b)
        return a.id < b.id
      end
      table.sort(attached, by_id)
      table.sort(others, by_id)

      local verdict, detail, hl
      if #attached > 0 then
        verdict, hl = "PASS", "DiagnosticOk"
        detail = ("%d LSP server(s) attached to this buffer"):format(#attached)
      elseif #others > 0 then
        verdict, hl = "FAIL", "DiagnosticWarn"
        detail = ("no LSP server attached to this buffer (%d running for other buffers)"):format(#others)
      else
        verdict, hl = "FAIL", "DiagnosticError"
        detail = "no active LSP server"
      end

      local out, marks = {}, {}
      local function add(text, group)
        out[#out + 1] = text
        marks[#marks + 1] = group or false
      end

      local function describe(client, group)
        local nbufs = vim.tbl_count(client.attached_buffers or {})
        add(("  %s (id %d, %d buffer(s))"):format(client.name, client.id, nbufs), group)
        local filetypes = client.config and client.config.filetypes
        if type(filetypes) == "table" and #filetypes > 0 then
          add("    languages: " .. table.concat(filetypes, ", "))
        end
        local dirs = workspaces(client)
        if #dirs == 0 then
          add("    workspace: none (single-file mode)")
        end
        for _, dir in ipairs(dirs) do
          add("    workspace: " .. dir)
        end
      end

      add(verdict .. "  " .. detail, hl)
      if verdict == "FAIL" then
        add("  full LSP report: :checkhealth vim.lsp", "Comment")
      end
      add("")

      add("Current buffer", "Title")
      add("  file: " .. (bufname ~= "" and vim.fn.fnamemodify(bufname, ":~:.") or "[No Name]"))
      add("  language: " .. (ft ~= "" and ft or "none detected"))

      if #attached > 0 then
        add("LSP servers attached to this buffer", "Title")
        for _, client in ipairs(attached) do
          describe(client, "DiagnosticOk")
        end
      end
      if #others > 0 then
        add("LSP servers running for other buffers", "Title")
        for _, client in ipairs(others) do
          describe(client)
        end
      end

      return out, marks, verdict, hl
    end

    local function show(out, marks, verdict, hl)
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, out)
      for i, group in ipairs(marks) do
        if group then
          vim.api.nvim_buf_set_extmark(buf, ns, i - 1, 0, { end_col = #out[i], hl_group = group })
        end
      end
      vim.bo[buf].bufhidden = "wipe" -- no hidden buffer left behind per run
      vim.bo[buf].modifiable = false

      -- Float sized to its content; height accounts for wrapped lines
      local longest = 0
      for _, text in ipairs(out) do
        longest = math.max(longest, vim.fn.strdisplaywidth(text))
      end
      local max_width = math.max(20, math.floor(vim.o.columns * 0.85))
      local width = math.min(math.max(longest + 2, 50), max_width)
      local height = 0
      for _, text in ipairs(out) do
        height = height + math.max(1, math.ceil(vim.fn.strdisplaywidth(text) / width))
      end
      height = math.max(1, math.min(height, math.floor(vim.o.lines * 0.6)))

      local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = width,
        height = height,
        row = math.max(0, math.floor((vim.o.lines - height) / 2) - 1),
        col = math.max(0, math.floor((vim.o.columns - width) / 2)),
        style = "minimal",
        border = "rounded",
        title = { { (" LSP check: %s "):format(verdict), hl } },
        title_pos = "center",
      })
      vim.wo[win].wrap = true

      for _, lhs in ipairs({ "q", "<Esc>" }) do
        vim.keymap.set("n", lhs, "<cmd>close<CR>", { buffer = buf, silent = true, nowait = true })
      end
    end

    vim.api.nvim_create_user_command("CheckHealthLspSimple", function()
      -- check first: opening the float changes the current buffer
      show(check_lsp())
    end, { desc = "Confirm an LSP server is active for the current buffer" })
  end,
}
