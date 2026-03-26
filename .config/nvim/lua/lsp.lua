vim.lsp.enable({
  "intelephense",
  "ts_ls",
  "eslint",
  "angularls",
})

vim.diagnostic.config({ virtual_text = false })

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
