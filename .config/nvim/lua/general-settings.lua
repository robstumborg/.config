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

-- split keybinds
vim.keymap.set("n", "ss", ":split<cr>", { silent = true })
vim.keymap.set("n", "sv", ":vsplit<cr>", { silent = true })
vim.keymap.set("n", "sc", ":close<cr>", { silent = true })
vim.keymap.set("n", "sh", "<c-w>h", { silent = true })
vim.keymap.set("n", "sj", "<c-w>j", { silent = true })
vim.keymap.set("n", "sk", "<c-w>k", { silent = true })
vim.keymap.set("n", "sl", "<c-w>l", { silent = true })

-- new file, save file, destroy buffer
vim.keymap.set("n", "<c-n>", ":enew<cr>", { silent = true })
vim.keymap.set("n", "<c-w>", ":bd!<cr>", { silent = true, nowait = true })

-- deal w/ word wrap (treat wrapped lines as their own)
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- toggle highlight
vim.keymap.set("n", "<left>", ":set hls!<cr>", { silent = true })

-- toggle wordwrap
vim.keymap.set("n", "<a-z>", ":set wrap!<cr>", { silent = true })

-- cycle colorcolumn (off, 80, 120)
vim.keymap.set("n", "<a-c>", function()
	vim.o.colorcolumn = (vim.o.colorcolumn == "") and "80" or (vim.o.colorcolumn == "80") and "120" or ""
end)

-- :W -> :w alias
vim.api.nvim_create_user_command("W", "w", {})

-- highlight on yank
local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = "*",
})

