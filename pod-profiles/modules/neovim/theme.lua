-- Follow the current Omarchy theme when neovim.lua names a colorscheme
-- (the file is a LazyVim lazy spec; we only read the colorscheme string).
-- Default is tokyonight-night, which is Omarchy's tokyo-night theme.
-- Plugins for the common Omarchy schemes are installed from nixpkgs.

local default_scheme = "tokyonight-night"

pcall(function()
  require("tokyonight").setup({
    style = "night",
    transparent = true,
  })
end)

local function current_theme_file()
  local home = vim.uv.os_homedir()
  local candidates = {
    home .. "/.local/state/omarchy/current/theme/neovim.lua",
    home .. "/.config/omarchy/current/theme/neovim.lua",
  }
  for _, path in ipairs(candidates) do
    if vim.uv.fs_stat(path) then
      return path
    end
  end
end

local function colorscheme_from_omarchy()
  local path = current_theme_file()
  if not path then
    return nil
  end
  local f = io.open(path, "r")
  if not f then
    return nil
  end
  local text = f:read("*a")
  f:close()
  return text:match('colorscheme%s*=%s*"([^"]+)"') or text:match("colorscheme%s*=%s*'([^']+)'")
end

local scheme = colorscheme_from_omarchy() or default_scheme
if not pcall(vim.cmd.colorscheme, scheme) then
  vim.notify("Unknown colorscheme '" .. scheme .. "', falling back to " .. default_scheme, vim.log.levels.WARN)
  if not pcall(vim.cmd.colorscheme, default_scheme) then
    vim.notify("Colorscheme " .. default_scheme .. " is not available", vim.log.levels.ERROR)
  end
end

-- Omarchy overlay transparency: clear backgrounds, keep other attributes.
local transparent_groups = {
  "Normal",
  "NormalFloat",
  "FloatBorder",
  "Pmenu",
  "Terminal",
  "EndOfBuffer",
  "FoldColumn",
  "Folded",
  "SignColumn",
  "LineNr",
  "CursorLineNr",
  "StatusLine",
  "StatusLineNC",
  "NormalNC",
  "WhichKeyFloat",
  "TelescopeBorder",
  "TelescopeNormal",
  "TelescopePromptBorder",
  "TelescopePromptTitle",
  "NeoTreeNormal",
  "NeoTreeNormalNC",
  "CursorLine",
}

local function apply_transparency()
  for _, name in ipairs(transparent_groups) do
    local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
    if ok then
      hl.bg = nil
      vim.api.nvim_set_hl(0, name, hl)
    end
  end
end

apply_transparency()
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("hadi_transparency", { clear = true }),
  callback = apply_transparency,
})
