
-- Spell
vim.opt.spelllang = 'en_us'
vim.opt.spell = true

-- Setup trouble
vim.keymap.set("n", "<leader>xq", "<cmd>TroubleToggle quickfix<cr>",
  {silent = true, noremap = true}
)

vim.api.nvim_set_keymap("v", "<leader>ri", [[ <Esc><Cmd>lua require('refactoring').refactor('Inline Variable')<CR>]], {noremap = true, silent = true, expr = false})

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

