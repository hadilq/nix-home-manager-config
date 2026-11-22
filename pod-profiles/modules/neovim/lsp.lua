-- nixd and lua_ls, using the binaries from programs.neovim.extraPackages.
-- [d / ]d follow Vim convention (prev / next). The old config had them reversed.

vim.diagnostic.config({ virtual_text = true })

local function on_attach(_, bufnr)
  local opts = { buffer = bufnr }
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts)
  vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts)
  vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
  vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
  vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, opts)
  vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references, opts)
  vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts)
  vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)
  vim.keymap.set("n", "]|", vim.diagnostic.goto_next, opts)
  vim.keymap.set("n", "[|", vim.diagnostic.goto_prev, opts)
end

local capabilities = require("cmp_nvim_lsp").default_capabilities()

local servers = {
  nixd = {},
  lua_ls = {
    settings = {
      Lua = {
        runtime = { version = "LuaJIT" },
        diagnostics = { globals = { "vim" } },
        workspace = { checkThirdParty = false },
        telemetry = { enable = false },
      },
    },
  },
}

for name, extra in pairs(servers) do
  local opts = vim.tbl_deep_extend("force", {
    on_attach = on_attach,
    capabilities = capabilities,
  }, extra)
  if vim.lsp.config then
    vim.lsp.config(name, opts)
    vim.lsp.enable(name)
  else
    require("lspconfig")[name].setup(opts)
  end
end
