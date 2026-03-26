-- nvim-tree
vim.pack.add({"https://github.com/nvim-tree/nvim-tree.lua"})
require("nvim-tree").setup({
	on_attach = function(bufnr)
		local api = require("nvim-tree.api")
		api.config.mappings.default_on_attach(bufnr)
		vim.keymap.set("n", "s", "", { buffer = bufnr })
		vim.keymap.del("n", "s", { buffer = bufnr })
	end,

	view = {
		relativenumber = true,
		side = "right",
		width = 40,
	},
})

vim.keymap.set("n", "<c-b>", ":NvimTreeToggle<cr>")

