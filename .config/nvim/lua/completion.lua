-- autopairs
vim.pack.add({"https://github.com/windwp/nvim-autopairs"})
require('nvim-autopairs').setup()

-- blink autocompletion
vim.pack.add({
  { src = "https://github.com/saghen/blink.cmp", version = vim.version.range("^1") },
})

require('blink.cmp').setup({
  fuzzy = { implementation = 'prefer_rust_with_warning' },
  signature = { 
    enabled = true,
    window = { border = "rounded" },
  },
  keymap = {
    ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
    ["<C-e>"] = { "hide", "fallback" },
    ["<CR>"] = { "accept", "fallback" },

    ["<Tab>"] = {
      function(cmp)
        return cmp.select_next()
      end,
      "snippet_forward",
      "fallback",
    },
    ["<S-Tab>"] = {
      function(cmp)
        return cmp.select_prev()
      end,
      "snippet_backward",
      "fallback",
    },

    ["<Up>"] = { "select_prev", "fallback" },
    ["<Down>"] = { "select_next", "fallback" },
    ["<C-u>"] = { "scroll_documentation_up", "fallback" },
    ["<C-d>"] = { "scroll_documentation_down", "fallback" },
  },

  appearance = {
    use_nvim_cmp_as_default = true,
    nerd_font_variant = "normal",
  },

  completion = {
    accept = { auto_brackets = { enabled = true } },
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 250,
      treesitter_highlighting = true,
      window = { border = "rounded" }
    }
  },

  cmdline = {
    keymap = {
      ['<Tab>'] = { 'accept' },
      ['<CR>'] = { 'accept_and_enter', 'fallback' },
    },
    -- (optionally) automatically show the menu
    completion = { menu = { auto_show = true } }
  },

  sources = {
    default = {
      "lsp"
    },
    providers = {
      cmdline = {
        min_keyword_length = function(ctx)
          -- when typing a command, only show when the keyword is 3 characters or longer
          if ctx.mode == 'cmdline' and string.find(ctx.line, ' ') == nil then return 3 end
          return 0
        end
      }
    }
  }
})

