vim.pack.add({ 'https://github.com/nvim-treesitter/nvim-treesitter' }, { load = true })

require('nvim-treesitter').setup {
  install_dir = vim.fn.stdpath('data') .. '/site'
}

require('nvim-treesitter').install({ 'php', 'typescript', 'javascript', 'html', 'angular' }):wait(300000)
