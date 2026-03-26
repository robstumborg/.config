---@type vim.lsp.Config
return {
  cmd = { 'intelephense', '--stdio' },
  filetypes = { 'php' },
  root_markers = { '.git', 'composer.json' },
  init_options = {
    licenseKey = '~/.config/intelephense/license.txt',
  },
  settings = {
    intelephense = {
      telemetry = {
        enabled = false,
      },
    },
  },
}
