-- file picker
vim.pack.add({"https://github.com/ibhagwan/fzf-lua"})

vim.keymap.set("n", "<c-p>", ":FzfLua files<cr>")
vim.keymap.set("n", "<c-f>", ":FzfLua live_grep<cr>")
