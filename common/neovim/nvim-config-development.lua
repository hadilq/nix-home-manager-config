
-- Setup refactoring
require('refactoring').setup({})

-- Setup nvim-lint
require('lint').linters_by_ft = {
  markdown = { 'vale' },
  python = { "mypy", "ruff" },
  nix = { "statix" },
  bash = { "shellcheck" },
  rust = { "rustfmt" }
}

-- Grammarous
vim.g["grammarous#jar_url"] = 'https://www.languagetool.org/download/LanguageTool-5.9.zip'

