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
vim.pack.add({
  "https://github.com/lewis6991/gitsigns.nvim",
  "https://github.com/nvim-lua/plenary.nvim"
})
vim.o.updatetime = 100
vim.wo.signcolumn = "yes"

require("gitsigns").setup({
  -- show gitsigns in files tracked by yadm
  _on_attach_pre = function(_, callback)
    vim.schedule(function()
      local file = vim.fn.expand("%:p")
      if not vim.fn.filereadable(file) then
        return callback()
      end
      local repo = vim.fn.expand("~/.local/share/yadm/repo.git")
      require("plenary.job")
      :new({
        command = "yadm",
        args = { "ls-files", "--error-unmatch", file },
        on_exit = vim.schedule_wrap(function(_, return_val)
          if return_val == 0 then
            return callback({
              gitdir = repo,
              toplevel = os.getenv("HOME"),
            })
          else
            return callback()
          end
        end),
      })
      :sync()
    end)
  end,
})

vim.keymap.set({ "n", "v" }, "<leader>gah", ":Gitsigns stage_hunk<cr>", { desc = "git: stage this hunk" })
vim.keymap.set({ "n", "v" }, "<leader>guh", ":Gitsigns undo_stage_hunk<cr>", { desc = "git: undo stage this hunk" })
vim.keymap.set({ "n", "v" }, "<leader>grh", ":Gitsigns reset_hunk<cr>", { desc = "git: reset this hunk" })
vim.keymap.set("n", "<leader>gph", ":Gitsigns preview_hunk<cr>", { desc = "git: preview this hunk" })
vim.keymap.set("n", "<leader>gn", ":Gitsigns next_hunk<cr>", { desc = "git: browse to next hunk" })
vim.keymap.set("n", "<leader>gp", ":Gitsigns prev_hunk<cr>", { desc = "git: browse to previous hunk" })

-- use system clipboard
vim.o.clipboard = "unnamedplus"

-- use local clipboard when using neovim via ssh
vim.g.clipboard = {
  name = 'OSC 52',
  copy = {
    ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
    ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
  },
  paste = {
    ['+'] = require('vim.ui.clipboard.osc52').paste('+'),
    ['*'] = require('vim.ui.clipboard.osc52').paste('*'),
  },
}

