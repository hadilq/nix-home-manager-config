
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

lspconfig.ccls.setup {
  init_options = {
    compilationDatabaseDirectory = "build";
    index = {
      threads = 0;
    };
    clang = {
      excludeArgs = { "-frounding-math"} ;
    };
  }
}

