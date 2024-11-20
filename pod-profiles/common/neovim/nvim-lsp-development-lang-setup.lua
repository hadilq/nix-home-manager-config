local function on_attach(client, bufnr)
  local opts = {buffer = bufnr, remap = false}

  vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
  vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
  vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
  vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
  vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
  vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
  vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
  vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
  vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
  vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
  vim.keymap.set("n", "]|", vim.diagnostic.goto_next)
  vim.keymap.set("n", "[|", vim.diagnostic.goto_prev)
end

local lspconfig = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').default_capabilities()

local lspconfig_opts = {
  on_attach = on_attach,
  capabilities = capabilities,
}
lspconfig.pylsp.setup(lspconfig_opts)
lspconfig.kotlin_language_server.setup(lspconfig_opts)
lspconfig.jdtls.setup(lspconfig_opts)
lspconfig.ltex.setup(lspconfig_opts)
lspconfig.bashls.setup(lspconfig_opts)
lspconfig.jsonls.setup(lspconfig_opts)
lspconfig.zls.setup(lspconfig_opts)

require('grammar-guard').init()

lspconfig.grammar_guard.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = { "/home/dev/.nix-profile/bin/ltex-ls" },
  settings = {
    ltex = {
      enabled = { "latex", "tex", "bib", "markdown" },
      language = "en-GB",
      diagnosticSeverity = "info",
      checkFrequency = "save",
      additionalRules = {
        enablePickyRules = false,
      },
    },
  },
})

