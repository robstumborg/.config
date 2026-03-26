-- status-line.lua
-- minimal statusline using neovim 0.12 built-ins
-- requires a nerd font patched terminal font
-- colors are from tokyonight-night palette

-- ─────────────────────────────────────────────────────────────
-- state: toggleable display flags
-- ─────────────────────────────────────────────────────────────
local state = {
  show_path   = true,
  show_branch = true,
}

-- ─────────────────────────────────────────────────────────────
-- config
-- ─────────────────────────────────────────────────────────────
local config = {
  icons = {
    git           = " ",   -- nf-dev-git_branch
    lsp           = " ",   -- nf-cod-symbol_misc (hierarchy)
    error         = " ",   -- nf-cod-error
    warn          = " ",   -- nf-cod-warning
    info          = " ",   -- nf-cod-info
    hint          = " ",   -- nf-cod-lightbulb
    modified      = "●",    -- U+25CF, no NF needed
    readonly      = " ",   -- nf-fa-lock
    path_hidden   = "…",
    branch_hidden = "…",
  },
  -- tokyonight-night palette
  colors = {
    purple  = "#bb9af7",  -- functions, branch
    green   = "#9ece6a",  -- strings, git added
    yellow  = "#e0af68",  -- warnings, git changed, modified
    red     = "#f7768e",  -- errors, git removed
    cyan    = "#7dcfff",  -- lsp, info diag
    teal    = "#1abc9c",  -- hints
    fg      = "#c0caf5",  -- main foreground
    dim     = "#565f89",  -- comments, muted elements
  },
}

-- ─────────────────────────────────────────────────────────────
-- highlight groups — explicit 24-bit colors, no chained links
-- ─────────────────────────────────────────────────────────────
local function setup_highlights()
  local c = config.colors
  local set = vim.api.nvim_set_hl

  set(0, "StatusLineFilename", { fg = c.fg,     bold = true })
  set(0, "StatusLineDim",      { fg = c.dim })
  set(0, "StatusLineMod",      { fg = c.yellow })
  set(0, "StatusLineReadonly", { fg = c.dim })
  set(0, "StatusLineGitBranch",{ fg = c.purple })
  set(0, "StatusLineGitAdd",   { fg = c.green })
  set(0, "StatusLineGitChg",   { fg = c.yellow })
  set(0, "StatusLineGitDel",   { fg = c.red })
  set(0, "StatusLineDiagE",    { fg = c.red })
  set(0, "StatusLineDiagW",    { fg = c.yellow })
  set(0, "StatusLineDiagI",    { fg = c.cyan })
  set(0, "StatusLineDiagH",    { fg = c.teal })
  set(0, "StatusLineLSP",      { fg = c.cyan })
  set(0, "StatusLinePos",      { fg = c.fg })
  set(0, "StatusLinePosLabel", { fg = c.dim })
end

setup_highlights()

-- re-apply after colorscheme changes
vim.api.nvim_create_autocmd("ColorScheme", {
  group    = vim.api.nvim_create_augroup("StatuslineHL", { clear = true }),
  callback = setup_highlights,
})

-- ─────────────────────────────────────────────────────────────
-- helpers
-- ─────────────────────────────────────────────────────────────

-- wrap text in a statusline highlight group, then reset
local function hl(group, text)
  return string.format("%%#%s#%s%%*", group, text)
end

-- double-space gap for breathing room between segments
local function gap()
  return "  "
end

-- ─────────────────────────────────────────────────────────────
-- components
-- ─────────────────────────────────────────────────────────────

-- directory path prefix (toggleable, dim)
local function filepath()
  local fpath = vim.fn.fnamemodify(vim.fn.expand("%"), ":~:.:h")
  if fpath == "" or fpath == "." then
    return ""
  end
  if state.show_path then
    return hl("StatusLineDim", "%<" .. fpath .. "/")
  end
  return hl("StatusLineDim", config.icons.path_hidden .. "/")
end

-- filename, bold + bright. modified dot and readonly lock appended.
local function filename()
  local name = vim.fn.expand("%:t")
  if name == "" then
    return hl("StatusLineDim", "no name")
  end

  local result = hl("StatusLineFilename", name)

  if vim.bo.modified then
    result = result .. " " .. hl("StatusLineMod", config.icons.modified)
  elseif vim.bo.readonly or not vim.bo.modifiable then
    result = result .. " " .. hl("StatusLineReadonly", config.icons.readonly)
  end

  return result
end

-- git branch icon + name, then per-file hunk stats separately
local function git()
  local info = vim.b.gitsigns_status_dict
  if not info or info.head == nil or info.head == "" then
    return ""
  end

  -- branch
  local branch_text
  if state.show_branch then
    branch_text = config.icons.git .. info.head
  else
    branch_text = config.icons.git .. config.icons.branch_hidden
  end
  local branch = hl("StatusLineGitBranch", branch_text)

  -- per-file hunk stats
  local hunks = {}
  if info.added   and info.added   > 0 then
    table.insert(hunks, hl("StatusLineGitAdd", "+" .. info.added))
  end
  if info.changed and info.changed > 0 then
    table.insert(hunks, hl("StatusLineGitChg", "~" .. info.changed))
  end
  if info.removed and info.removed > 0 then
    table.insert(hunks, hl("StatusLineGitDel", "-" .. info.removed))
  end

  if #hunks == 0 then
    return branch
  end
  return branch .. "  " .. table.concat(hunks, " ")
end

-- diagnostic counts with nerd font icons, each severity colored
local function diagnostics()
  local counts = vim.diagnostic.count(0)
  if vim.tbl_isempty(counts) then
    return ""
  end

  local items = {
    { sev = vim.diagnostic.severity.ERROR, icon = config.icons.error, grp = "StatusLineDiagE" },
    { sev = vim.diagnostic.severity.WARN,  icon = config.icons.warn,  grp = "StatusLineDiagW" },
    { sev = vim.diagnostic.severity.INFO,  icon = config.icons.info,  grp = "StatusLineDiagI" },
    { sev = vim.diagnostic.severity.HINT,  icon = config.icons.hint,  grp = "StatusLineDiagH" },
  }

  local parts = {}
  for _, item in ipairs(items) do
    local n = counts[item.sev]
    if n and n > 0 then
      table.insert(parts, hl(item.grp, item.icon .. n))
    end
  end

  if #parts == 0 then
    return ""
  end
  return table.concat(parts, " ")
end

-- lsp client(s) for the current buffer, with icon
local function lsp_client()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then
    return ""
  end
  local names = {}
  for _, c in ipairs(clients) do
    table.insert(names, c.name)
  end
  return hl("StatusLineLSP", config.icons.lsp .. table.concat(names, ","))
end

-- filetype — hidden for empty/unknown buffers
local function filetype()
  local ft = vim.bo.filetype
  if ft == "" then
    return ""
  end
  return hl("StatusLineDim", ft)
end

-- file encoding — only shown when not utf-8
local function encoding()
  local enc = (vim.bo.fileencoding ~= "" and vim.bo.fileencoding) or vim.o.encoding
  if enc == "utf-8" then
    return ""
  end
  return hl("StatusLineDim", enc)
end

-- search match count — only shown during an active search pattern
local function searchcount()
  local mode = vim.fn.mode()
  if mode ~= "n" and mode ~= "no" and mode ~= "nov" then
    return ""
  end
  local ok, result = pcall(vim.fn.searchcount, { recompute = 0, maxcount = 999 })
  if not ok or result == nil or result.total == nil or result.total == 0 then
    return ""
  end
  local cur   = result.incomplete == 1 and "?" or result.current
  local total = result.incomplete == 2 and (result.total .. "+") or result.total
  return hl("StatusLineDim", cur .. "/" .. total)
end

-- scroll position: top/bot (lowercase) based on cursor line, otherwise percentage.
local function scroll_position()
  local cursor = vim.fn.line(".")
  local total  = vim.fn.line("$")
  local last   = vim.fn.line("w$")

  if cursor == 1 then
    return "top"
  elseif last == total then
    return "bot"
  else
    return "%p%%"
  end
end

-- cursor position: scroll label dim, line:col bright
local function position()
  return hl("StatusLinePosLabel", scroll_position()) .. "  " .. hl("StatusLinePos", "%l:%c")
end

-- ─────────────────────────────────────────────────────────────
-- assembly
-- ─────────────────────────────────────────────────────────────

Statusline = {}

function Statusline.active()
  -- left
  local left_parts = {}

  local git_str = git()
  if git_str ~= "" then
    table.insert(left_parts, git_str)
  end

  -- path + filename run together (no gap between them)
  table.insert(left_parts, filepath() .. filename())

  local left = " " .. table.concat(left_parts, gap())

  -- right
  local right_parts = {}

  local diag = diagnostics()
  if diag ~= "" then
    table.insert(right_parts, diag)
  end

  local lsp = lsp_client()
  if lsp ~= "" then
    table.insert(right_parts, lsp)
  end

  local ft = filetype()
  if ft ~= "" then
    table.insert(right_parts, ft)
  end

  local enc = encoding()
  if enc ~= "" then
    table.insert(right_parts, enc)
  end

  local sc = searchcount()
  if sc ~= "" then
    table.insert(right_parts, sc)
  end

  table.insert(right_parts, position())

  local right = table.concat(right_parts, gap()) .. " "

  return left .. "%=" .. right
end

function Statusline.inactive()
  local name = vim.fn.expand("%:t")
  if name == "" then name = "no name" end
  return " " .. hl("StatusLineDim", name)
end

-- ─────────────────────────────────────────────────────────────
-- toggles
-- ─────────────────────────────────────────────────────────────

function Statusline.toggle_path()
  state.show_path = not state.show_path
  vim.cmd("redrawstatus")
end

function Statusline.toggle_branch()
  state.show_branch = not state.show_branch
  vim.cmd("redrawstatus")
end

vim.keymap.set("n", "<leader>sp", Statusline.toggle_path,
{ desc = "statusline: toggle path" })
vim.keymap.set("n", "<leader>sb", Statusline.toggle_branch,
{ desc = "statusline: toggle git branch" })

-- ─────────────────────────────────────────────────────────────
-- autocmds
-- ─────────────────────────────────────────────────────────────

local group = vim.api.nvim_create_augroup("Statusline", { clear = true })

vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
  group    = group,
  desc     = "activate statusline on focus",
  callback = function()
    vim.opt_local.statusline = "%!v:lua.Statusline.active()"
  end,
})

vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
  group    = group,
  desc     = "deactivate statusline when unfocused",
  callback = function()
    vim.opt_local.statusline = "%!v:lua.Statusline.inactive()"
  end,
})

