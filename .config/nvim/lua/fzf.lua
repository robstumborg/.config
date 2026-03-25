vim.pack.add({"https://github.com/ibhagwan/fzf-lua"})

-- avoids being slow to close
vim.opt.ttimeoutlen = 0

vim.keymap.set("n", "<c-p>", ":FzfLua files<cr>")
vim.keymap.set("n", "<c-f>", ":FzfLua live_grep<cr>")
vim.keymap.set("n", "<c-h>", ":FzfLua buffers<cr>")

local actions = require('fzf-lua.actions')
require('fzf-lua').setup({
  winopts = { preview = { title = true }},
  keymap = {
    builtin = {
      ["<C-d>"] = "preview-page-down",
      ["<C-u>"] = "preview-page-up",
      ["<C-p>"] = "toggle-preview",
    },
  },
  actions = {
    files = {
      ["ctrl-n"] = actions.toggle_ignore,
      ["ctrl-h"] = actions.toggle_hidden,
      ["enter"]  = actions.file_edit_or_qf,
    }
  },
})
