---@type vim.lsp.Config
return {
  cmd = { 'intelephense', '--stdio' },
  filetypes = { 'php' },
  root_markers = { '.git', 'composer.json' },
  init_options = {
    licenceKey = vim.fn.expand('~/intelephense/license.txt')
  },
  settings = {
    intelephense = {
      telemetry = {
        enabled = false,
      },
    },
  },
}
