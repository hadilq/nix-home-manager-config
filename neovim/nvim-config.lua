
-- Setup trouble
vim.keymap.set("n", "<leader>xq", "<cmd>TroubleToggle quickfix<cr>",
  {silent = true, noremap = true}
)

-- Setup refactoring
require('refactoring').setup({})

vim.api.nvim_set_keymap("v", "<leader>ri", [[ <Esc><Cmd>lua require('refactoring').refactor('Inline Variable')<CR>]], {noremap = true, silent = true, expr = false})

-- Setup nvim-lint
require('lint').linters_by_ft = {
  markdown = { 'vale' },
  python = { "mypy", "ruff" },
  nix = { "statix" },
  bash = { "shellcheck" },
  rust = { "rustfmt" }
}

-- Srtup conform-nvim
require("conform").formatters.lua_format = {
  command = "lua-format",
  stdin = true
}

-- Grammarous
vim.g["grammarous#jar_url"] = 'https://www.languagetool.org/download/LanguageTool-5.9.zip'

