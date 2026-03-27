-- tabline.lua
-- minimal buffer bar using neovim built-ins, no plugins
-- colors match tokyonight-night palette (mirrors status-line.lua)

-- ─────────────────────────────────────────────────────────────
-- palette
-- ─────────────────────────────────────────────────────────────
local colors = {
  bg         = "#1a1b26",  -- main background
  bg_active  = "#292e42",  -- active buffer highlight
  fg         = "#c0caf5",  -- active buffer text
  dim        = "#565f89",  -- inactive buffer text
  yellow     = "#e0af68",  -- modified indicator
}

-- ─────────────────────────────────────────────────────────────
-- highlight groups
-- ─────────────────────────────────────────────────────────────
local function setup_highlights()
  local set = vim.api.nvim_set_hl
  set(0, "TabLineBufActive",     { fg = colors.fg,     bg = colors.bg_active, bold = true })
  set(0, "TabLineBufInactive",   { fg = colors.dim,    bg = colors.bg })
  set(0, "TabLineBufModActive",  { fg = colors.yellow, bg = colors.bg_active })
  set(0, "TabLineBufModInactive",{ fg = colors.yellow, bg = colors.bg })
  set(0, "TabLineFill",          { fg = colors.bg,     bg = colors.bg })
end

-- ─────────────────────────────────────────────────────────────
-- helpers
-- ─────────────────────────────────────────────────────────────

-- return all listed, loaded buffers
local function listed_buffers()
  local bufs = {}
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[b].buflisted then
      table.insert(bufs, b)
    end
  end
  return bufs
end

-- given a list of buffers, build a map of bufnr → shortest unique path suffix
-- e.g. backend/services.md vs frontend/services.md instead of full paths
local function display_names(bufs)
  -- split a relative path into segments, leaf first
  local function segments(path)
    local parts = {}
    for seg in path:gmatch("[^/\\]+") do
      table.insert(parts, 1, seg)
    end
    return parts
  end

  -- build per-buffer state: reversed segments + current depth
  local state = {}
  for _, b in ipairs(bufs) do
    local full = vim.api.nvim_buf_get_name(b)
    if full == "" then
      state[b] = { fixed = true, name = "[No Name]" }
    else
      local rel = vim.fn.fnamemodify(full, ":~:.")
      state[b] = { fixed = false, segs = segments(rel), depth = 1 }
    end
  end

  -- widen depth for any buffers whose display suffix collides
  local changed = true
  while changed do
    changed = false
    local seen = {}
    for _, b in ipairs(bufs) do
      local s = state[b]
      if not s.fixed then
        local parts = {}
        for i = s.depth, 1, -1 do table.insert(parts, s.segs[i]) end
        local display = table.concat(parts, "/")
        seen[display] = seen[display] or {}
        table.insert(seen[display], b)
      end
    end
    for _, group in pairs(seen) do
      if #group > 1 then
        for _, b in ipairs(group) do
          local s = state[b]
          if s.depth < #s.segs then
            s.depth = s.depth + 1
            changed = true
          end
        end
      end
    end
  end

  -- assemble final names
  local names = {}
  for _, b in ipairs(bufs) do
    local s = state[b]
    if s.fixed then
      names[b] = s.name
    else
      local parts = {}
      for i = s.depth, 1, -1 do table.insert(parts, s.segs[i]) end
      names[b] = table.concat(parts, "/")
    end
  end
  return names
end

-- ─────────────────────────────────────────────────────────────
-- render
-- ─────────────────────────────────────────────────────────────
local M = {}

function M.render()
  local bufs = listed_buffers()
  local names = display_names(bufs)
  local cur = vim.api.nvim_get_current_buf()
  local line = ""

  for _, b in ipairs(bufs) do
    local active   = b == cur
    local modified = vim.bo[b].modified

    local name_hl = active and "%#TabLineBufActive#" or "%#TabLineBufInactive#"
    local mod_hl  = active and "%#TabLineBufModActive#" or "%#TabLineBufModInactive#"

    local label = names[b]
    local mod_str = modified and (mod_hl .. " ●" .. name_hl) or ""

    line = line
      .. name_hl
      .. "  "
      .. label
      .. mod_str
      .. "  "
  end

  -- fill the rest of the bar with the fill highlight
  line = line .. "%#TabLineFill#"
  return line
end

-- ─────────────────────────────────────────────────────────────
-- setup
-- ─────────────────────────────────────────────────────────────
setup_highlights()

vim.o.tabline    = "%!v:lua.require'tabline'.render()"
vim.o.showtabline = 2

-- re-apply highlights if the colorscheme changes
vim.api.nvim_create_autocmd("ColorScheme", {
  group    = vim.api.nvim_create_augroup("TablineHighlights", { clear = true }),
  callback = setup_highlights,
})

-- ─────────────────────────────────────────────────────────────
-- buffer navigation keymaps
-- ─────────────────────────────────────────────────────────────
vim.keymap.set("n", "<C-j>", "<cmd>bnext<cr>",     { silent = true })
vim.keymap.set("n", "<C-k>", "<cmd>bprevious<cr>", { silent = true })

return M
