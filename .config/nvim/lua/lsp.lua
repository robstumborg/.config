vim.lsp.enable({
  "intelephense",
  "ts_ls",
  "eslint",
  "angularls",
})

vim.diagnostic.config({
  virtual_text = false,
  -- lsp stuff for minimal status line
  status = {
    format = function(counts)
      local icons = {
        [vim.diagnostic.severity.ERROR] = "E",
        [vim.diagnostic.severity.WARN]  = "W",
        [vim.diagnostic.severity.INFO]  = "I",
        [vim.diagnostic.severity.HINT]  = "H",
      }
      local hl_map = {
        [vim.diagnostic.severity.ERROR] = "DiagnosticError",
        [vim.diagnostic.severity.WARN]  = "DiagnosticWarn",
        [vim.diagnostic.severity.INFO]  = "DiagnosticInfo",
        [vim.diagnostic.severity.HINT]  = "DiagnosticHint",
      }
      local parts = {}
      for _, sev in ipairs({
        vim.diagnostic.severity.ERROR,
        vim.diagnostic.severity.WARN,
        vim.diagnostic.severity.INFO,
        vim.diagnostic.severity.HINT,
      }) do
        local n = counts[sev]
        if n and n > 0 then
          table.insert(parts, ("%%#%s#%s:%d%%*"):format(hl_map[sev], icons[sev], n))
        end
      end
      return table.concat(parts, " ")
    end,
  },
})

-- lsp keybinds
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', '<leader>cr', vim.lsp.buf.rename, opts)

    local diag_opts = { severity = { min = vim.diagnostic.severity.WARN }, float = true }
    vim.keymap.set('n', ']e', function() vim.diagnostic.goto_next(diag_opts) end, { buffer = ev.buf})
    vim.keymap.set('n', '[e', function() vim.diagnostic.goto_prev(diag_opts) end, { buffer = ev.buf})
  end,
})
