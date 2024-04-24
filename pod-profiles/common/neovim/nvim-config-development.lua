
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

