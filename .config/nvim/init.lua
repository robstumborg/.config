vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- theme
vim.pack.add({"https://github.com/folke/tokyonight.nvim"})
vim.cmd("colorscheme tokyonight-night")

-- enable 24-bit color
vim.o.termguicolors = true

-- relative line numbers
vim.wo.relativenumber = true

-- number of screen lines to keep above and below the cursor
vim.o.scrolloff = 15

-- mouse mode
vim.o.mouse = "a"

-- break indent
vim.o.breakindent = true

-- undo history
vim.o.undofile = true
vim.o.undodir = vim.fn.stdpath("state") .. "/undo"

-- search settings
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.hlsearch = true

-- set completeopt to have a better completion experience
vim.o.completeopt = "menuone,noselect"

-- indenting
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true

-- backup
vim.opt.backup = false
vim.opt.writebackup = false

-- git integration
vim.pack.add({"https://github.com/lewis6991/gitsigns.nvim"})
vim.o.updatetime = 100
vim.wo.signcolumn = "yes"

