
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
local conform = require("conform")
conform.setup({
  formatters_by_ft = {
    lua = { "stylua" },
    java = { "google-java-format" },
    kotlin = { "ktlint" },
    markdown = { { "prettierd", "prettier" } },
    rust = { "rustfmt" },
    yaml = { "yamlfix" },
    toml = { "taplo" },
  },
})

vim.keymap.set({ "n", "v" }, "<leader>l", function()
    conform.format({
      lsp_fallback = true,
      async = false,
      timeout_ms = 500,
    })
  end
)

-- Grammarous
vim.g["grammarous#jar_url"] = 'https://www.languagetool.org/download/LanguageTool-5.9.zip'

